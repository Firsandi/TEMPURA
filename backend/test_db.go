package main

import (
	"log"
	"tempura-backend/config"
	"tempura-backend/models"
)

func main() {
	config.ConnectDatabase()
	err := config.DB.AutoMigrate(&models.User{})
	if err != nil {
		log.Printf("MIGRATE ERROR: %v", err)
	} else {
		log.Println("MIGRATE OK")
	}
}
