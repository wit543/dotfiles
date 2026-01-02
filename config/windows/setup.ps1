# Windows Dotfiles Setup Script
# Run as Administrator: powershell -ExecutionPolicy Bypass -File setup.ps1
#
# Usage:
#   .\setup.ps1                      # Full install (all components)
#   .\setup.ps1 -Profile minimal     # Minimal setup (servers)
#   .\setup.ps1 -Profile deploy      # Deploy machine (+ docker)
#   .\setup.ps1 -Profile development # Dev environment (+ editors)
#   .\setup.ps1 -Profile full        # Everything (+ AI tools)
#   .\setup.ps1 -ListProfiles        # Show available profiles
#
# Profiles:
#   minimal     - System tweaks, Git, basic CLI tools
#   deploy      - minimal + Docker, container tools
#   development - deploy + full CLI/TUI tools, VSCode, dev languages
#   full        - development + Claude AI, all extensions

param(
    [ValidateSet("minimal", "deploy", "development", "full")]
    [string]$Profile = "full",

    [switch]$ListProfiles,
    [switch]$Help
)

$ErrorActionPreference = "Continue"

# ============================================================================
# PROFILE DEFINITIONS
# ============================================================================

$Profiles = @{
    minimal = @{
        Description = "Basic setup for servers (system tweaks, git, basic tools)"
        Components = @("system", "bloatware", "telemetry", "git", "cli-basic")
    }
    deploy = @{
        Description = "Deployment machine (minimal + docker, container tools)"
        Components = @("system", "bloatware", "telemetry", "git", "cli-basic", "docker")
    }
    development = @{
        Description = "Development environment (editors, full CLI, languages)"
        Components = @("system", "bloatware", "telemetry", "git", "cli-basic", "cli-full", "tui", "docker", "devtools", "vscode", "apps", "font", "profile")
    }
    full = @{
        Description = "Complete setup (everything + AI assistant)"
        Components = @("system", "bloatware", "telemetry", "git", "cli-basic", "cli-full", "tui", "docker", "devtools", "vscode", "apps", "font", "claude", "profile")
    }
}

# Show help
if ($Help) {
    Write-Host @"
Windows Dotfiles Setup Script

Usage:
  .\setup.ps1                      # Full install (all components)
  .\setup.ps1 -Profile minimal     # Minimal setup (servers)
  .\setup.ps1 -Profile deploy      # Deploy machine (+ docker)
  .\setup.ps1 -Profile development # Dev environment (+ editors)
  .\setup.ps1 -Profile full        # Everything (+ AI tools)
  .\setup.ps1 -ListProfiles        # Show available profiles

Profiles:
  minimal     - System tweaks, Git, basic CLI tools
  deploy      - minimal + Docker, container tools
  development - deploy + full CLI/TUI tools, VSCode, dev languages
  full        - development + Claude AI, all extensions
"@
    exit 0
}

# List profiles
if ($ListProfiles) {
    Write-Host "`nAvailable Profiles:" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor Cyan
    foreach ($name in @("minimal", "deploy", "development", "full")) {
        $p = $Profiles[$name]
        Write-Host "`n  $name" -ForegroundColor Yellow
        Write-Host "    $($p.Description)" -ForegroundColor Gray
        Write-Host "    Components: $($p.Components -join ', ')" -ForegroundColor DarkGray
    }
    Write-Host ""
    exit 0
}

# Get selected profile components
$SelectedComponents = $Profiles[$Profile].Components

function Should-Install {
    param([string]$Component)
    return $SelectedComponents -contains $Component
}

Write-Host @"

  ____        _    __ _ _
 |  _ \  ___ | |_ / _(_) | ___  ___
 | | | |/ _ \| __| |_| | |/ _ \/ __|
 | |_| | (_) | |_|  _| | |  __/\__ \
 |____/ \___/ \__|_| |_|_|\___||___/

  Windows Setup Script

"@ -ForegroundColor Cyan

# ============================================================================
# DETERMINE DOTFILES LOCATION
# ============================================================================
$dotfilesDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not (Test-Path "$dotfilesDir\config")) {
    $dotfilesDir = "$env:USERPROFILE\dotfiles"
}
Write-Host "Dotfiles directory: $dotfilesDir" -ForegroundColor Gray
Write-Host "Profile: $Profile" -ForegroundColor Yellow
Write-Host "Components: $($SelectedComponents -join ', ')" -ForegroundColor Gray

# Check admin status
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "WARNING: Not running as Administrator. Some features will be skipped." -ForegroundColor Yellow
}

# Calculate total steps based on profile
$totalSteps = $SelectedComponents.Count
$currentStep = 0

# ============================================================================
# REMOVE BLOATWARE
# ============================================================================
if (Should-Install "bloatware") {
$currentStep++
Write-Host "`n[$currentStep/$totalSteps] Removing bloatware..." -ForegroundColor Yellow

$bloatwareApps = @(
    # Microsoft bloatware
    "Clipchamp.Clipchamp"
    "Microsoft.3DBuilder"
    "Microsoft.549981C3F5F10"          # Cortana
    "Microsoft.BingFinance"
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingTranslator"
    "Microsoft.BingTravel"
    "Microsoft.BingWeather"
    "Microsoft.Getstarted"              # Tips
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MixedReality.Portal"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.SkypeApp"
    "Microsoft.Todos"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "MicrosoftCorporationII.MicrosoftFamily"
    "MicrosoftCorporationII.QuickAssist"
    "Microsoft.Copilot"
    "Microsoft.Windows.Ai.Copilot.Provider"
    # Third-party bloatware
    "Amazon.com.Amazon"
    "AmazonVideo.PrimeVideo"
    "Disney"
    "Facebook"
    "Instagram"
    "king.com.CandyCrush*"
    "LinkedIn"
    "McAfee"
    "Netflix"
    "Spotify"
    "TikTok"
    "Twitter"
)

$removed = 0
foreach ($app in $bloatwareApps) {
    $packages = Get-AppxPackage -Name "*$app*" -AllUsers -ErrorAction SilentlyContinue
    if ($packages) {
        foreach ($pkg in $packages) {
            Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction SilentlyContinue
            $removed++
        }
    }
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
        Where-Object { $_.PackageName -like "*$app*" } |
        ForEach-Object {
            Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
        }
}
Write-Host "  Removed $removed bloatware apps" -ForegroundColor Green
}

# ============================================================================
# DISABLE TELEMETRY & ADS
# ============================================================================
if (Should-Install "telemetry") {
$currentStep++
Write-Host "`n[$currentStep/$totalSteps] Disabling telemetry and ads..." -ForegroundColor Yellow

# Disable telemetry
if ($isAdmin) {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
}

# Disable advertising ID
New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Type DWord -Force

# Disable Start Menu suggestions/ads
@(
    "SystemPaneSuggestionsEnabled"
    "SubscribedContent-338388Enabled"
    "SubscribedContent-338389Enabled"
    "SubscribedContent-353694Enabled"
    "SubscribedContent-353696Enabled"
    "SoftLandingEnabled"
) | ForEach-Object {
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name $_ -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
}

# Disable Copilot
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force

# Disable Bing in Start Menu search
New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force

Write-Host "  Telemetry, ads, and Copilot disabled" -ForegroundColor Green
}

# ============================================================================
# SYSTEM SETTINGS
# ============================================================================
if (Should-Install "system") {
$currentStep++
Write-Host "`n[$currentStep/$totalSteps] Configuring system settings..." -ForegroundColor Yellow

# Disable hibernate
if ($isAdmin) {
    powercfg -h off 2>&1 | Out-Null
    Write-Host "  Hibernate disabled" -ForegroundColor Green
}

# Cursor: Black, 150% size
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

# Notify system of cursor change
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class CursorChanger {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
}
"@ -ErrorAction SilentlyContinue
[CursorChanger]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0x03) | Out-Null

Write-Host "  Cursor set to black, 150% size" -ForegroundColor Green
}

# ============================================================================
# INSTALL CORE CLI TOOLS (Basic - for all profiles)
# ============================================================================
if (Should-Install "cli-basic") {
$currentStep++
Write-Host "`n[$currentStep/$totalSteps] Installing basic CLI tools..." -ForegroundColor Yellow

# Basic tools for minimal profile
$basicTools = @(
    @{ id = "Git.Git"; name = "Git" }
    @{ id = "junegunn.fzf"; name = "fzf" }
    @{ id = "BurntSushi.ripgrep.MSVC"; name = "ripgrep" }
)

foreach ($tool in $basicTools) {
    $installed = winget list --id $tool.id 2>&1 | Select-String $tool.id
    if (-not $installed) {
        Write-Host "  Installing $($tool.name)..." -NoNewline
        winget install $tool.id --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host "  $($tool.name) already installed" -ForegroundColor Gray
    }
}
}

# ============================================================================
# INSTALL FULL CLI TOOLS (for development/full profiles)
# ============================================================================
if (Should-Install "cli-full") {
$currentStep++
Write-Host "`n[$currentStep/$totalSteps] Installing full CLI tools..." -ForegroundColor Yellow

# Core tools (equivalent to Brewfile)
$coreTools = @(
    @{ id = "Git.Git"; name = "Git" }
    @{ id = "Neovim.Neovim"; name = "Neovim" }
    @{ id = "junegunn.fzf"; name = "fzf" }
    @{ id = "BurntSushi.ripgrep.MSVC"; name = "ripgrep" }
    @{ id = "sharkdp.fd"; name = "fd" }
    @{ id = "sharkdp.bat"; name = "bat" }
    @{ id = "eza-community.eza"; name = "eza" }
    @{ id = "dandavison.delta"; name = "delta" }
    @{ id = "ajeetdsouza.zoxide"; name = "zoxide" }
    @{ id = "Starship.Starship"; name = "Starship" }
    @{ id = "jqlang.jq"; name = "jq" }
    @{ id = "mikefarah.yq"; name = "yq" }
    @{ id = "tldr-pages.tlrc"; name = "tldr" }
    @{ id = "bootandy.dust"; name = "dust" }
)

foreach ($tool in $coreTools) {
    $installed = winget list --id $tool.id 2>&1 | Select-String $tool.id
    if (-not $installed) {
        Write-Host "  Installing $($tool.name)..." -NoNewline
        winget install $tool.id --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host "  $($tool.name) already installed" -ForegroundColor Gray
    }
}
}

# ============================================================================
# INSTALL TUI PRODUCTIVITY TOOLS
# ============================================================================
if (Should-Install "tui") {
$currentStep++
Write-Host "`n[$currentStep/$totalSteps] Installing TUI productivity tools..." -ForegroundColor Yellow

$tuiTools = @(
    @{ id = "JesseDuffield.lazygit"; name = "lazygit" }
    @{ id = "JesseDuffield.lazydocker"; name = "lazydocker" }
    @{ id = "aristocratos.btop4win"; name = "btop" }
)

foreach ($tool in $tuiTools) {
    $installed = winget list --id $tool.id 2>&1 | Select-String $tool.id
    if (-not $installed) {
        Write-Host "  Installing $($tool.name)..." -NoNewline
        winget install $tool.id --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host "  $($tool.name) already installed" -ForegroundColor Gray
    }
}
}

# ============================================================================
# INSTALL DEVELOPMENT TOOLS
# ============================================================================
if (Should-Install "devtools") {
$currentStep++
Write-Host "`n[$currentStep/$totalSteps] Installing development tools..." -ForegroundColor Yellow

$devTools = @(
    @{ id = "OpenJS.NodeJS.LTS"; name = "Node.js" }
    @{ id = "Python.Python.3.12"; name = "Python 3.12" }
    @{ id = "GoLang.Go"; name = "Go" }
    @{ id = "Docker.DockerDesktop"; name = "Docker Desktop" }
)

foreach ($tool in $devTools) {
    $installed = winget list --id $tool.id 2>&1 | Select-String $tool.id
    if (-not $installed) {
        Write-Host "  Installing $($tool.name)..." -NoNewline
        winget install $tool.id --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host "  $($tool.name) already installed" -ForegroundColor Gray
    }
}
}

# ============================================================================
# INSTALL APPLICATIONS
# ============================================================================
if (Should-Install "apps") {
$currentStep++
Write-Host "`n[$currentStep/$totalSteps] Installing applications..." -ForegroundColor Yellow

$apps = @(
    @{ id = "Google.Chrome"; name = "Chrome" }
    @{ id = "Microsoft.VisualStudioCode"; name = "VSCode" }
    @{ id = "Microsoft.WindowsTerminal"; name = "Windows Terminal" }
)

foreach ($app in $apps) {
    $installed = winget list --id $app.id 2>&1 | Select-String $app.id
    if (-not $installed) {
        Write-Host "  Installing $($app.name)..." -NoNewline
        winget install $app.id --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host "  $($app.name) already installed" -ForegroundColor Gray
    }
}

# Set Chrome as default browser
$chromeProgId = 'ChromeHTML'
@('http', 'https') | ForEach-Object {
    $regKey = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\$_\UserChoice"
    if (Test-Path $regKey) {
        Set-ItemProperty -Path $regKey -Name 'ProgId' -Value $chromeProgId -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "  Chrome set as default browser" -ForegroundColor Green
}

# ============================================================================
# INSTALL NERD FONT
# ============================================================================
if (Should-Install "font") {
$currentStep++
Write-Host "`n[$currentStep/$totalSteps] Installing Nerd Font..." -ForegroundColor Yellow

# Download and install MesloLGS NF (for Starship icons)
$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip"
$fontZip = "$env:TEMP\Meslo.zip"
$fontDir = "$env:TEMP\Meslo"
$fontsFolder = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

if (-not (Test-Path "$fontsFolder\MesloLGSNerdFont-Regular.ttf")) {
    Write-Host "  Downloading MesloLGS Nerd Font..." -NoNewline
    try {
        Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip -UseBasicParsing
        Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force

        # Create fonts folder if needed
        if (-not (Test-Path $fontsFolder)) {
            New-Item -ItemType Directory -Path $fontsFolder -Force | Out-Null
        }

        # Install fonts
        Get-ChildItem "$fontDir\*.ttf" | ForEach-Object {
            Copy-Item $_.FullName $fontsFolder -Force
            # Register font in registry
            $fontName = $_.BaseName
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "$fontName (TrueType)" -Value $_.FullName -Force
        }

        Remove-Item $fontZip -Force -ErrorAction SilentlyContinue
        Remove-Item $fontDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " FAILED" -ForegroundColor Red
    }
} else {
    Write-Host "  MesloLGS Nerd Font already installed" -ForegroundColor Gray
}
}

# ============================================================================
# DEPLOY GIT CONFIG
# ============================================================================
if (Should-Install "git") {
$currentStep++
Write-Host "`n[$currentStep/$totalSteps] Deploying Git configuration..." -ForegroundColor Yellow

$gitConfigSrc = "$dotfilesDir\config\git\.gitconfig"
$gitIgnoreSrc = "$dotfilesDir\config\git\.gitignore_global"
$gitConfigDest = "$env:USERPROFILE\.gitconfig"
$gitIgnoreDest = "$env:USERPROFILE\.gitignore_global"

if (Test-Path $gitConfigSrc) {
    Copy-Item -Path $gitConfigSrc -Destination $gitConfigDest -Force
    Write-Host "  .gitconfig deployed" -ForegroundColor Green
} else {
    Write-Host "  .gitconfig not found in dotfiles" -ForegroundColor Yellow
}

if (Test-Path $gitIgnoreSrc) {
    Copy-Item -Path $gitIgnoreSrc -Destination $gitIgnoreDest -Force
    Write-Host "  .gitignore_global deployed" -ForegroundColor Green
}
}

# ============================================================================
# DEPLOY STARSHIP CONFIG (part of cli-full)
# ============================================================================
if (Should-Install "cli-full") {
Write-Host "`nDeploying Starship configuration..." -ForegroundColor Yellow

$starshipSrc = "$dotfilesDir\config\zsh\starship.toml"
$starshipDest = "$env:USERPROFILE\.config\starship.toml"

if (Test-Path $starshipSrc) {
    # Create .config directory if needed
    $starshipDir = Split-Path $starshipDest
    if (-not (Test-Path $starshipDir)) {
        New-Item -ItemType Directory -Path $starshipDir -Force | Out-Null
    }
    Copy-Item -Path $starshipSrc -Destination $starshipDest -Force
    Write-Host "  starship.toml deployed" -ForegroundColor Green
} else {
    Write-Host "  starship.toml not found in dotfiles" -ForegroundColor Yellow
}
}

# ============================================================================
# DEPLOY VSCODE CONFIG & EXTENSIONS
# ============================================================================
if (Should-Install "vscode") {
$currentStep++
Write-Host "`n[$currentStep/$totalSteps] Deploying VSCode configuration..." -ForegroundColor Yellow

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$vscodeUserDir = "$env:APPDATA\Code\User"
$settingsSrc = "$dotfilesDir\config\vscode\settings.json"
$keybindingsSrc = "$dotfilesDir\config\vscode\keybindings.json"
$extensionsSrc = "$dotfilesDir\config\vscode\extensions.txt"

# Create VSCode User directory if needed
if (-not (Test-Path $vscodeUserDir)) {
    New-Item -ItemType Directory -Path $vscodeUserDir -Force | Out-Null
}

# Copy settings
if (Test-Path $settingsSrc) {
    Copy-Item -Path $settingsSrc -Destination "$vscodeUserDir\settings.json" -Force
    Write-Host "  settings.json deployed" -ForegroundColor Green
}

if (Test-Path $keybindingsSrc) {
    Copy-Item -Path $keybindingsSrc -Destination "$vscodeUserDir\keybindings.json" -Force
    Write-Host "  keybindings.json deployed" -ForegroundColor Green
}

# Install extensions
$codePath = "code"
$possiblePaths = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
    "C:\Program Files\Microsoft VS Code\bin\code.cmd"
)
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $codePath = $path
        break
    }
}

if (Test-Path $extensionsSrc) {
    $extensions = Get-Content $extensionsSrc | Where-Object {
        $_ -and ($_ -notmatch '^\s*#') -and ($_.Trim() -ne '')
    } | ForEach-Object {
        ($_ -split '#')[0].Trim()
    } | Where-Object { $_ }

    $total = $extensions.Count
    $current = 0

    foreach ($ext in $extensions) {
        $current++
        Write-Host "  [$current/$total] Installing $ext..." -NoNewline
        & $codePath --install-extension $ext --force 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host " OK" -ForegroundColor Green
        } else {
            Write-Host " SKIP" -ForegroundColor Yellow
        }
    }
}
}

# ============================================================================
# DEPLOY CLAUDE CODE CONFIG
# ============================================================================
if (Should-Install "claude") {
$currentStep++
Write-Host "`n[$currentStep/$totalSteps] Deploying Claude Code configuration..." -ForegroundColor Yellow

$claudeSettingsSrc = "$dotfilesDir\config\claude\settings.json"
$claudeMdSrc = "$dotfilesDir\config\claude\CLAUDE.md"

# Claude Code CLI config location (user-level)
$claudeCliDir = "$env:APPDATA\claude-code"
# VSCode extension config location
$claudeVscodeDir = "$env:USERPROFILE\.claude"

# Create directories
@($claudeCliDir, $claudeVscodeDir) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

# Deploy to Claude Code CLI (user-level)
if (Test-Path $claudeSettingsSrc) {
    Copy-Item -Path $claudeSettingsSrc -Destination "$claudeCliDir\settings.json" -Force
    Write-Host "  CLI settings deployed to $claudeCliDir" -ForegroundColor Green
}

# Deploy to VSCode extension / global Claude location
if (Test-Path $claudeSettingsSrc) {
    Copy-Item -Path $claudeSettingsSrc -Destination "$claudeVscodeDir\settings.json" -Force
    Write-Host "  VSCode extension settings deployed to $claudeVscodeDir" -ForegroundColor Green
}

# Deploy CLAUDE.md (global coding standards)
if (Test-Path $claudeMdSrc) {
    Copy-Item -Path $claudeMdSrc -Destination "$claudeVscodeDir\CLAUDE.md" -Force
    Write-Host "  CLAUDE.md deployed to $claudeVscodeDir" -ForegroundColor Green
}

Write-Host "  Claude Code configured with WebSearch, WebFetch, and MCP permissions" -ForegroundColor Green

# Install Claude Code CLI
Write-Host "  Installing Claude Code CLI..." -ForegroundColor Yellow

# Check if npm is available (installed with Node.js)
$npmPath = Get-Command npm -ErrorAction SilentlyContinue
if ($npmPath) {
    $claudeInstalled = npm list -g @anthropic-ai/claude-code 2>&1 | Select-String "@anthropic-ai/claude-code"
    if (-not $claudeInstalled) {
        Write-Host "  Installing @anthropic-ai/claude-code globally..." -NoNewline
        npm install -g @anthropic-ai/claude-code 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host " OK" -ForegroundColor Green
        } else {
            Write-Host " SKIP (may need to install manually)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  Claude Code CLI already installed" -ForegroundColor Gray
    }
} else {
    Write-Host "  npm not found, skipping Claude Code CLI installation" -ForegroundColor Yellow
    Write-Host "  Install manually: npm install -g @anthropic-ai/claude-code" -ForegroundColor Gray
}
}

# ============================================================================
# CONFIGURE POWERSHELL PROFILE
# ============================================================================
if (Should-Install "profile") {
$currentStep++
Write-Host "`n[$currentStep/$totalSteps] Configuring PowerShell profile..." -ForegroundColor Yellow

$profileContent = @'
# ============================================================================
#                         POWERSHELL PROFILE
#                    Generated by dotfiles setup
# ============================================================================

# Initialize Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Initialize zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ============================================================================
# ALIASES (matching macOS/Linux dotfiles)
# ============================================================================

# Modern CLI replacements
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Set-Alias -Name ls -Value eza -Option AllScope
    function ll { eza -lah --git --icons @args }
    function lt { eza --tree --level=2 --icons @args }
    function la { eza -a --icons @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name cat -Value bat -Option AllScope
}

if (Get-Command fd -ErrorAction SilentlyContinue) {
    Set-Alias -Name f -Value fd -Option AllScope
}

if (Get-Command rg -ErrorAction SilentlyContinue) {
    Set-Alias -Name grep -Value rg -Option AllScope
}

# TUI tools
if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Set-Alias -Name lg -Value lazygit
}

if (Get-Command lazydocker -ErrorAction SilentlyContinue) {
    Set-Alias -Name lzd -Value lazydocker
}

# Git aliases
function gs { git status @args }
function ga { git add @args }
function gc { git commit @args }
function gp { git push @args }
function gl { git pull @args }
function gd { git diff @args }
function gco { git checkout @args }
function gbr { git branch @args }
function glg { git log --oneline --graph --decorate @args }

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Directory shortcuts
function home { Set-Location $env:USERPROFILE }
function docs { Set-Location "$env:USERPROFILE\Documents" }
function dl { Set-Location "$env:USERPROFILE\Downloads" }
function dev { Set-Location "$env:USERPROFILE\dev" }

# Utility functions
function mkcd { param($dir) New-Item -ItemType Directory -Path $dir -Force; Set-Location $dir }
function which { param($cmd) Get-Command $cmd -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition }
function touch { param($file) if (Test-Path $file) { (Get-Item $file).LastWriteTime = Get-Date } else { New-Item $file -ItemType File } }

# FZF integration
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        $env:FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git"
    }
}

# ============================================================================
# END OF PROFILE
# ============================================================================
'@

$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

Set-Content -Path $PROFILE -Value $profileContent -Force
Write-Host "  PowerShell profile configured at $PROFILE" -ForegroundColor Green
}

# ============================================================================
# SUMMARY
# ============================================================================

# Build summary based on installed components
$installedComponents = @()
$configuredItems = @()

if (Should-Install "cli-basic") { $installedComponents += "git, fzf, ripgrep" }
if (Should-Install "cli-full") { $installedComponents += "neovim, fd, bat, eza, delta, zoxide, starship, jq, yq, tldr, dust" }
if (Should-Install "tui") { $installedComponents += "lazygit, lazydocker, btop" }
if (Should-Install "devtools") { $installedComponents += "Node.js, Python, Go, Docker Desktop" }
if (Should-Install "apps") { $installedComponents += "Chrome, VSCode, Windows Terminal" }
if (Should-Install "font") { $installedComponents += "MesloLGS Nerd Font" }
if (Should-Install "claude") { $installedComponents += "Claude Code CLI" }

if (Should-Install "bloatware") { $configuredItems += "Bloatware removed" }
if (Should-Install "telemetry") { $configuredItems += "Telemetry & ads disabled" }
if (Should-Install "system") { $configuredItems += "System settings (hibernate, cursor)" }
if (Should-Install "git") { $configuredItems += "Git config deployed" }
if (Should-Install "cli-full") { $configuredItems += "Starship prompt deployed" }
if (Should-Install "vscode") { $configuredItems += "VSCode settings & extensions" }
if (Should-Install "claude") { $configuredItems += "Claude Code configured" }
if (Should-Install "profile") { $configuredItems += "PowerShell profile with aliases" }

Write-Host @"

=== Setup Complete ===

Profile: $Profile
Components: $($SelectedComponents -join ', ')

"@ -ForegroundColor Cyan

if ($installedComponents.Count -gt 0) {
    Write-Host "Installed:" -ForegroundColor Cyan
    foreach ($item in $installedComponents) {
        Write-Host "  - $item" -ForegroundColor Gray
    }
    Write-Host ""
}

if ($configuredItems.Count -gt 0) {
    Write-Host "Configured:" -ForegroundColor Cyan
    foreach ($item in $configuredItems) {
        Write-Host "  - $item" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host @"
Next steps:
  1. Restart terminal (or run: . `$PROFILE)
  2. Set Windows Terminal font to "MesloLGS Nerd Font"
  3. Restart for all changes to take effect

"@ -ForegroundColor Cyan
