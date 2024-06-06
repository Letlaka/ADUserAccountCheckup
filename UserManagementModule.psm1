# UserManagementModule.psm1

function Set-UserPassword {
    param (
        [string]$username,
        [array]$DCs,
        [securestring]$newPassword
    )
    $resetSuccessful = $false
    foreach ($DC in $DCs) {
        try {
            Set-ADAccountPassword -Identity $username -Server $DC -NewPassword $newPassword
            Set-ADUser -Identity $username -Server $DC -ChangePasswordAtLogon $true
            Write-Output "Password reset successfully on domain controller: $DC"
            Write-LogAction "Password reset successfully on domain controller: $DC"
            Send-EmailNotification -subject "Password Reset" -body "Password reset successfully on domain controller: $DC"
            $resetSuccessful = $true
            break  # Stop after successful reset on any DC
        } catch {
            Write-Warning "Error resetting password on domain controller: $DC"
            Write-LogAction "Error resetting password on domain controller: $DC"
        }
    }

    if (!$resetSuccessful) {
        Write-Warning "Failed to reset the password on all domain controllers"
        Write-LogAction "Failed to reset the password on all domain controllers"
        Send-EmailNotification -subject "Password Reset Failed" -body "Failed to reset the password on all domain controllers"
    }
}
