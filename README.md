# computer-setup

PowerShell script that installs my standard set of applications on a fresh Windows machine using [winget](https://learn.microsoft.com/windows/package-manager/winget/).

## Applications

| Application     | winget ID          |
|-----------------|--------------------|
| Claude Desktop  | `Anthropic.Claude` |
| Git             | `Git.Git`          |
| Google Chrome   | `Google.Chrome`    |
| Steam           | `Valve.Steam`      |
| Mozilla Firefox | `Mozilla.Firefox`  |

## Usage

Open PowerShell and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Install-Apps.ps1
```

The script is safe to re-run. Anything already installed is skipped.

## Adding an application

Find the package ID, then add a line to the `$Apps` array in `Install-Apps.ps1`:

```powershell
winget search "<app name>"
```
