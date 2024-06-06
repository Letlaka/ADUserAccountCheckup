# MainScript.ps1

# Import modules
Import-Module -Name "$PSScriptRoot\LoggingModule.psm1"
Import-Module -Name "$PSScriptRoot\EmailModule.psm1"
Import-Module -Name "$PSScriptRoot\ADModule.psm1"
Import-Module -Name "$PSScriptRoot\UserManagementModule.psm1"
Import-Module -Name "$PSScriptRoot\ReportModule.psm1"
Import-Module -Name "$PSScriptRoot\MenuModule.psm1"

# Main script logic
$DCs = Get-DomainControllers

$isDC = Is-DomainController

if (-not $isDC) {
    $credential = Get-ADCredentials -server ($DCs[0])
} else {
    $credential = $null
}

do {
    $choice = Show-Menu -title "User Account Management"

    switch ($choice) {
        "1" {
            $username = Read-Host -Prompt 'Enter the username to check'
            try {
                $userInfo = Get-UserInfo -username $username -servers $DCs -credential $credential
                if ($userInfo) {
                    # The rest of your code...
                } else {
                    Write-Warning "User not found on any domain controller."
                }
            } catch {
                $errorMessage = $_.Exception.Message
                Write-Warning "An error occurred while checking the user information: $errorMessage"
                Log-Action "Error: $errorMessage"
                Send-EmailNotification -subject "User Info Check Error" -body "An error occurred while checking the user information: $errorMessage"
            }
        }
        "2" {
            $username = Read-Host -Prompt 'Enter the username to reset password'
            $newPassword = Read-Host -Prompt 'Enter the new password'
            Reset-UserPassword -username $username -DCs $DCs -newPassword $newPassword
        }
        "3" {
            $username = Read-Host -Prompt 'Enter the username to unlock account'
            Unlock-UserAccount -username $username -DCs $DCs
        }
        "4" {
            Generate-AccountStatusSummary
        }
        "5" {
            exit
        }
        default {
            Write-Host "Invalid choice, please try again."
        }
    }
} while ($true)
