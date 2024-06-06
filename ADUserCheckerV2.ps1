# MainScript.ps1

# Import modules
Import-Module -Name "$PSScriptRoot\LoggingModule.psm1"
Import-Module -Name "$PSScriptRoot\EmailModule.psm1"
Import-Module -Name "$PSScriptRoot\ADModule.psm1"
Import-Module -Name "$PSScriptRoot\UserManagementModule.psm1"
Import-Module -Name "$PSScriptRoot\ReportModule.psm1"
Import-Module -Name "$PSScriptRoot\MenuModule.psm1"

# Main script loop with menu
$DCs = Get-DomainControllerList
$isDC = Test-DomainController

if (-not $isDC) {
    $credential = Get-ADCredential -server ($DCs[0])
}

do {
    $choice = Show-UserMenu -title "User Account Management"

    switch ($choice) {
        "1" {
            $username = Read-Host -Prompt 'Enter the username to check'
            try {
                $userInfo = Get-UserInformation -username $username -servers $DCs -credential $credential
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
                Write-LogAction "Error: $errorMessage"
                Send-EmailNotification -subject "User Info Check Error" -body "An error occurred while checking the user information: $errorMessage"
            }
        }
        "2" {
            $username = Read-Host -Prompt 'Enter the username to reset password'
            $newPassword = Read-Host -Prompt 'Enter the new password' -AsSecureString
            Set-UserPassword -username $username -DCs $DCs -newPassword $newPassword
        }
        "3" {
            $username = Read-Host -Prompt 'Enter the username to unlock account'
            Unlock-UserAccount -username $username -DCs $DCs
        }
        "4" {
            New-AccountStatusSummary
        }
        "5" {
            exit
        }
        default {
            Write-Host "Invalid choice, please try again."
        }
    }
} while ($true)
