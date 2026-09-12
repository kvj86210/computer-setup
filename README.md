# computer-setup

PowerShell scripts that set up a fresh Windows machine: install my standard
applications with [winget](https://learn.microsoft.com/windows/package-manager/winget/)
and create a standard (non-administrator) user account.

## Usage

Open PowerShell **as Administrator** and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Setup.ps1
```

You will be prompted to enter (and confirm) the password for the new user
account. Everything else is non-interactive.

Use `-SkipApps` or `-SkipUser` to run only one half.

## Scripts

| Script                 | What it does                                                               |
|------------------------|----------------------------------------------------------------------------|
| `Setup.ps1`            | Runs the two scripts below in order.                                       |
| `Install-Apps.ps1`     | Installs the applications listed below. Skips anything already installed. |
| `New-StandardUser.ps1` | Creates the local `Ada` account. Skips if it already exists.               |

All scripts are safe to re-run.

## Applications

| Application     | winget ID          |
|-----------------|--------------------|
| Claude Desktop  | `Anthropic.Claude` |
| Git             | `Git.Git`          |
| Google Chrome   | `Google.Chrome`    |
| Steam           | `Valve.Steam`      |
| Mozilla Firefox | `Mozilla.Firefox`  |

To add one, find its ID and add a line to the `$Apps` array in `Install-Apps.ps1`:

```powershell
winget search "<app name>"
```

## User account

`New-StandardUser.ps1` creates a **local** account named `Ada` (no Microsoft
account) with the password you enter at the prompt. The account is a member of
`Users` only, never `Administrators`, and is preselected on the Windows sign-in
screen so it is the default account after a reboot.
