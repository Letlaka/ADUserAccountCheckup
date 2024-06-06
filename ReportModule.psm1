# ReportModule.psm1

function Generate-AccountStatusSummary {
    $users = Get-ADUser -Filter * -Property DisplayName, Enabled, LastLogonDate
    $report = @()

    foreach ($user in $users) {
        $userSummary = [PSCustomObject]@{
            DisplayName  = $user.DisplayName
            Enabled      = $user.Enabled
            LastLogonDate= $user.LastLogonDate
        }
        $report += $userSummary
    }

    $reportPath = Join-Path -Path $PSScriptRoot -ChildPath "UserAccountStatusSummary.csv"
    $report | Export-Csv -Path $reportPath -NoTypeInformation
    Write-Output "Account status summary generated: $reportPath"
    Log-Action "Account status summary generated: $reportPath"
    Send-EmailNotification -subject "Account Status Summary Generated" -body "Account status summary has been generated: $reportPath"
}
