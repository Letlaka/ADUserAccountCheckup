# EmailModule.psm1

function Send-EmailNotification {
    param (
        [string]$subject,
        [string]$body
    )
    $smtpServer = "rwcrexc01.randwestcity.gov.za"
    $from = "Letlaka.Tsotetsi@Randwestcity.gov.za"
    $to = "Letlaka.Tsotetsi@Randwestcity.gov.za"

    try {
        Send-MailMessage -SmtpServer $smtpServer -From $from -To $to -Subject $subject -Body $body -BodyAsHtml
    } catch {
        Write-Warning "Failed to send email: $_"
        Log-Action "Failed to send email: $_"
    }
}
