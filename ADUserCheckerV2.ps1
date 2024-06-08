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
            Check-UserInformation -username $username
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
