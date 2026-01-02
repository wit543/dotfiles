# Windows Dotfiles One-Liner Installer
# Usage: irm https://raw.githubusercontent.com/wit543/dotfiles/main/config/windows/install.ps1 | iex
#
# This script:
# 1. Clones/updates the dotfiles repo
# 2. Runs the setup script
# 3. Applies all Windows configurations

$ErrorActionPreference = "Stop"

# ============================================================================
# BANNER
# ============================================================================
Write-Host @"

  ____        _    __ _ _
 |  _ \  ___ | |_ / _(_) | ___  ___
 | | | |/ _ \| __| |_| | |/ _ \/ __|
 | |_| | (_) | |_|  _| | |  __/\__ \
 |____/ \___/ \__|_| |_|_|\___||___/

  Windows Setup Script

"@ -ForegroundColor Cyan

# ============================================================================
# CHECK ADMIN (some features require it)
# ============================================================================
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Note: Running without admin rights. Some features may be limited." -ForegroundColor Yellow
    Write-Host "For full setup, run: Start-Process powershell -Verb RunAs -ArgumentList '-c irm <url> | iex'" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================================
# CONFIGURATION
# ============================================================================
$dotfilesRepo = "https://github.com/wit543/dotfiles.git"
$dotfilesDir = "$env:USERPROFILE\dotfiles"

# ============================================================================
# CLONE OR UPDATE DOTFILES
# ============================================================================
Write-Host "[1/2] Setting up dotfiles repository..." -ForegroundColor Yellow

if (Test-Path "$dotfilesDir\.git") {
    Write-Host "  Updating existing dotfiles..." -ForegroundColor Gray
    Push-Location $dotfilesDir
    git pull --rebase 2>&1 | Out-Null
    Pop-Location
    Write-Host "  Dotfiles updated" -ForegroundColor Green
} elseif (Test-Path $dotfilesDir) {
    Write-Host "  Dotfiles directory exists but is not a git repo" -ForegroundColor Yellow
    Write-Host "  Skipping clone, using existing files" -ForegroundColor Yellow
} else {
    Write-Host "  Cloning dotfiles repository..." -ForegroundColor Gray
    git clone $dotfilesRepo $dotfilesDir 2>&1 | Out-Null
    if ($?) {
        Write-Host "  Dotfiles cloned" -ForegroundColor Green
    } else {
        Write-Host "  Failed to clone. Downloading setup script directly..." -ForegroundColor Yellow
        # Fallback: just run the setup inline
    }
}

# ============================================================================
# RUN SETUP
# ============================================================================
Write-Host "`n[2/2] Running setup..." -ForegroundColor Yellow

$setupScript = "$dotfilesDir\config\windows\setup.ps1"

if (Test-Path $setupScript) {
    & $setupScript
} else {
    Write-Host "  Setup script not found, running inline setup..." -ForegroundColor Yellow

    # ========================================================================
    # INLINE SETUP (fallback if repo not available)
    # ========================================================================

    # --- Disable Hibernate ---
    Write-Host "`n  Disabling hibernate..." -ForegroundColor Gray
    if ($isAdmin) {
        powercfg -h off 2>&1 | Out-Null
        Write-Host "    Hibernate disabled" -ForegroundColor Green
    } else {
        Write-Host "    Skipped (requires admin)" -ForegroundColor Yellow
    }

    # --- Cursor Settings ---
    Write-Host "  Setting cursor to black, 150% size..." -ForegroundColor Gray
    $cursorSize = 48
    $cursorPath = "C:\Windows\Cursors"
    $regPath = "HKCU:\Control Panel\Cursors"

    $cursors = @{
        "Arrow"       = "aero_arrow_l.cur"
        "Help"        = "aero_helpsel_l.cur"
        "AppStarting" = "aero_working_l.ani"
        "Wait"        = "aero_busy_l.ani"
        "Crosshair"   = "cross_l.cur"
        "IBeam"       = "beam_l.cur"
        "NWPen"       = "aero_pen_l.cur"
        "No"          = "aero_unavail_l.cur"
        "SizeNS"      = "aero_ns_l.cur"
        "SizeWE"      = "aero_ew_l.cur"
        "SizeNWSE"    = "aero_nwse_l.cur"
        "SizeNESW"    = "aero_nesw_l.cur"
        "SizeAll"     = "aero_move_l.cur"
        "UpArrow"     = "aero_up_l.cur"
        "Hand"        = "aero_link_l.cur"
    }

    foreach ($cursor in $cursors.GetEnumerator()) {
        $fullPath = Join-Path $cursorPath $cursor.Value
        if (Test-Path $fullPath) {
            Set-ItemProperty -Path $regPath -Name $cursor.Key -Value $fullPath -ErrorAction SilentlyContinue
        }
    }

    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Accessibility" -Name "CursorSize" -Value 3 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "CursorBaseSize" -Value $cursorSize -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $regPath -Name "(Default)" -Value "Windows Black (large)" -ErrorAction SilentlyContinue

    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class CursorChanger {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
}
"@
    [CursorChanger]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0x03) | Out-Null
    Write-Host "    Cursor configured" -ForegroundColor Green

    # --- Install Chrome ---
    Write-Host "  Installing Chrome..." -ForegroundColor Gray
    $chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    if (-not (Test-Path $chromePath)) {
        winget install Google.Chrome --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
        Write-Host "    Chrome installed" -ForegroundColor Green
    } else {
        Write-Host "    Chrome already installed" -ForegroundColor Green
    }

    # --- Install VSCode ---
    Write-Host "  Installing VSCode..." -ForegroundColor Gray
    $vscodePath = "C:\Program Files\Microsoft VS Code\Code.exe"
    if (-not (Test-Path $vscodePath)) {
        winget install Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
        Write-Host "    VSCode installed" -ForegroundColor Green
    } else {
        Write-Host "    VSCode already installed" -ForegroundColor Green
    }
}

# ============================================================================
# COMPLETE
# ============================================================================
Write-Host @"

=== Setup Complete ===

Changes applied:
  - Hibernate: Disabled
  - Cursor: Black, 150% size
  - Chrome: Installed
  - VSCode: Installed

Note: Sign out or restart for all changes to take effect.

"@ -ForegroundColor Cyan
