# Function to write actions
function Write-Action {
    param (
        [string]$message
    )
    $logFilePath = Join-Path -Path $PSScriptRoot -ChildPath "action_log.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFilePath -Value "$timestamp - $message"
}

# Example usage in existing functions
$DC = "domaincontroller.example.com"
Write-Action "Password reset successfully on domain controller: $DC"