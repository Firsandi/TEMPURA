package models

import (
	"time"
)

type BatchProduksi struct {
	BatchID         uint       `gorm:"primaryKey;column:batch_id" json:"batch_id"`
	NamaBatch       string     `json:"nama_batch"`
	TanggalProduksi time.Time  `json:"tanggal_produksi"`
	StatusBatch     string     `gorm:"default:draft" json:"status_batch"` // draft, active, completed
	JumlahBungkus   int        `json:"jumlah_bungkus"`
	JumlahKedelai   float64    `json:"jumlah_kedelai"`
	JumlahRagi      int        `json:"jumlah_ragi"`
	CreatedBy       uint       `json:"created_by"`
	CreatedAt       time.Time  `json:"created_at"`
	IsDeleted       bool       `gorm:"default:false" json:"is_deleted"`
}

type ProductionHistory struct {
	HistoryID    uint       `gorm:"primaryKey;column:history_id" json:"history_id"`
	BatchID      uint       `json:"batch_id"`
	RunNumber    int        `json:"run_number"`
	StartTime    time.Time  `json:"start_time"`
	EndTime      *time.Time `json:"end_time"`
	Status       string     `json:"status"` // Berhasil Fermentasi (normal), Fermentasi Dihentikan (dihentikan paksa)
}

type SensorData struct {
	SensorDataID uint      `gorm:"primaryKey;column:sensor_data_id" json:"sensor_data_id"`
	BatchID      *uint     `json:"batch_id"`
	HistoryID    *uint     `json:"history_id"`
	Suhu         float64   `json:"suhu"`
	Kelembaban   float64   `json:"kelembaban"`
	SoilMoisture int       `json:"soil_moisture"`
	Timestamp    time.Time `gorm:"autoCreateTime" json:"timestamp"`
}

type Device struct {
	DeviceID   uint   `gorm:"primaryKey;column:device_id" json:"device_id"`
	DeviceName string `json:"device_name"`
}

type DeviceStatus struct {
	StatusID  uint      `gorm:"primaryKey;column:status_id" json:"status_id"`
	DeviceID  uint      `json:"device_id"`
	Status    bool      `json:"status"`
	Timestamp time.Time `json:"timestamp"`
}

type DeviceControlLog struct {
	LogID     uint      `gorm:"primaryKey;column:log_id" json:"log_id"`
	DeviceID  uint      `json:"device_id"`
	UserID    uint      `json:"user_id"`
	Action    string    `json:"action"` // ON, OFF
	Timestamp time.Time `json:"timestamp"`
}
