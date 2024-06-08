# MainScript.ps1

# Import modules
Import-Module -Name "$PSScriptRoot\LoggingModule.psm1"
Import-Module -Name "$PSScriptRoot\EmailModule.psm1"
Import-Module -Name "$PSScriptRoot\ADModule.psm1"
Import-Module -Name "$PSScriptRoot\UserManagementModule.psm1"
Import-Module -Name "$PSScriptRoot\ReportModule.psm1"
Import-Module -Name "$PSScriptRoot\MenuModule.psm1"

# Retrieve domain controllers list and check if the current machine is a domain controller
$DCs = Get-DomainControllerList
$isDC = Test-DomainController
$credential = $null

if (-not $isDC) {
    $credential = Get-ADCredential -Server ($DCs[0])
}

# Cache to store user information to avoid redundant AD calls
$userInfoCache = @{}

function Get-CachedUserInfo {
    param (
        [string]$username,
        [array]$servers,
        [PSCredential]$credential = $null
    )

    if ($userInfoCache.ContainsKey($username)) {
        return $userInfoCache[$username]
    }

    $userInfo = Get-UserInformation -username $username -servers $servers -credential $credential
    if ($userInfo) {
        $userInfoCache[$username] = $userInfo
    }
    return $userInfo
}

do {
    $choice = Show-Menu -title "User Account Management"

    switch ($choice) {
        "1" {
            $username = Read-Host -Prompt 'Enter the username to check'
            if ([string]::IsNullOrWhiteSpace($username)) {
                Write-Warning "Username cannot be empty."
                continue
            }
            try {
                $userInfo = Get-CachedUserInfo -username $username -servers $DCs -credential $credential
                if ($userInfo) {
                    $DCInfo = @()
                    $passwordExpired = $false
                    $lockedOutDCs = @()
                    $needsPasswordReset = $false

                    $jobs = @()

                    foreach ($DC in $DCs) {
                        $jobs += Start-Job -ScriptBlock {
                            param ($DC, $userInfo)
                            $domainControllerInfo = [PSCustomObject]@{
                                DomainController      = $DC
                                Enabled               = $userInfo.Enabled
                                AccountExpirationDate = $userInfo.AccountExpirationDate
                                PasswordExpired       = $userInfo.PasswordExpired
                                PasswordAgeDays       = ((Get-Date) - $userInfo.PasswordLastSet).Days
                                PasswordNeverExpires  = $userInfo.PasswordNeverExpires
                                LockedOut             = $userInfo.LockedOut
                                LastLogonDate         = $userInfo.LastLogonDate
                            }

                            if ($userInfo.LockedOut) {
                                $domainControllerInfo
                            }

                            return $domainControllerInfo
                        } -ArgumentList $DC, $userInfo
                    }

                    $DCInfo = $jobs | Receive-Job -Wait -AutoRemoveJob

                    Display-UserInfo -DCInfo $DCInfo -username $username

                    if ($passwordExpired) {
                        Write-Output "Password is expired. Resetting password to 'Password1' and requiring change at next logon."
                        $securePassword = ConvertTo-SecureString 'Password1' -AsPlainText -Force
                        Set-UserPassword -username $username -DCs $DCs -newPassword $securePassword
                    }

                    if ($lockedOutDCs.Count -gt 0) {
                        Write-Output "`nThe account is locked out on the following domain controllers:"
                        $lockedOutDCs | ForEach-Object { Write-Output $_ }

                        # Automatically unlock the account
                        Write-Output "Automatically unlocking the account on all domain controllers where it is locked out."
                        Unlock-UserAccount -username $username -DCs $lockedOutDCs
                    } else {
                        Write-Output "The account is not locked out on any domain controller."
                    }
                } else {
                    Write-Warning "User not found on domain controller: $($DCs[0])"
                }
            } catch {
                $errorMessage = $_.Exception.Message
                Write-Warning "An error occurred while checking the user information: $errorMessage"
                Write-Action "Error: $errorMessage"
                Send-EmailNotification -subject "User Info Check Error" -body "An error occurred while checking the user information: $errorMessage"
            }
        }
        "2" {
            $username = Read-Host -Prompt 'Enter the username to reset password'
            if ([string]::IsNullOrWhiteSpace($username)) {
                Write-Warning "Username cannot be empty."
                continue
            }
            $newPassword = Read-Host -Prompt 'Enter the new password' -AsSecureString
            Set-UserPassword -username $username -DCs $DCs -newPassword $newPassword
        }
        "3" {
            $username = Read-Host -Prompt 'Enter the username to unlock account'
            if ([string]::IsNullOrWhiteSpace($username)) {
                Write-Warning "Username cannot be empty."
                continue
            }
            Unlock-UserAccount -username $username -DCs $DCs
        }
        "4" {
            Get-AccountStatusSummary
        }
        "5" {
            exit
        }
        default {
            Write-Host "Invalid choice, please try again."
        }
    }
} while ($true)
