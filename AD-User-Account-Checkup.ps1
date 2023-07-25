# Import the ActiveDirectory module
Import-Module ActiveDirectory

# Check if the machine running the script is a domain controller
$computer = Get-WmiObject -Class Win32_ComputerSystem
$isDC = $computer.DomainRole -eq 4 -or $computer.DomainRole -eq 5

# Prompt for credentials if the machine is not a domain controller
if (-not $isDC) {
    $credential = Get-Credential -Message "Enter credentials"
}

# Read the domain controllers to check from a file named "servers.txt" stored in the same directory as the script
$DCs = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "servers.txt")

# Prompt the user for the username to check
$username = Read-Host -Prompt 'Enter the username to check'

# Create an empty array to store information about each domain controller checked
$DCInfo = @()

# Loop through each domain controller
foreach ($DC in $DCs) {
    # Display the current domain controller name
    Write-Output "`nChecking user on domain controller: $DC"

    # Get the user information from the current domain controller
    if ($isDC) {
        $user = Get-ADUser -Identity $username -Server $DC -Properties AccountExpirationDate, PasswordExpired, PasswordLastSet, LockedOut, PasswordNeverExpires, LastLogonDate
    } else {
        $user = Get-ADUser -Identity $username -Server $DC -Credential $credential -Properties AccountExpirationDate, PasswordExpired, PasswordLastSet, LockedOut, PasswordNeverExpires, LastLogonDate
    }

    # Create an object to store information about this domain controller and add it to the array
    $info = New-Object PSObject -Property @{
        DomainController = $DC
        Enabled = if ($user.Enabled) { "Yes" } else { "No" }
        AccountExpirationDate = if ($user.AccountExpirationDate) { $user.AccountExpirationDate } else { "N/A" }
        PasswordExpired = if ($user.PasswordExpired) { "Yes" } else { "No" }
        PasswordAgeDays = (New-TimeSpan -Start $user.PasswordLastSet).Days
        PasswordNeverExpires = if ($user.PasswordNeverExpires) { "Yes" } else { "No" }
        LockedOut = if ($user.LockedOut) { "Yes" } else { "No" }
    }
    $DCInfo += $info

    # Check if the account is enabled or disabled
    if ($user.Enabled -eq $false) {
        Write-Output "Account is disabled. Ask user for a user request form so the account can be enabled."
        break
    } else {
        Write-Output "Account is enabled"
    }

    # Check if the account has an expiration date and if it has passed
    if ($user.AccountExpirationDate -ne $null) {
        if ($user.AccountExpirationDate -lt (Get-Date)) {
            Write-Output "Account has expired. Ask user for a new contract so the account expiry date can be updated."
            break
        }
    }

    # Check if the password has expired
    if ($user.PasswordExpired -eq $true) {
        Write-Output "Password has expired"
    }

    # Calculate the password age in days
    $passwordAge = (New-TimeSpan -Start $user.PasswordLastSet).Days
    Write-Output "Password age: $passwordAge days"

    # Check if the password age is over 30 days and reset it if necessary and if PasswordNeverExpires is not set to true
    if ($passwordAge -gt 30) {
        if ($user.PasswordNeverExpires -ne $true) {
            Write-Output "Password age is over 30 days, resetting password to 'Password1'"
            Set-ADAccountPassword -Identity $user.SamAccountName -NewPassword (ConvertTo-SecureString -AsPlainText "Password1" -Force)
            Set-ADUser -Identity $user.SamAccountName -ChangePasswordAtLogon $true
        } else {
            Write-Output "Skipping password reset because PasswordNeverExpires is set to true"
        }
    }

    # Check if the account is locked out and unlock it if necessary or display a message that it is not locked out
    if ($user.LockedOut -eq $true) {
        Write-Output "Unlocking user account on domain controller: $DC"
        Unlock-ADAccount -Identity $user.SamAccountName
    } else {
        Write-Output "Account is not locked out on domain controller: $DC"
    }
}

# Display a table with the user's name, all the properties checked, and the name of the admin that ran the script, as well as details about the date and time
Write-Output "`nSummary of information checked for user: $username"
$DCInfo | Format-Table -Property DomainController, Enabled, AccountExpirationDate, PasswordExpired, PasswordAgeDays, PasswordNeverExpires, LockedOut
Write-Output "Script run by: $($env:USERNAME) on $(Get-Date)"
