# Start-SysmonInstall
Automate Sysmon install using @swiftonsecurity config

This script downloads the Sysmon installation files and the @swiftonsecurity Sysmon configuration file and installs Sysmon.

https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon
https://github.com/SwiftOnSecurity/sysmon-config

## Requirements
* Script must be run as an administrator as Sysmon is installed as a service
* PowerShell 5 or greater is required as this utilizes the Archiving cmdlets to extract files

## Usage
1. Download or Clone this repo and unzip as needed
2. Open PowerShell as Administrator
3. Type the path to the Start-SysmonInstall.ps1 script
    * PS C:\Windows\System32> C:\tools\PATH\TO\PSFile\Start-SysmonInstall.ps1


## Change Log
* 10/26/19 - initial release
