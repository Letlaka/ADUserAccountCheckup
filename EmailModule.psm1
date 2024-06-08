# Function to send email notifications
function Send-EmailNotification {
    param (
        [string]$subject,
        [string]$body
    )
    $smtpServer = "smtp.yourserver.com"
    $from = "admin@yourdomain.com"
    $to = "recipient@yourdomain.com"
    
    Send-MailMessage -SmtpServer $smtpServer -From $from -To $to -Subject $subject -Body $body -BodyAsHtml
}

# Example usage in existing functions
Send-EmailNotification -subject "Password Reset" -body "Password reset successfully on domain controller: $DC"
