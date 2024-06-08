function Check-UserInformation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$username
    )

    $DCs = Get-ADDomainController -Discover -ErrorAction Stop
    $credential = Get-Credential

    $userInfo = Get-CachedUserInfo -username $username -servers $DCs -credential $credential
    if ($userInfo) {
        $DCInfo = @()

        foreach ($DC in $DCs) {
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

            $DCInfo += $domainControllerInfo
        }

        Display-UserInfo -DCInfo $DCInfo -username $username

        if ($userInfo.LockedOut) {
            Write-Output "The account is locked out on the following domain controllers:"
            $DCInfo | Where-Object { $_.LockedOut } | ForEach-Object { Write-Output $_ }

            # Automatically unlock the account
            Write-Output "Automatically unlocking the account on all domain controllers where it is locked out."
            Unlock-UserAccount -username $username -DCs $DCs
        } else {
            Write-Output "The account is not locked out on any domain controller."
        }
    } else {
        if ($DCs.Count -gt 0) {
            Write-Warning "User not found on domain controller: $($DCs[0])"
        } else {
            Write-Warning "No domain controllers provided. Cannot check user information."
        }
    }
}