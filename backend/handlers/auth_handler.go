package handlers

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"net/http"
	"time"

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

	// Generate 6-digit OTP token
	token, _ := generateOTP(6)
	expiresAt := time.Now().Add(1 * time.Hour) // Token valid for 1 hour

	// Create request
	request := models.PasswordResetRequest{
		Username:  user.Username,
		Email:     input.Email,
		Token:     token,
		ExpiresAt: expiresAt,
		IsUsed:    false,
	}

	if err := config.DB.Create(&request).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat permintaan reset"})
		return
	}

	// Simulation: Print to console (In production, send via email)
	fmt.Printf("SIMULASI EMAIL: Token reset password untuk %s: %s (Berlaku s/d %v)\n", 
		user.Email, token, expiresAt.Format("15:04:05"))

	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"message": "Kode verifikasi telah dikirim ke email Anda.",
	})
}

func ResetPassword(c *gin.Context) {
	var input struct {
		Email       string `json:"email" binding:"required"`
		Token       string `json:"token" binding:"required"`
		NewPassword string `json:"new_password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format input tidak valid"})
		return
	}

	var request models.PasswordResetRequest
	// Find the most recent unused token for this email
	err := config.DB.Where("email = ? AND token = ? AND is_used = ?", input.Email, input.Token, false).
		Order("created_at desc").First(&request).Error

	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Kode verifikasi salah atau sudah digunakan"})
		return
	}

	// Check expiry
	if time.Now().After(request.ExpiresAt) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Kode verifikasi telah kedaluwarsa"})
		return
	}

	// Update User Password
	if err := config.DB.Model(&models.User{}).Where("username = ?", request.Username).
		Update("password", input.NewPassword).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui kata sandi"})
		return
	}

	// Mark token as used
	config.DB.Model(&request).Update("is_used", true)

	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"message": "Kata sandi berhasil diperbarui. Silakan login kembali.",
	})
}

// Helper function to generate OTP
func generateOTP(n int) (string, error) {
	const digits = "0123456789"
	ret := make([]byte, n)
	for i := 0; i < n; i++ {
		num, err := rand.Int(rand.Reader, big.NewInt(int64(len(digits))))
		if err != nil {
			return "", err
		}
		ret[i] = digits[num.Int64()]
	}
	return string(ret), nil
}

func ChangePassword(c *gin.Context) {
	var input struct {
		UserID      uint   `json:"user_id" binding:"required"`
		OldPassword string `json:"old_password" binding:"required"`
		NewPassword string `json:"new_password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	if err := config.DB.First(&user, input.UserID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	if user.Password != input.OldPassword {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Kata sandi lama salah"})
		return
	}

	if err := config.DB.Model(&user).Update("password", input.NewPassword).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui kata sandi"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"message": "Kata sandi berhasil diubah",
	})
}

