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

- PowerShell 5.1 or later (or PowerShell Core 6.0 or later for cross-platform support).
- ActiveDirectory module installed (available by default on Windows Server).
- Sufficient permissions to read user account properties in Active Directory.
- If running the script from a non-domain controller machine, provide appropriate credentials with permissions to query user accounts.

## Usage

1. Clone the repository or download the script file directly to your machine.
2. Open PowerShell and navigate to the directory where the script is located.

```powershell
cd C:\path\to\AD-User-Account-Checkup
```

Execute the script by running the following command:
```powershell
.\AD-User-Account-Checkup.ps1
```

1. The script will prompt for the username of the account you wish to check.

2. If the machine running the script is not a domain controller, it will also prompt for credentials.

3. The script will then check the specified user's account attributes on all domain controllers listed in "servers.txt" file.

4. After performing all checks, it will display a summary table with the results for each domain controller.

5. If the account is disabled, expired, or has a password older than 30 days (and PasswordNeverExpires is false), the script will prompt for necessary actions.

## Configuration
The script reads the names of domain controllers from a file named "servers.txt" stored in the same directory as the script. Make sure to list all domain controllers you want to include in the checkup.

To disable the automatic password reset (enabled by default for accounts with passwords older than 30 days), you can modify the script accordingly.

## Contributing
Contributions to this script are welcome! If you find any issues, have feature suggestions, or want to improve the code, feel free to open an issue or submit a pull request.

## License
This project is licensed under the MIT License.

## Disclaimer
This script is provided as-is and without any warranty. Use it at your own risk. Always review and understand the script before executing it, especially in a production environment.
