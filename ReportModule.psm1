# Function to get account status summary
function Get-AccountStatusSummary {
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

    $report | Export-Csv -Path "UserAccountStatusSummary.csv" -NoTypeInformation
    Write-Output "Account status summary generated: UserAccountStatusSummary.csv"
}

# Call the function
Get-AccountStatusSummary