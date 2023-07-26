# AD-User-Account-Checkup

This PowerShell script checks the status of a specified user account on multiple domain controllers.

## Prerequisites

- A Windows machine with PowerShell 5.1 or later installed.
- The `ActiveDirectory` PowerShell module installed on the machine running the script.
- A file named "servers.txt" in the same directory as the script, containing a list of domain controllers to check, one per line.

## Installing the ActiveDirectory PowerShell Module

The `ActiveDirectory` PowerShell module is included with the Windows Server operating system and can be installed as a feature on Windows Server machines. On non-server Windows machines, the `ActiveDirectory` PowerShell module can be installed using one of the following methods:

### Method 1: Using PowerShell

1. Open a PowerShell console as an administrator.
2. Run the following command to install the `RSAT-AD-PowerShell` feature:

```PowerShell
Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
```

3. Verify that the `ActiveDirectory` module is installed by running the following command:

```PowerShell
Get-Module -ListAvailable -Name ActiveDirectory
```

This should display information about the `ActiveDirectory` module if it is installed correctly.

### Method 2: Using the Settings App

1. Open the Settings app and navigate to "Apps & features".
2. Click on "Optional features" and then click on "Add a feature".
3. Scroll down until you find "RSAT: Active Directory Domain Services and Lightweight Directory Tools" and click on it to select it.
4. Click on "Install" to install the feature.

After installing the feature, verify that the `ActiveDirectory` module is installed by following step 3 from Method 1 above.

## Usage

1. Make sure the `ActiveDirectory` PowerShell module is installed on the machine running the script.
2. Create a file named "servers.txt" in the same directory as the script and list the domain controllers to check, one per line.
3. Run the script and follow the prompts.

## Example

```
PS C:\> .\ADUserChecker.ps1
Enter credentials
Enter the username to check: jdoe

Checking user on domain controller: DC1
Account is enabled
Password age: 45 days
Password age is over 30 days, resetting password to 'Password1'
Account is not locked out on domain controller: DC1

Summary of information checked for user: jdoe

DomainController Enabled AccountExpirationDate PasswordExpired PasswordAgeDays PasswordNeverExpires LockedOut
---------------- ------- -------------------- -------------- --------------- ------------------- --------
DC1              Yes     N/A                  No             45              No                  No     

Script run by: admin on 10/30/2022 16:13:49
Reset password for this user? (y/n): n
Check another user? (y/n): n
```

I hope this helps! Let me know if you have any further questions or concerns. 😊