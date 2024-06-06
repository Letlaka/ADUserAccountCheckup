# UserManagementModule.psm1

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
            Log-Action "Password reset successfully on domain controller: $DC"
            Send-EmailNotification -subject "Password Reset" -body "Password reset successfully on domain controller: $DC"
            $resetSuccessful = $true
            break  # Stop after successful reset on any DC
        } catch {
            Write-Warning "Error resetting password on domain controller: $DC"
            Log-Action "Error resetting password on domain controller: $DC"
        }
    }

    if (!$resetSuccessful) {
        Write-Warning "Failed to reset the password on all domain controllers"
        Log-Action "Failed to reset the password on all domain controllers"
        Send-EmailNotification -subject "Password Reset Failed" -body "Failed to reset the password on all domain controllers"
    }
}

function Unlock-UserAccount {
    param (
        [string]$username,
        [array]$DCs
    )
    $unlockSuccessful = $false
    foreach ($DC in $DCs) {
        try {
            Unlock-ADAccount -Identity $username -Server $DC
            Write-Output "Account unlocked on domain controller: $DC"
            Log-Action "Account unlocked on domain controller: $DC"
            Send-EmailNotification -subject "Account Unlocked" -body "Account unlocked on domain controller: $DC"
            $unlockSuccessful = $true
            break  # Stop after successful unlock on any DC
        } catch {
            Write-Warning "Error unlocking account on domain controller: $DC"
            Log-Action "Error unlocking account on domain controller: $DC"
        }
    }

    if (!$unlockSuccessful) {
        Write-Warning "Failed to unlock the account on all domain controllers"
        Log-Action "Failed to unlock the account on all domain controllers"
        Send-EmailNotification -subject "Account Unlock Failed" -body "Failed to unlock the account on all domain controllers"
    }
}
