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
        }
        "2" {
            # Call function to reset user password
        }
        "3" {
            # Call function to unlock user account
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
