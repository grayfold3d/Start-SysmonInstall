<#
.SYNOPSIS
    Automate install of Sysmon using SwiftonSecurity config
.DESCRIPTION
    This script will download the Sysmon binary files from Microsoft and download the SwiftOnSecurity Sysmon config and install.
    Script must be run from an elevated prompt as Sysmon installs as a service.
.EXAMPLE
    PS C:\Tools> .\Start-SysmonInstall.ps1
.NOTES   
    PowerShell version 5 is required as 
#>

# Function to enable additional protocols as some versions of PowerShell do not support TLS 1.2
function Enable-SSLRequirements
{
    $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
}

# Function to get OS Architecture to determine which version of Sysmon to use
function Get-OSArch {
	try
    {
		$proc = Get-WmiObject win32_processor | Where-Object {$_.deviceID -eq "CPU0"}
	}
    catch 
    { 
        Write-Host "Error detecting OS Architecture $($Error[0])" 
    }
	
	if ($proc.addresswidth -eq '64')
    {
		$Arch = '64'
	}
    elseIf ($proc.addresswidth -eq '32')
    {
		$Arch = '32'
	}

	Write-Output $arch
}


Enable-SSLRequirements

$OSArch = Get-OSArch

# Sysmon staging folder creation
$sysMonDest = "$env:USERPROFILE\Downloads\Sysmon"

if (!(Test-Path $sysMonDest )) {
    try
    {
        New-Item -Path "$sysMonDest" -ItemType Directory  -ErrorAction stop | Out-Null
    }
    catch
    {
        Write-Host "Error creating destination folder": $($error[0]) -ForegroundColor Red
    }
}

# Download Sysmon files
$sysMonURL = "https://download.sysinternals.com/files/Sysmon.zip"
$sysMonConfigURL = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"

try
{
    $sysMonResponse = Invoke-WebRequest -Uri $sysMonURL -OutFile "$sysMonDest/Sysmon.zip"
}
catch
{
    Write-Host "Error downloading Symon binary; $($error[0])" -ForegroundColor Red
    break
}

# Donwloading config file for Sysmon
try
{
    $sysMonconfigResponse = Invoke-WebRequest -Uri $sysMonConfigURL -OutFile "$sysMonDest/sysmonconfig-export.xml"
}
catch
{
    Write-Host "Error downloading Symon binary; $($error[0])" -ForegroundColor Red
    break
}


# Test for Archiving cmdlets and if installed
if (!(Get-Command Expand-Archive -ErrorAction SilentlyContinue))
{
    Write-Host "Archive Cmdlets not found. Verify PowerShell version 5 or greater is installed" -ForegroundColor Yellow
    return
}
# Archiving cmdlets found 
else
{
    $global:progressPreference = 'silentlyContinue'
    try
    {  
        Expand-Archive -Path "$sysMonDest\Sysmon.zip" -DestinationPath $sysMonDest -Force -ErrorAction Stop
    }
    catch
    {
        write-host "Unable to extract file:""$sysMonDest\Sysmon.zip"". Verify file is not in use and that you have access to $sysMonDest." -ForegroundColor Yellow
    }
}

# Install SysMon

if ($OSArch -eq '64')
{
    $command = """$sysMonDest\sysmon64.exe"" -accepteula -i ""$sysMonDest\sysmonconfig-export.xml"""
}
else
{
    $command = """$sysMonDest\sysmon.exe"" -accepteula -i ""$sysMonDest\sysmonconfig-export.xml"""
}
try
{
	iex "& $command" 2> $null
}
catch 
{
	Write-Host "Error installing Sysmon Service $($Error[0])" -ForegroundColor Red 
}

# Test if Sysmon service is installed and cleanup install files

if(Get-Service -Name 'Sysmon*')
{
    Remove-Item $sysMonDest -Recurse
}
else
{
    Write-Host "Unable to verify Sysmon service is installed" -ForegroundColor Red
}