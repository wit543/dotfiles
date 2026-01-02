@echo off
REM Windows Dotfiles One-Liner Installer (CMD)
REM Usage: curl -fsSL https://raw.githubusercontent.com/wit543/dotfiles/main/config/windows/install.cmd -o install.cmd && install.cmd && del install.cmd

echo.
echo   ____        _    __ _ _
echo  ^|  _ \  ___ ^| ^|_ / _^(_^) ^| ___  ___
echo  ^| ^| ^| ^|/ _ \^| __^| ^|_^| ^| ^|/ _ \/ __^|
echo  ^| ^|_^| ^| ^(_^) ^| ^|_^|  _^| ^| ^|  __/\__ \
echo  ^|____/ \___/ \__^|_^| ^|_^|_^|\___^|^|___/
echo.
echo   Windows Setup Script (CMD)
echo.

REM Check for PowerShell
where powershell >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: PowerShell is required but not found.
    echo Please install PowerShell or use the PowerShell installer directly.
    pause
    exit /b 1
)

echo This script will run the PowerShell installer.
echo.
echo For best results, run as Administrator.
echo.

REM Run PowerShell installer
powershell -ExecutionPolicy Bypass -Command "& { irm 'https://raw.githubusercontent.com/wit543/dotfiles/main/config/windows/install.ps1' | iex }"

if %ERRORLEVEL% neq 0 (
    echo.
    echo Setup encountered an error. Trying local fallback...
    echo.

    REM Fallback: Run basic setup via PowerShell inline
    powershell -ExecutionPolicy Bypass -Command "& { Write-Host 'Running basic setup...'; powercfg -h off; winget install Google.Chrome --accept-package-agreements --accept-source-agreements --silent; winget install Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements --silent; Write-Host 'Basic setup complete.' }"
)

echo.
echo Setup complete. Press any key to exit.
pause >nul
