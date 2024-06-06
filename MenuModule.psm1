# MenuModule.psm1

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
