package main

import (
	"log"
	"net/http"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"tempura-backend/handlers"
	"tempura-backend/config"
	"tempura-backend/services"
)

func main() {
	// 1. Initialize Database (Supabase)
	config.ConnectDatabase()

	// 2. Initialize MQTT
	config.InitMQTT()
	services.StartMQTTSubscription()

	// 2. Setup Router
	r := gin.Default()

	// 2.1 Allow CORS
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))

	// 3. Routes
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})

	auth := r.Group("/auth")
	{
		auth.POST("/login", handlers.Login)
		auth.POST("/reset-password", handlers.RequestPasswordReset)
		auth.GET("/reset-requests", handlers.GetResetRequests)
		auth.POST("/reset-requests/:id", handlers.HandleResetRequest)
	}

	batchGroup := r.Group("/batch")
	{
		batchGroup.GET("", handlers.GetBatches)
		batchGroup.POST("", handlers.CreateBatch)
		batchGroup.GET("/:id", handlers.GetBatchDetail)
		batchGroup.PUT("/:id", handlers.UpdateBatch)
		batchGroup.DELETE("/:id", handlers.DeleteBatch)
		batchGroup.PUT("/:id/start", handlers.StartBatch)
		batchGroup.PUT("/:id/stop", handlers.StopBatch)
	}

	dashboard := r.Group("/dashboard")
	{
		dashboard.GET("/latest", handlers.GetDashboardData)
	}

	// 4. Run Server
	log.Println("Server running on port 8080")
	r.Run(":8080")
}
