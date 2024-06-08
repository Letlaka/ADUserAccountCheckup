# ADModule.psm1

function Test-DomainController {
    # Get Win32_ComputerSystem information
    $computer = Get-WmiObject -Class Win32_ComputerSystem
  
    # Check if DomainRole is either 4 (Domain Controller) or 5 (Primary Domain Controller)
    $isDomainController = $computer.DomainRole -in @(4, 5)
  
    # Return the result
    return $isDomainController
}
function Get-DomainControllerList {
    # Define the path to the domain controller list file
    $DCListPath = Join-Path -Path $PSScriptRoot -ChildPath "servers.txt"
  
    # Check if the file exists
    if (Test-Path -Path $DCListPath) {
      # Read the domain controller list from the file
      return Get-Content -Path $DCListPath
    } else {
      # Log a warning about missing file
      Write-Warning "Domain controller list file not found: $DCListPath"
  
      # Get domain controllers from Active Directory and select hostnames
      return Get-ADDomainController -Filter { Enabled -eq $true } | Select-Object -ExpandProperty HostName
    }
  }
  
  function Get-ADCredential {
    param (
      [Parameter(Mandatory=$true)]
      [string] $Server
    )
  
    do {
      # Prompt for credentials
      $credential = Get-Credential -Message "Enter credentials"
  
      try {
        # Validate credentials by attempting to get any user
        Get-ADUser -Filter * -Server $Server -Credential $credential -ErrorAction Stop | Out-Null
        return $credential
      } catch {
        # Log a warning about invalid credentials
        Write-Warning "Invalid credentials, please try again"
      }
    } while ($true)
  }
  
  function Get-UserInformation {
    param (
      [Parameter(Mandatory=$true)]
      [string] $Username,
      [Parameter(Mandatory=$true)]
      [array] $Servers,
      [Parameter(Mandatory=$false)]
      [PSCredential] $Credential = $null
    )
  
    $properties = @('AccountExpirationDate', 'PasswordExpired', 'PasswordLastSet', 'LockedOut', 'PasswordNeverExpires', 'LastLogonDate', 'Enabled')
  
    # Loop through each server
    foreach ($server in $Servers) {
      try {
        # Get user information with specified properties
        if ($Credential) {
          $userInfo = Get-ADUser -Identity $Username -Server $server -Credential $Credential -Properties $properties -ErrorAction Stop
        } else {
          $userInfo = Get-ADUser -Identity $Username -Server $server -Properties $properties -ErrorAction Stop
        }
        return $userInfo
      } catch {
        # Log a warning about user not found on specific server
        Write-Warning "User not found on domain controller: $server"
      }
    }
  
    # Return null if user not found on any server
    return $null
  }
  