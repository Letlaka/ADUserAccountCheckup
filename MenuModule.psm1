# MenuModule.psm1
Import-Module -Name "$PSScriptRoot\ADModule.psm1"

# Function to display an interactive menu
function Show-Menu {
    param (
        [string]$title
    )
    $menuOptions = @(
        "1. Check user information",
        "2. Reset user password",
        "3. Unlock user account",
        "4. Generate account status summary",
        "5. Exit"
    )

    Write-Host "==== $title ===="
    $menuOptions | ForEach-Object { Write-Host $_ }
    $choice = Read-Host "Please select an option"

    return $choice
}

# Main script loop with menu
do {
    $choice = Show-Menu -title "User Account Management"
    
    switch ($choice) {
        "1" {
            # Call function to check user information
            $username = Read-Host -Prompt 'Enter the username to check'
            Check-UserInformation -username $username
        }
        "2" {
            # Call function to reset user password
            $username = Read-Host -Prompt 'Enter the username to reset password'
            $newPassword = Read-Host -Prompt 'Enter the new password' -AsSecureString
            Set-UserPassword -username $username -DCs $DCs -newPassword $newPassword
        }
        "3" {
            # Call function to unlock user account
            $username = Read-Host -Prompt 'Enter the username to unlock account'
            Unlock-UserAccount -username $username -DCs $DCs
        }
        "4" {
            Generate-AccountStatusSummary
        }
        "5" {
            break
        }
        default {
            Write-Host "Invalid choice, please try again."
        }
    }
} while ($true)
