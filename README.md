# AD-User-Account-Checkup

This PowerShell script checks the status of a specified user account on multiple domain controllers, displays user information, and handles password resets if necessary.

## Prerequisites

- A Windows machine with PowerShell 5.1 or later installed.
- The `ActiveDirectory` PowerShell module installed on the machine running the script.
- A file named "servers.txt" in the same directory as the script, containing a list of domain controllers to check, one per line (optional).

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
2. (Optional) Create a file named "servers.txt" in the same directory as the script and list the domain controllers to check, one per line. If this file is not present, the script will fetch the domain controllers dynamically.
3. Run the script and follow the prompts.

## Script Workflow

1. **Import ActiveDirectory Module**: The script begins by importing the `ActiveDirectory` module.
2. **Check if Machine is a Domain Controller**: Uses the `Is-DomainController` function to determine if the machine running the script is a domain controller.
3. **Get Domain Controller List**: The `Get-DomainControllers` function retrieves the list of domain controllers either from `servers.txt` or dynamically.
4. **Get Credentials**: If the script is not running on a domain controller, it will prompt for credentials.
5. **User Interaction**: Prompts for a username to check and retrieves user information using the `Get-UserInfo` function.
6. **Display User Information**: The `Display-UserInfo` function displays detailed user information.
7. **Password Reset**: If the user's password is expired, the script will reset the password to 'Password1' and require a change at the next logon.
8. **Lockout Status**: Displays whether the account is locked out on any domain controllers.

## Example

```PowerShell
PS C:\> .\ADUserChecker.ps1
Enter credentials
Enter the username to check: jdoe

Checking user on domain controller: DC1
Account is enabled
Password age: 45 days
Password age is over 30 days, resetting password to 'Password1'
Account is not locked out on domain controller: DC1

Summary of information checked for user: jdoe

DomainController Enabled AccountExpirationDate PasswordExpired PasswordAgeDays PasswordNeverExpires LockedOut LastLogonDate
---------------- ------- -------------------- -------------- --------------- ------------------- -------- -------------
DC1              Yes     N/A                  No             45              No                  No       10/01/2022     

Script run by: admin on 10/30/2022 16:13:49
Check another user? (y/n): n
