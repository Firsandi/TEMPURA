package config

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"tempura-backend/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDatabase() {
	// Load .env file
	err := godotenv.Load()
	if err != nil {
		log.Println("Warning: No .env file found, using system environment variables")
	}

	host := os.Getenv("DB_HOST")
	user := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASSWORD")
	dbname := os.Getenv("DB_NAME")
	port := os.Getenv("DB_PORT")

	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=require TimeZone=Asia/Jakarta", 
		host, user, password, dbname, port)
	
	database, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})

	if err != nil {
		log.Fatalf("Gagal koneksi ke database: %v. Pastikan kredensial di .env sudah benar.", err)
	}

	DB = database
	
	// Auto Migrate models
	err = DB.AutoMigrate(
		&models.User{},
		&models.BatchProduksi{},
		&models.SensorData{},
		&models.Device{},
		&models.DeviceStatus{},
		&models.DeviceControlLog{},
		&models.ProductionHistory{},
		&models.SystemSetting{},
	)
	if err != nil {
		log.Printf("Gagal migrasi database: %v", err)
	}

	log.Println("Database connected and migrated successfully")

	// Seed Admin User if table is empty
	var count int64
	DB.Model(&models.User{}).Count(&count)
	if count == 0 {
		admin := models.User{
			Username: "admin",
			Password: "admin123", // Harap ganti di produksi
			Fullname: "Administrator Tempura",
			RoleID:   1,
		}
		DB.Create(&admin)
		log.Println("Default admin user created: admin / admin123")
	}
}
