# AD User Account Checkup

AD User Account Checkup is a PowerShell script that allows you to perform a comprehensive checkup on Active Directory user accounts. It checks various attributes and properties of a user account across multiple domain controllers to ensure the account is in a healthy and secure state.

## Features

- Check user account status (enabled or disabled).
- Monitor account expiration dates and prompt for updates if expired.
- Detect and handle password expiration.
- Reset passwords for accounts with passwords older than 30 days (optional).
- Unlock locked user accounts.
- Support for multiple domain controllers for comprehensive checks.

## Prerequisites

Before running the script, ensure you have the following:

- **For Machines that are Domain Controllers:**
  - PowerShell 5.1 or later (or PowerShell Core 6.0 or later for cross-platform support).
  - ActiveDirectory module is already available on Windows Server by default.

- **For Machines that are NOT Domain Controllers:**
  - PowerShell 5.1 or later (or PowerShell Core 6.0 or later for cross-platform support).
  - Install the ActiveDirectory module by using one of the following methods:

    - **Method 1: Install the ActiveDirectory module from Optional Features in Windows (Windows Server):**
      1. Open the "Server Manager" on your Windows Server.
      2. Click on "Add roles and features."
      3. Click "Next" until you reach the "Features" section.
      4. In the "Features" section, expand "Remote Server Administration Tools" and then "Role Administration Tools."
      5. Find and select "Active Directory Module for Windows PowerShell."
      6. Click "Next" and follow the on-screen instructions to complete the installation.

    - **Method 2: Install the ActiveDirectory module using PowerShell:**
      1. Open PowerShell with administrative privileges.
      2. Run the following command to install the ActiveDirectory module:

         ```powershell
         Install-WindowsFeature RSAT-AD-PowerShell
         ```

      3. After the installation is complete, you can verify if the module is installed by running the following command:

         ```powershell
         Get-Module -Name ActiveDirectory -ListAvailable
         ```

## Usage

1. Clone the repository or download the script file directly to your machine.
2. Open PowerShell and navigate to the directory where the script is located.

```powershell
cd C:\path\to\AD-User-Account-Checkup
```

3. Execute the script by running the following command:

```powershell
.\AD-User-Account-Checkup.ps1
```

4. The script will prompt for the username of the account you wish to check.

5. If the machine running the script is not a domain controller, it will also prompt for credentials.

6. The script will then check the specified user's account attributes on all domain controllers listed in "servers.txt" file.

7. After performing all checks, it will display a summary table with the results for each domain controller.

8. If the account is disabled, expired, or has a password older than 30 days (and PasswordNeverExpires is false), the script will prompt for necessary actions.

## Configuration

The script reads the names of domain controllers from a file named "servers.txt" stored in the same directory as the script. Make sure to list all domain controllers you want to include in the checkup.

To disable the automatic password reset (enabled by default for accounts with passwords older than 30 days), you can modify the script accordingly.

## Contributing

Contributions to this script are welcome! If you find any issues, have feature suggestions, or want to improve the code, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License.

## Disclaimer

This script is provided as-is and without any warranty. Use it at your own risk. Always review and understand the script before executing it, especially in a production environment.