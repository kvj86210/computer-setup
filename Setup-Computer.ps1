<#
.SYNOPSIS
    Sets up a fresh Windows machine: installs the standard set of applications
    using winget and creates a standard (non-administrator) user account.

.DESCRIPTION
    Iterates over a list of winget package IDs and installs each one that is not
    already present, then creates the local user account if it does not exist.
    Safe to re-run: anything already present is skipped.

    Must be run from an elevated (Administrator) PowerShell.

.EXAMPLE
    .\Setup-Computer.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\Setup-Computer.ps1
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# --- Applications to install -------------------------------------------------
# Find IDs with:  winget search "<name>"
$Apps = @(
    @{ Name = 'Claude Desktop';  Id = 'Anthropic.Claude' }
    @{ Name = 'Git';             Id = 'Git.Git' }
    @{ Name = 'Google Chrome';   Id = 'Google.Chrome' }
    @{ Name = 'Steam';           Id = 'Valve.Steam' }
    @{ Name = 'Mozilla Firefox'; Id = 'Mozilla.Firefox' }
)

# --- Standard user account to create ----------------------------------------
$UserName = 'Ada'

# --- Preflight ---------------------------------------------------------------
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error 'winget was not found. Install "App Installer" from the Microsoft Store and re-run this script.'
    exit 1
}

Write-Host "Using winget $(winget --version)" -ForegroundColor Cyan
Write-Host ''

# --- Install -----------------------------------------------------------------
$installed = @()
$skipped   = @()
$failed    = @()

foreach ($app in $Apps) {
    Write-Host "==> $($app.Name) [$($app.Id)]" -ForegroundColor Yellow

    $listOutput = winget list --id $app.Id --exact --accept-source-agreements 2>&1 | Out-String
    if ($listOutput -match [regex]::Escape($app.Id)) {
        Write-Host '    Already installed, skipping.' -ForegroundColor DarkGray
        $skipped += $app.Name
        continue
    }

    winget install --id $app.Id --exact --silent `
        --accept-package-agreements --accept-source-agreements

    if ($LASTEXITCODE -eq 0) {
        Write-Host '    Installed.' -ForegroundColor Green
        $installed += $app.Name
    }
    else {
        Write-Host "    Failed (winget exit code $LASTEXITCODE)." -ForegroundColor Red
        $failed += $app.Name
    }
    Write-Host ''
}

# --- Standard user account ---------------------------------------------------
Write-Host "==> User account '$UserName'" -ForegroundColor Yellow
if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
    Write-Host '    Already exists, skipping.' -ForegroundColor DarkGray
}
else {
    $password = Read-Host -Prompt "    Password for '$UserName'" -AsSecureString
    New-LocalUser -Name $UserName -Password $password -PasswordNeverExpires -AccountNeverExpires | Out-Null
    Add-LocalGroupMember -Group 'Users' -Member $UserName
    Write-Host '    Created (standard user, no administrator rights).' -ForegroundColor Green
}
Write-Host ''

# --- Summary -----------------------------------------------------------------
Write-Host '---------------- Summary ----------------' -ForegroundColor Cyan
Write-Host "Installed : $($installed -join ', ')"
Write-Host "Skipped   : $($skipped -join ', ')"
if ($failed.Count -gt 0) {
    Write-Host "Failed    : $($failed -join ', ')" -ForegroundColor Red
    exit 1
}
