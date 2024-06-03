# Import the ActiveDirectory module
Import-Module ActiveDirectory

# Function to check if the machine running the script is a domain controller
function Is-DomainController {
    $computer = Get-WmiObject -Class Win32_ComputerSystem
    return $computer.DomainRole -eq 4 -or $computer.DomainRole -eq 5
}

# Function to get domain controller list
function Get-DomainControllers {
    $DCListPath = Join-Path -Path $PSScriptRoot -ChildPath "servers.txt"
    if (Test-Path $DCListPath) {
        return Get-Content $DCListPath
    } else {
        Write-Warning "Domain controller list file not found: $DCListPath"
        return Get-ADDomainController -Filter {Enabled -eq $true} | Select-Object -ExpandProperty HostName
    }
}

# Function to get credentials if needed
function Get-ADCredentials {
    param (
        [string]$server
    )
    do {
        $credential = Get-Credential -Message "Enter credentials"
        try {
            Get-ADUser -Filter * -Server $server -Credential $credential -ErrorAction Stop | Out-Null
            return $credential
        } catch {
            Write-Warning "Invalid credentials, please try again"
        }
    } while ($true)
}

# Function to get user information
function Get-UserInfo {
    param (
        [string]$username,
        [string]$server,
        [pscredential]$credential = $null
    )
    $properties = @('AccountExpirationDate', 'PasswordExpired', 'PasswordLastSet', 'LockedOut', 'PasswordNeverExpires', 'LastLogonDate', 'Enabled')
    if ($credential) {
        return Get-ADUser -Identity $username -Server $server -Credential $credential -Properties $properties -ErrorAction SilentlyContinue
    } else {
        return Get-ADUser -Identity $username -Server $server -Properties $properties -ErrorAction SilentlyContinue
    }
}

# Function to display user information
function Display-UserInfo {
    param (
        [array]$DCInfo,
        [string]$username
    )
    Write-Output "`nSummary of information checked for user: $username"
    $DCInfo | Format-Table -Property DomainController, Enabled, AccountExpirationDate, PasswordExpired, PasswordAgeDays, PasswordNeverExpires, LockedOut, LastLogonDate
    Write-Output "Script run by: $($env:USERNAME) on $(Get-Date)"
}

# Function to handle password reset
function Reset-UserPassword {
    param (
        [string]$username,
        [array]$DCs,
        [string]$newPassword
    )
    $resetSuccessful = $false
    foreach ($DC in $DCs) {
        try {
            Set-ADAccountPassword -Identity $username -Server $DC -NewPassword (ConvertTo-SecureString $newPassword -AsPlainText -Force)
            Set-ADUser -Identity $username -Server $DC -ChangePasswordAtLogon $true
            Write-Output "Password reset successfully on domain controller: $DC"
            $resetSuccessful = $true
            break  # Stop after successful reset on any DC
        } catch {
            Write-Warning "Error resetting password on domain controller: $DC"
        }
    }

    if (!$resetSuccessful) {
        Write-Warning "Failed to reset the password on all domain controllers"
    }
}

# Main script
$DCs = Get-DomainControllers

$isDC = Is-DomainController

if (-not $isDC) {
    $credential = Get-ADCredentials -server ($DCs[0])
}

do {
    $username = Read-Host -Prompt 'Enter the username to check'
    $userInfo = Get-UserInfo -username $username -server ($DCs[0]) -credential $credential

    if ($userInfo) {
        $DCInfo = @()
        $passwordExpired = $false
        $lockedOutDCs = @()
        $needsPasswordReset = $false

        foreach ($DC in $DCs) {
            Write-Output "`nChecking user on domain controller: $DC"

            $domainControllerInfo = New-Object PSCustomObject
            $domainControllerInfo | Add-Member -MemberType NoteProperty -Name DomainController -Value $DC
            $domainControllerInfo | Add-Member -MemberType NoteProperty -Name Enabled -Value $userInfo.Enabled
            $domainControllerInfo | Add-Member -MemberType NoteProperty -Name AccountExpirationDate -Value $userInfo.AccountExpirationDate
            $domainControllerInfo | Add-Member -MemberType NoteProperty -Name PasswordExpired -Value $userInfo.PasswordExpired
            $passwordAgeDays = ((Get-Date) - $userInfo.PasswordLastSet).Days
            $domainControllerInfo | Add-Member -MemberType NoteProperty -Name PasswordAgeDays -Value $passwordAgeDays
            $domainControllerInfo | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires -Value $userInfo.PasswordNeverExpires
            $domainControllerInfo | Add-Member -MemberType NoteProperty -Name LockedOut -Value $userInfo.LockedOut
            $domainControllerInfo | Add-Member -MemberType NoteProperty -Name LastLogonDate -Value $userInfo.LastLogonDate

            if ($userInfo.LockedOut) {
                $lockedOutDCs += $DC
            }

            if ($passwordAgeDays -gt 30) {
                $passwordExpired = $true
            }

            $DCInfo += $domainControllerInfo
        }

        Display-UserInfo -DCInfo $DCInfo -username $username

        if ($passwordExpired) {
            Write-Output "Password is expired. Resetting password to 'Password1' and requiring change at next logon."
            Reset-UserPassword -username $username -DCs $DCs -newPassword 'Password1'
        }

        if ($lockedOutDCs.Count -gt 0) {
            Write-Output "`nThe account is locked out on the following domain controllers:"
            $lockedOutDCs | ForEach-Object { Write-Output $_ }
        } else {
            Write-Output "The account is not locked out on any domain controller."
        }
    } else {
        Write-Warning "User not found on domain controller: $($DCs[0])"
    }

    $checkAnother = Read-Host -Prompt 'Check another user? (y/n)'
} while ($checkAnother -eq 'y')
