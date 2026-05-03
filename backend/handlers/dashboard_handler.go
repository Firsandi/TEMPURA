package handlers

import (
	"net/http"
	"time"
	"tempura-backend/config"
	"tempura-backend/models"

	"github.com/gin-gonic/gin"
)

func GetDashboardData(c *gin.Context) {
	// 1. Get latest GLOBAL sensor data (for online check)
	var globalLatest models.SensorData
	config.DB.Order("timestamp desc").First(&globalLatest)

	// 2. Get active batch
	var batch models.BatchProduksi
	if err := config.DB.Where("status_batch = ? AND is_deleted = false", "active").Order("created_at desc").First(&batch).Error; err != nil {
		c.JSON(http.StatusOK, gin.H{
			"status": "no_active_batch",
			"message": "Tidak Ada Batch",
			"data": gin.H{
				"latest_sensor": globalLatest,
			},
		})
		return
	}

	// 3. Get latest sensor data for this batch
	var latestData models.SensorData
	config.DB.Where("batch_id = ?", batch.BatchID).Order("timestamp desc").First(&latestData)

	// 4. Calculate Averages for Stats (last 24h or current run)
	var stats struct {
		AvgTemp float64 `json:"avg_temp"`
		AvgHum  float64 `json:"avg_hum"`
	}
	config.DB.Model(&models.SensorData{}).
		Where("batch_id = ?", batch.BatchID).
		Select("AVG(suhu) as avg_temp, AVG(kelembaban) as avg_hum").
		Scan(&stats)

	// 5. Calculate Fermentation Status based on Soil Moisture
	fermentationStatus := "Fase Awal"
	if latestData.SoilMoisture > 0 {
		if latestData.SoilMoisture > 800 {
			fermentationStatus = "Fase Inokulasi"
		} else if latestData.SoilMoisture > 500 {
			fermentationStatus = "Pertumbuhan Miselium"
		} else if latestData.SoilMoisture > 200 {
			fermentationStatus = "Siap Panen"
		} else {
			fermentationStatus = "Selesai (Siap Panen)"
		}
	} else if latestData.SensorDataID == 0 {
		fermentationStatus = "Menunggu Sensor..."
	}

	// 6. Get sensor history (for chart)
	var history []models.SensorData
	config.DB.Where("batch_id = ?", batch.BatchID).Order("timestamp desc").Limit(20).Find(&history)

	// 7. Get Production History (list of runs)
	var runs []models.ProductionHistory
	config.DB.Where("batch_id = ?", batch.BatchID).Order("run_number desc").Find(&runs)

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data": gin.H{
			"batch":               batch,
			"latest_sensor":       globalLatest,
			"stats":               stats,
			"fermentation_status": fermentationStatus,
			"sensor_history":      history,
			"production_runs":     runs,
		},
	})
}

func CreateBatch(c *gin.Context) {
	var input struct {
		NamaBatch     string  `json:"nama_batch"`
		JumlahBungkus int     `json:"jumlah_bungkus"`
		JumlahKedelai float64 `json:"jumlah_kedelai"`
		JumlahRagi    int     `json:"jumlah_ragi"`
		CreatedBy     uint    `json:"created_by"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if batch name already exists
	var existing models.BatchProduksi
	if err := config.DB.Where("nama_batch = ? AND is_deleted = false", input.NamaBatch).First(&existing).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Nama batch sudah ada. Gunakan nama lain."})
		return
	}

	batch := models.BatchProduksi{
		NamaBatch:       input.NamaBatch,
		JumlahBungkus:   input.JumlahBungkus,
		JumlahKedelai:   input.JumlahKedelai,
		JumlahRagi:      input.JumlahRagi,
		TanggalProduksi: time.Now(),
		StatusBatch:     "draft", // Initial status is draft
		CreatedBy:       input.CreatedBy,
		IsDeleted:       false,
	}

	if err := config.DB.Create(&batch).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat batch baru"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"message": "Batch draft berhasil dibuat",
		"data":    batch,
	})
}
