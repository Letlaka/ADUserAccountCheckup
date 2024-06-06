# ADModule.psm1

function Test-DomainController {
    $computer = Get-WmiObject -Class Win32_ComputerSystem
    return $computer.DomainRole -eq 4 -or $computer.DomainRole -eq 5
}

function Get-DomainControllerList {
    $DCListPath = Join-Path -Path $PSScriptRoot -ChildPath "servers.txt"
    if (Test-Path $DCListPath) {
        return Get-Content $DCListPath
    } else {
        Write-Warning "Domain controller list file not found: $DCListPath"
        return Get-ADDomainController -Filter {Enabled -eq $true} | Select-Object -ExpandProperty HostName
    }
}

function Get-ADCredential {
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

function Get-UserInformation {
    param (
        [string]$username,
        [array]$servers,
        [pscredential]$credential = $null
    )
    $properties = @('AccountExpirationDate', 'PasswordExpired', 'PasswordLastSet', 'LockedOut', 'PasswordNeverExpires', 'LastLogonDate', 'Enabled')
    foreach ($server in $servers) {
        try {
            if ($credential) {
                $userInfo = Get-ADUser -Identity $username -Server $server -Credential $credential -Properties $properties -ErrorAction Stop
            } else {
                $userInfo = Get-ADUser -Identity $username -Server $server -Properties $properties -ErrorAction Stop
            }
            return $userInfo
        } catch {
            Write-Warning "User not found on domain controller: $server"
        }
    }
    return $null
}
# ADModule.psm1

function Test-DomainController {
    $computer = Get-WmiObject -Class Win32_ComputerSystem
    return $computer.DomainRole -eq 4 -or $computer.DomainRole -eq 5
}

function Get-DomainControllerList {
    $DCListPath = Join-Path -Path $PSScriptRoot -ChildPath "servers.txt"
    if (Test-Path $DCListPath) {
        return Get-Content $DCListPath
    } else {
        Write-Warning "Domain controller list file not found: $DCListPath"
        return Get-ADDomainController -Filter {Enabled -eq $true} | Select-Object -ExpandProperty HostName
    }
}

function Get-ADCredential {
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

function Get-UserInformation {
    param (
        [string]$username,
        [array]$servers,
        [pscredential]$credential = $null
    )
    $properties = @('AccountExpirationDate', 'PasswordExpired', 'PasswordLastSet', 'LockedOut', 'PasswordNeverExpires', 'LastLogonDate', 'Enabled')
    foreach ($server in $servers) {
        try {
            if ($credential) {
                $userInfo = Get-ADUser -Identity $username -Server $server -Credential $credential -Properties $properties -ErrorAction Stop
            } else {
                $userInfo = Get-ADUser -Identity $username -Server $server -Properties $properties -ErrorAction Stop
            }
            return $userInfo
        } catch {
            Write-Warning "User not found on domain controller: $server"
        }
    }
    return $null
}
