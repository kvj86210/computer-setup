<#
.SYNOPSIS
    Full machine setup: installs applications, then creates the standard user.

.DESCRIPTION
    Runs, in order:
      1. Install-Apps.ps1      - winget installs
      2. New-StandardUser.ps1  - local "Ada" account (prompts for its password)

    Must be run from an elevated (Administrator) PowerShell.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\Setup.ps1
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [switch] $SkipApps,
    [switch] $SkipUser
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not $SkipApps) {
    & (Join-Path $here 'Install-Apps.ps1')
    if ($LASTEXITCODE -ne 0) {
        Write-Error 'Application install reported failures. Fix those before continuing.'
        exit 1
    }
    Write-Host ''
}

if (-not $SkipUser) {
    & (Join-Path $here 'New-StandardUser.ps1')
}
