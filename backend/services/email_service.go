package services

import (
	"fmt"
	"net/smtp"
	"os"
)

func SendAccountEmail(toEmail, password string) error {
	smtpHost := os.Getenv("SMTP_HOST")
	smtpPort := os.Getenv("SMTP_PORT")
	smtpEmail := os.Getenv("SMTP_EMAIL")
	smtpPassword := os.Getenv("SMTP_PASSWORD")

	if smtpHost == "" || smtpEmail == "" || smtpPassword == "" {
		// Log warning but don't fail, useful for local testing without SMTP configured
		fmt.Println("Warning: SMTP configuration is missing. Cannot send email.")
		fmt.Printf("Generated Account: Email=%s, Password=%s\n", toEmail, password)
		return nil
	}

	auth := smtp.PlainAuth("", smtpEmail, smtpPassword, smtpHost)

	subject := "Informasi Akun Pegawai Tempura"
	body := fmt.Sprintf(`Halo,

Akun pegawai Anda di sistem Tempura telah berhasil dibuat.

Detail Akun Anda:
Email: %s
Kata Sandi: %s

Harap segera masuk ke aplikasi dan kami sarankan untuk mengubah kata sandi Anda.

Salam,
Admin Tempura
`, toEmail, password)

	message := []byte("To: " + toEmail + "\r\n" +
		"Subject: " + subject + "\r\n" +
		"\r\n" +
		body)

	addr := smtpHost + ":" + smtpPort
	err := smtp.SendMail(addr, auth, smtpEmail, []string{toEmail}, message)
	if err != nil {
		return fmt.Errorf("failed to send email: %v", err)
	}

	return nil
}
