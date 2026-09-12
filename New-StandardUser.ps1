<#
.SYNOPSIS
    Creates a local standard user account and sets Windows to log into it
    automatically at boot.

.DESCRIPTION
    Prompts for a password, creates a local (non-Microsoft) account in the
    "Users" group, and enables automatic logon for it using the standard
    Windows Winlogon registry settings.

    Must be run from an elevated (Administrator) PowerShell.
    If the account already exists the script does nothing.

.EXAMPLE
    .\New-StandardUser.ps1
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [string] $UserName = 'Ada'
)

$ErrorActionPreference = 'Stop'

Write-Host "==> Standard user '$UserName'" -ForegroundColor Yellow

if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
    Write-Host '    Already exists, skipping.' -ForegroundColor DarkGray
    exit 0
}

# --- Prompt for password -----------------------------------------------------
$password = Read-Host -Prompt "    Password for '$UserName'" -AsSecureString
if ($password.Length -eq 0) {
    Write-Error 'Password cannot be empty.'
    exit 1
}

# --- Create the account ------------------------------------------------------
New-LocalUser -Name $UserName -Password $password -PasswordNeverExpires -AccountNeverExpires | Out-Null
Add-LocalGroupMember -Group 'Users' -Member $UserName
Write-Host '    Created.' -ForegroundColor Green

# --- Automatic logon ---------------------------------------------------------
# https://learn.microsoft.com/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon
$plainPassword = (New-Object System.Management.Automation.PSCredential ($UserName, $password)).GetNetworkCredential().Password
$winlogon = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
Set-ItemProperty -Path $winlogon -Name 'AutoAdminLogon'    -Value '1'
Set-ItemProperty -Path $winlogon -Name 'DefaultUserName'   -Value $UserName
Set-ItemProperty -Path $winlogon -Name 'DefaultDomainName' -Value $env:COMPUTERNAME
Set-ItemProperty -Path $winlogon -Name 'DefaultPassword'   -Value $plainPassword
Write-Host '    Automatic logon enabled. Reboot to verify.' -ForegroundColor Green
