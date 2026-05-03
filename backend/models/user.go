package models

import (
	"time"
)

type User struct {
	UserID       uint      `gorm:"primaryKey;column:user_id" json:"id"`
	Username     string    `gorm:"unique;not null" json:"username"`
	Password     string    `gorm:"not null" json:"-"` // Hidden in JSON
	Email        string    `json:"email"`
	Fullname     string    `json:"full_name"`
	RoleID       uint      `json:"role_id"`
	IsActive     bool      `gorm:"default:true" json:"is_active"`
	IsDeleted    bool      `gorm:"default:false" json:"is_deleted"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

type PasswordResetRequest struct {
	RequestID uint      `gorm:"primaryKey;column:request_id" json:"request_id"`
	Username  string    `json:"username"`
	Email     string    `json:"email"`
	Status    string    `gorm:"default:pending" json:"status"` // pending, approved, rejected
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type LoginResponse struct {
	Status  string `json:"status"`
	Message string `json:"message"`
	Data    *User  `json:"data,omitempty"`
}
