package handlers

import (
	"fmt"
	"net/http"
	"github.com/gin-gonic/gin"
	"tempura-backend/config"
	"tempura-backend/models"
)

func Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	// Cari user berdasarkan username
	result := config.DB.Where("username = ? AND is_deleted = false", req.Username).First(&user)
	
	if result.Error != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"status":  "error",
			"message": "User tidak ditemukan",
		})
		return
	}

	// Cek password (Idealnya gunakan bcrypt.CompareHashAndPassword)
	if user.Password != req.Password {
		c.JSON(http.StatusUnauthorized, gin.H{
			"status":  "error",
			"message": "Kata sandi salah",
		})
		return
	}

	c.JSON(http.StatusOK, models.LoginResponse{
		Status:  "success",
		Message: "Login berhasil",
		Data:    &user,
	})
}

func RequestPasswordReset(c *gin.Context) {
	var input struct {
		Email string `json:"email"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Find user by email
	var user models.User
	if err := config.DB.Where("email = ? AND is_deleted = false", input.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Email tidak terdaftar"})
		return
	}

	// Create request
	request := models.PasswordResetRequest{
		Username: user.Username,
		Email:    input.Email,
		Status:   "pending",
	}

	if err := config.DB.Create(&request).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengirim permintaan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"message": "Permintaan reset password telah dikirim ke admin.",
	})
}

func GetResetRequests(c *gin.Context) {
	var requests []models.PasswordResetRequest
	config.DB.Order("created_at desc").Find(&requests)
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": requests})
}

func HandleResetRequest(c *gin.Context) {
	id := c.Param("id")
	var input struct {
		Action string `json:"action"` // approve, reject
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var request models.PasswordResetRequest
	if err := config.DB.First(&request, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Permintaan tidak ditemukan"})
		return
	}

	if input.Action == "approve" {
		request.Status = "approved"
		
		// Reset password logic (Simulasi: set ke "tempura123")
		newPassword := "tempura123"
		config.DB.Model(&models.User{}).Where("username = ?", request.Username).Update("password", newPassword)
		
		// Simulasi kirim email
		fmt.Printf("SIMULASI EMAIL: Password baru untuk %s dikirim ke %s: %s\n", request.Username, request.Email, newPassword)
		
	} else {
		request.Status = "rejected"
	}

	config.DB.Save(&request)
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Permintaan berhasil diproses"})
}
