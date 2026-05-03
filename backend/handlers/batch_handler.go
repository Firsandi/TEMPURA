package handlers

import (
	"fmt"
	"net/http"
	"time"
	"tempura-backend/config"
	"tempura-backend/models"

	"github.com/gin-gonic/gin"
)

// GetBatches returns all batches, including drafts
func GetBatches(c *gin.Context) {
	var batches []models.BatchProduksi
	if err := config.DB.Where("is_deleted = false").Order("status_batch desc, created_at desc").Find(&batches).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data batch"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   batches,
	})
}

// StartBatch moves a batch from draft/completed to active
func StartBatch(c *gin.Context) {
	id := c.Param("id")

	// 1. Check if sensors are detected (latest sensor < 30s)
	var latest models.SensorData
	config.DB.Order("timestamp desc").First(&latest)
	if time.Since(latest.Timestamp) > 30*time.Second {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Sensor tidak terdeteksi. Pastikan alat IoT aktif sebelum memulai batch.",
		})
		return
	}

	// 2. Check if another batch is already active
	var activeCount int64
	config.DB.Model(&models.BatchProduksi{}).Where("status_batch = ? AND is_deleted = false", "active").Count(&activeCount)
	if activeCount > 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Masih ada batch yang sedang berjalan. Hentikan batch tersebut terlebih dahulu.",
		})
		return
	}

	// 3. Get Batch
	var batch models.BatchProduksi
	if err := config.DB.First(&batch, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Batch tidak ditemukan"})
		return
	}

	// 4. Create Production History record
	var lastRun int
	config.DB.Model(&models.ProductionHistory{}).Where("batch_id = ?", batch.BatchID).Select("MAX(run_number)").Row().Scan(&lastRun)
	
	history := models.ProductionHistory{
		BatchID:   batch.BatchID,
		RunNumber: lastRun + 1,
		StartTime: time.Now(),
		Status:    "Berjalan", // Temporary status
	}
	config.DB.Create(&history)

	// 5. Update batch status to active
	config.DB.Model(&batch).Update("status_batch", "active")

	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"message": "Batch berhasil dijalankan",
		"data":    history,
	})
}

// UpdateBatch updates draft batch details
func UpdateBatch(c *gin.Context) {
	id := c.Param("id")
	var input struct {
		NamaBatch     string  `json:"nama_batch"`
		JumlahBungkus int     `json:"jumlah_bungkus"`
		JumlahKedelai float64 `json:"jumlah_kedelai"`
		JumlahRagi    int     `json:"jumlah_ragi"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Only allow update if status is draft
	var batch models.BatchProduksi
	if err := config.DB.Where("batch_id = ?", id).First(&batch).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Batch tidak ditemukan"})
		return
	}

	if batch.StatusBatch != "draft" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Hanya batch berstatus draft yang dapat diubah"})
		return
	}

	if err := config.DB.Model(&batch).Updates(input).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui batch"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Batch berhasil diperbarui"})
}

// DeleteBatch deletes a draft batch
func DeleteBatch(c *gin.Context) {
	id := c.Param("id")
	
	var batch models.BatchProduksi
	if err := config.DB.Where("batch_id = ?", id).First(&batch).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Batch tidak ditemukan"})
		return
	}

	// Check if it has history (already active or completed)
	if batch.StatusBatch != "draft" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Batch yang sudah berjalan tidak dapat dihapus"})
		return
	}

	if err := config.DB.Model(&batch).Update("is_deleted", true).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus batch"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Batch berhasil dihapus"})
}



// StopBatch marks a batch as completed (Manual)
func StopBatch(c *gin.Context) {
	id := c.Param("id")
	
	if err := CompleteBatch(id, "Fermentasi Dihentikan (dihentikan paksa)"); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"message": "Batch berhasil dihentikan paksa",
	})
}

// CompleteBatch is a helper to finalize a batch session
func CompleteBatch(batchID interface{}, status string) error {
	now := time.Now()
	
	// 1. Update Batch status
	if err := config.DB.Model(&models.BatchProduksi{}).Where("batch_id = ?", batchID).Update("status_batch", "completed").Error; err != nil {
		return fmt.Errorf("gagal update status batch: %v", err)
	}

	// 2. Update Production History
	if err := config.DB.Model(&models.ProductionHistory{}).
		Where("batch_id = ? AND end_time IS NULL", batchID).
		Updates(map[string]interface{}{
			"end_time": &now,
			"status":   status,
		}).Error; err != nil {
		return fmt.Errorf("gagal update history: %v", err)
	}

	return nil
}

func GetBatchDetail(c *gin.Context) {
	id := c.Param("id")

	var batch models.BatchProduksi
	if err := config.DB.First(&batch, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Batch tidak ditemukan"})
		return
	}

	var runs []models.ProductionHistory
	config.DB.Where("batch_id = ?", batch.BatchID).Order("run_number desc").Find(&runs)

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data": gin.H{
			"batch":           batch,
			"production_runs": runs,
		},
	})
}
