# computer-setup

PowerShell script that sets up a fresh Windows machine: installs my standard
applications with [winget](https://learn.microsoft.com/windows/package-manager/winget/)
and creates two local user accounts: `Ada` (standard user) and `dad`
(administrator).

## Usage

Open PowerShell **as Administrator** and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Setup-Computer.ps1
```

You will be prompted for each new account's password. Everything else is
non-interactive. The script is safe to re-run; anything already present is skipped.

The first sign-in setup screens (privacy questions and the "getting things
ready" animation) are disabled machine-wide, so new accounts land straight on
the desktop.

## Applications

| Application     | winget ID          |
|-----------------|--------------------|
| Claude Desktop  | `Anthropic.Claude` |
| Git             | `Git.Git`          |
| Google Chrome   | `Google.Chrome`    |
| Steam           | `Valve.Steam`      |
| Mozilla Firefox | `Mozilla.Firefox`  |

To add one, find its ID and add a line to the `$Apps` array in `Setup-Computer.ps1`:

```powershell
winget search "<app name>"
```
