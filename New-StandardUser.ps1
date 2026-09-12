<#
.SYNOPSIS
    Creates a local, non-administrator user account.

.DESCRIPTION
    Prompts for a password, then creates a local account (no Microsoft account)
    that is a member of "Users" only. The account is made the default selection
    on the Windows sign-in screen.

    Must be run from an elevated (Administrator) PowerShell.
    Safe to re-run: if the account already exists nothing is changed.

.PARAMETER UserName
    Name of the local account to create. Defaults to "Ada".

.EXAMPLE
    .\New-StandardUser.ps1
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [string] $UserName = 'Ada',
    [string] $FullName = 'Ada'
)

$ErrorActionPreference = 'Stop'

Write-Host "==> Standard user '$UserName'" -ForegroundColor Yellow

if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
    Write-Host '    Already exists, skipping.' -ForegroundColor DarkGray
    exit 0
}

# --- Prompt for password (entered twice, never echoed) -----------------------
while ($true) {
    $password = Read-Host -Prompt "    Password for '$UserName'" -AsSecureString
    $confirm  = Read-Host -Prompt '    Confirm password' -AsSecureString

    if ($password.Length -eq 0) {
        Write-Host '    Password cannot be empty. Try again.' -ForegroundColor Red
        continue
    }

    $cred1 = New-Object System.Management.Automation.PSCredential ('x', $password)
    $cred2 = New-Object System.Management.Automation.PSCredential ('x', $confirm)
    if ($cred1.GetNetworkCredential().Password -cne $cred2.GetNetworkCredential().Password) {
        Write-Host '    Passwords do not match. Try again.' -ForegroundColor Red
        continue
    }
    break
}

# --- Create the account ------------------------------------------------------
New-LocalUser -Name $UserName `
              -FullName $FullName `
              -Password $password `
              -Description 'Standard (non-administrator) user' `
              -PasswordNeverExpires `
              -AccountNeverExpires | Out-Null

Add-LocalGroupMember -Group 'Users' -Member $UserName
Write-Host '    Created. Member of Users only.' -ForegroundColor Green

# --- Make it the default account on the sign-in screen -----------------------
$sid     = (Get-LocalUser -Name $UserName).SID.Value
$logonUi = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI'
Set-ItemProperty -Path $logonUi -Name 'LastLoggedOnUser'        -Value ".\$UserName" -Type String
Set-ItemProperty -Path $logonUi -Name 'LastLoggedOnSAMUser'     -Value ".\$UserName" -Type String
Set-ItemProperty -Path $logonUi -Name 'LastLoggedOnDisplayName' -Value $FullName     -Type String
Set-ItemProperty -Path $logonUi -Name 'LastLoggedOnUserSID'     -Value $sid          -Type String
Write-Host '    Set as the default account on the sign-in screen.' -ForegroundColor Green
