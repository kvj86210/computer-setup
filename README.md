# computer-setup

PowerShell script that sets up a fresh Windows machine: installs my standard
applications with [winget](https://learn.microsoft.com/windows/package-manager/winget/)
and creates a standard (non-administrator) local user account named `Ada`.

## Usage

Open PowerShell **as Administrator** and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Setup-Computer.ps1
```

You will be prompted for the new account's password. Everything else is
non-interactive. The script is safe to re-run; anything already present is skipped.

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
