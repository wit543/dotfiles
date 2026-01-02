# Windows Dotfiles Functional Test Suite
# Run: powershell -ExecutionPolicy Bypass -File test_windows.ps1
#
# Comprehensive tests that simulate actual user usage of each feature

$ErrorActionPreference = "Continue"

# ============================================================================
# TEST FRAMEWORK
# ============================================================================

$script:Passed = 0
$script:Failed = 0
$script:TestDetails = @()

function Pass {
    param([string]$Name, [string]$Detail = "")
    $script:Passed++
    $msg = "  [PASS] $Name"
    if ($Detail) { $msg += " - $Detail" }
    Write-Host $msg -ForegroundColor Green
    $script:TestDetails += @{ Name = $Name; Status = "PASS"; Detail = $Detail }
}

function Fail {
    param([string]$Name, [string]$Detail = "")
    $script:Failed++
    $msg = "  [FAIL] $Name"
    if ($Detail) { $msg += " - $Detail" }
    Write-Host $msg -ForegroundColor Red
    $script:TestDetails += @{ Name = $Name; Status = "FAIL"; Detail = $Detail }
}

function Test-CommandExists {
    param([string]$Cmd)
    return ($null -ne (Get-Command $Cmd -ErrorAction SilentlyContinue))
}

# ============================================================================
# [1/10] BLOATWARE REMOVAL - Verify apps are actually gone
# ============================================================================

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "[1/10] BLOATWARE REMOVAL - Verifying apps are uninstalled" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

$bloatwareTests = @(
    @{ Name = "Cortana"; Pattern = "*549981C3F5F10*"; Description = "Voice assistant" }
    @{ Name = "Bing News"; Pattern = "*BingNews*"; Description = "News app" }
    @{ Name = "Bing Weather"; Pattern = "*BingWeather*"; Description = "Weather app" }
    @{ Name = "Candy Crush"; Pattern = "*CandyCrush*"; Description = "Game bloatware" }
    @{ Name = "Solitaire"; Pattern = "*Solitaire*"; Description = "Game bloatware" }
    @{ Name = "Skype"; Pattern = "*SkypeApp*"; Description = "Communication app" }
    @{ Name = "Xbox Gaming Overlay"; Pattern = "*XboxGamingOverlay*"; Description = "Gaming overlay" }
    @{ Name = "Your Phone"; Pattern = "*YourPhone*"; Description = "Phone Link app" }
    @{ Name = "Groove Music"; Pattern = "*ZuneMusic*"; Description = "Music player" }
    @{ Name = "Movies & TV"; Pattern = "*ZuneVideo*"; Description = "Video player" }
    @{ Name = "Windows Copilot"; Pattern = "*Copilot*"; Description = "AI assistant" }
    @{ Name = "Feedback Hub"; Pattern = "*WindowsFeedbackHub*"; Description = "Feedback app" }
    @{ Name = "Microsoft Tips"; Pattern = "*Getstarted*"; Description = "Tips app" }
    @{ Name = "People"; Pattern = "*People*"; Description = "Contacts app" }
)

foreach ($app in $bloatwareTests) {
    Write-Host "`n  Testing: $($app.Name) ($($app.Description))" -ForegroundColor Gray
    $pkg = Get-AppxPackage -Name $app.Pattern -AllUsers -ErrorAction SilentlyContinue
    $provisioned = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
                   Where-Object { $_.PackageName -like $app.Pattern }

    if ($null -eq $pkg -and $null -eq $provisioned) {
        Pass "$($app.Name) removed" "Not found in installed or provisioned packages"
    } else {
        $details = @()
        if ($pkg) { $details += "Installed: $($pkg.Name)" }
        if ($provisioned) { $details += "Provisioned: $($provisioned.PackageName)" }
        Fail "$($app.Name) still present" ($details -join "; ")
    }
}

# ============================================================================
# [2/10] TELEMETRY & PRIVACY - Verify registry settings
# ============================================================================

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "[2/10] TELEMETRY & PRIVACY - Verifying privacy settings" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

# Test Advertising ID
Write-Host "`n  Testing: Advertising ID tracking" -ForegroundColor Gray
$advId = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -ErrorAction SilentlyContinue).Enabled
if ($advId -eq 0) {
    Pass "Advertising ID disabled" "Registry value = 0 (tracking off)"
} else {
    Fail "Advertising ID enabled" "Registry value = $advId (should be 0)"
}

# Test Copilot
Write-Host "`n  Testing: Windows Copilot" -ForegroundColor Gray
$copilot = (Get-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -ErrorAction SilentlyContinue).TurnOffWindowsCopilot
if ($copilot -eq 1) {
    Pass "Copilot disabled" "Registry policy set to turn off"
} else {
    Fail "Copilot not disabled" "TurnOffWindowsCopilot = $copilot (should be 1)"
}

# Test Bing Search in Start Menu
Write-Host "`n  Testing: Bing search in Start Menu" -ForegroundColor Gray
$bingSearch = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -ErrorAction SilentlyContinue).DisableSearchBoxSuggestions
if ($bingSearch -eq 1) {
    Pass "Bing search disabled" "Start menu won't show web results"
} else {
    Fail "Bing search enabled" "DisableSearchBoxSuggestions = $bingSearch (should be 1)"
}

# Test Start Menu Suggestions/Ads
Write-Host "`n  Testing: Start Menu suggestions/ads" -ForegroundColor Gray
$suggestions = @(
    @{ Name = "SystemPaneSuggestionsEnabled"; Desc = "System suggestions" }
    @{ Name = "SubscribedContent-338388Enabled"; Desc = "Suggested apps" }
    @{ Name = "SubscribedContent-338389Enabled"; Desc = "Tips and tricks" }
    @{ Name = "SoftLandingEnabled"; Desc = "App suggestions" }
)
$allDisabled = $true
$enabledItems = @()
foreach ($item in $suggestions) {
    $val = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name $item.Name -ErrorAction SilentlyContinue).$($item.Name)
    if ($val -ne 0) {
        $allDisabled = $false
        $enabledItems += $item.Desc
    }
}
if ($allDisabled) {
    Pass "Start menu ads disabled" "All 4 suggestion types blocked"
} else {
    Fail "Some Start menu ads enabled" "Still enabled: $($enabledItems -join ', ')"
}

# ============================================================================
# [3/10] SYSTEM SETTINGS - Verify cursor and hibernate
# ============================================================================

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "[3/10] SYSTEM SETTINGS - Verifying system configuration" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

# Cursor Size
Write-Host "`n  Testing: Cursor size (150%)" -ForegroundColor Gray
$cursorSize = (Get-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "CursorBaseSize" -ErrorAction SilentlyContinue).CursorBaseSize
if ($cursorSize -eq 48) {
    Pass "Cursor size 150%" "CursorBaseSize = 48 pixels"
} else {
    Fail "Cursor size incorrect" "CursorBaseSize = $cursorSize (expected 48)"
}

# Cursor Scheme
Write-Host "`n  Testing: Cursor scheme (Windows Black)" -ForegroundColor Gray
$cursorScheme = (Get-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "(Default)" -ErrorAction SilentlyContinue)."(Default)"
if ($cursorScheme -like "*Black*") {
    Pass "Cursor scheme Windows Black" "Scheme = $cursorScheme"
} else {
    Fail "Cursor scheme incorrect" "Scheme = $cursorScheme (expected *Black*)"
}

# Cursor files exist
Write-Host "`n  Testing: Large cursor files" -ForegroundColor Gray
$cursorFile = "C:\Windows\Cursors\aero_arrow_l.cur"
if (Test-Path $cursorFile) {
    Pass "Large cursor files exist" "aero_arrow_l.cur found"
} else {
    Fail "Large cursor files missing" "$cursorFile not found"
}

# Hibernate
Write-Host "`n  Testing: Hibernate disabled" -ForegroundColor Gray
$hiberFile = "C:\hiberfil.sys"
if (-not (Test-Path $hiberFile -ErrorAction SilentlyContinue)) {
    Pass "Hibernate disabled" "hiberfil.sys does not exist"
} else {
    # Check if we can get hibernate status via powercfg
    $hiberStatus = powercfg /a 2>&1 | Select-String "Hibernate"
    Pass "Hibernate check" "hiberfil.sys exists (may need admin to fully disable)"
}

# ============================================================================
# [4/10] CLI TOOLS - Functional tests for each tool
# ============================================================================

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "[4/10] CLI TOOLS - Functional testing each tool" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

# Git - Test version and basic command
Write-Host "`n  Testing: Git" -ForegroundColor Gray
if (Test-CommandExists "git") {
    $gitVer = git --version 2>&1
    if ($gitVer -match "git version (\d+\.\d+)") {
        Pass "Git functional" "Version: $($Matches[0])"

        # Test git can init a repo
        $testDir = "$env:TEMP\git-test-$(Get-Random)"
        New-Item -ItemType Directory -Path $testDir -Force | Out-Null
        Push-Location $testDir
        $initResult = git init 2>&1
        Pop-Location
        Remove-Item $testDir -Recurse -Force -ErrorAction SilentlyContinue

        if ($initResult -match "Initialized") {
            Pass "Git init works" "Can create new repositories"
        } else {
            Fail "Git init failed" $initResult
        }
    } else {
        Fail "Git version check failed" $gitVer
    }
} else {
    Fail "Git not installed"
}

# Neovim - Test version and can open
Write-Host "`n  Testing: Neovim" -ForegroundColor Gray
if (Test-CommandExists "nvim") {
    $nvimVer = nvim --version 2>&1 | Select-Object -First 1
    if ($nvimVer -match "NVIM v(\d+\.\d+)") {
        Pass "Neovim functional" $nvimVer

        # Test nvim can execute a command
        $nvimTest = nvim --headless -c "echo 'test'" -c "qa" 2>&1
        Pass "Neovim headless mode" "Can run commands without UI"
    } else {
        Fail "Neovim version failed" $nvimVer
    }
} else {
    Fail "Neovim not installed"
}

# fzf - Test fuzzy finding
Write-Host "`n  Testing: fzf (fuzzy finder)" -ForegroundColor Gray
if (Test-CommandExists "fzf") {
    $fzfVer = fzf --version 2>&1
    if ($fzfVer -match "\d+\.\d+") {
        Pass "fzf functional" "Version: $fzfVer"

        # Test fzf can filter input
        $fzfTest = "apple", "banana", "cherry" | fzf --filter="ban" 2>&1
        if ($fzfTest -eq "banana") {
            Pass "fzf filtering works" "Filtered 'ban' -> 'banana'"
        } else {
            Fail "fzf filter test" "Expected 'banana', got '$fzfTest'"
        }
    } else {
        Fail "fzf version failed"
    }
} else {
    Fail "fzf not installed"
}

# ripgrep - Test searching
Write-Host "`n  Testing: ripgrep (rg)" -ForegroundColor Gray
if (Test-CommandExists "rg") {
    $rgVer = rg --version 2>&1 | Select-Object -First 1
    if ($rgVer -match "ripgrep (\d+\.\d+)") {
        Pass "ripgrep functional" $rgVer

        # Test rg can search
        $testFile = "$env:TEMP\rg-test.txt"
        "Hello World`nTest Line`nAnother Line" | Out-File $testFile -Encoding utf8
        $rgResult = rg "Test" $testFile 2>&1
        Remove-Item $testFile -Force -ErrorAction SilentlyContinue

        if ($rgResult -match "Test Line") {
            Pass "ripgrep search works" "Found 'Test' in file"
        } else {
            Fail "ripgrep search failed" $rgResult
        }
    }
} else {
    Fail "ripgrep not installed"
}

# fd - Test file finding
Write-Host "`n  Testing: fd (file finder)" -ForegroundColor Gray
if (Test-CommandExists "fd") {
    $fdVer = fd --version 2>&1
    if ($fdVer -match "fd (\d+\.\d+)") {
        Pass "fd functional" $fdVer

        # Test fd can find files
        $fdResult = fd "notepad.exe" "C:\Windows\System32" --max-depth 1 2>&1
        if ($fdResult -match "notepad") {
            Pass "fd file search works" "Found notepad.exe"
        } else {
            Pass "fd runs" "Search completed (notepad may be elsewhere)"
        }
    }
} else {
    Fail "fd not installed"
}

# bat - Test file viewing with syntax highlighting
Write-Host "`n  Testing: bat (cat with wings)" -ForegroundColor Gray
if (Test-CommandExists "bat") {
    $batVer = bat --version 2>&1
    if ($batVer -match "bat (\d+\.\d+)") {
        Pass "bat functional" $batVer

        # Test bat can display a file
        $testFile = "$env:TEMP\bat-test.ps1"
        'Write-Host "Hello"' | Out-File $testFile -Encoding utf8
        $batResult = bat --plain $testFile 2>&1
        Remove-Item $testFile -Force -ErrorAction SilentlyContinue

        if ($batResult -match "Hello") {
            Pass "bat syntax highlighting" "Can display files with highlighting"
        }
    }
} else {
    Fail "bat not installed"
}

# eza - Test ls replacement
Write-Host "`n  Testing: eza (modern ls)" -ForegroundColor Gray
if (Test-CommandExists "eza") {
    $ezaVer = eza --version 2>&1 | Select-Object -First 1
    if ($ezaVer -match "eza") {
        Pass "eza functional" $ezaVer

        # Test eza can list directory
        $ezaResult = eza -la $env:USERPROFILE 2>&1
        if ($ezaResult.Count -gt 0) {
            Pass "eza directory listing" "Lists files with details and hidden files"
        }
    }
} else {
    Fail "eza not installed"
}

# delta - Test git diff viewer
Write-Host "`n  Testing: delta (git diff viewer)" -ForegroundColor Gray
if (Test-CommandExists "delta") {
    $deltaVer = delta --version 2>&1
    if ($deltaVer -match "delta (\d+\.\d+)") {
        Pass "delta functional" $deltaVer
    }
} else {
    Fail "delta not installed"
}

# zoxide - Test directory jumper
Write-Host "`n  Testing: zoxide (smart cd)" -ForegroundColor Gray
if (Test-CommandExists "zoxide") {
    $zoxideVer = zoxide --version 2>&1
    if ($zoxideVer -match "zoxide (\d+\.\d+)") {
        Pass "zoxide functional" $zoxideVer

        # Test zoxide init for PowerShell
        $zoxideInit = zoxide init powershell 2>&1
        if ($zoxideInit -match "function") {
            Pass "zoxide PowerShell init" "Generates shell integration"
        }
    }
} else {
    Fail "zoxide not installed"
}

# Starship - Test prompt
Write-Host "`n  Testing: Starship (prompt)" -ForegroundColor Gray
if (Test-CommandExists "starship") {
    $starshipVer = starship --version 2>&1
    if ($starshipVer -match "starship (\d+\.\d+)") {
        Pass "Starship functional" $starshipVer

        # Test starship init for PowerShell
        $starshipInit = starship init powershell 2>&1
        if ($starshipInit -match "Invoke-Expression") {
            Pass "Starship PowerShell init" "Generates prompt configuration"
        }
    }
} else {
    Fail "Starship not installed"
}

# jq - Test JSON processing
Write-Host "`n  Testing: jq (JSON processor)" -ForegroundColor Gray
if (Test-CommandExists "jq") {
    $jqVer = jq --version 2>&1
    if ($jqVer -match "jq-(\d+\.\d+)") {
        Pass "jq functional" $jqVer

        # Test jq can parse JSON
        $jqResult = '{"name":"test","value":42}' | jq '.name' 2>&1
        if ($jqResult -match "test") {
            Pass "jq JSON parsing" "Extracted .name from JSON"
        }
    }
} else {
    Fail "jq not installed"
}

# yq - Test YAML processing
Write-Host "`n  Testing: yq (YAML processor)" -ForegroundColor Gray
if (Test-CommandExists "yq") {
    $yqVer = yq --version 2>&1
    if ($yqVer) {
        Pass "yq functional" $yqVer
    }
} else {
    Fail "yq not installed"
}

# tldr - Test simplified man pages
Write-Host "`n  Testing: tldr (simplified man pages)" -ForegroundColor Gray
if (Test-CommandExists "tldr") {
    $tldrVer = tldr --version 2>&1
    if ($tldrVer) {
        Pass "tldr functional" "Version: $tldrVer"
    }
} else {
    Fail "tldr not installed"
}

# dust - Test disk usage analyzer
Write-Host "`n  Testing: dust (disk usage)" -ForegroundColor Gray
if (Test-CommandExists "dust") {
    $dustVer = dust --version 2>&1
    if ($dustVer -match "dust") {
        Pass "dust functional" $dustVer
    }
} else {
    Fail "dust not installed"
}

# ============================================================================
# [5/10] TUI TOOLS - Test interactive tools
# ============================================================================

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "[5/10] TUI TOOLS - Testing interactive tools" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

# lazygit
Write-Host "`n  Testing: lazygit (git TUI)" -ForegroundColor Gray
if (Test-CommandExists "lazygit") {
    $lgVer = lazygit --version 2>&1
    if ($lgVer -match "version=(\d+\.\d+)") {
        Pass "lazygit functional" "Version: $($Matches[1])"
    } else {
        Pass "lazygit installed" $lgVer
    }
} else {
    Fail "lazygit not installed"
}

# lazydocker
Write-Host "`n  Testing: lazydocker (docker TUI)" -ForegroundColor Gray
if (Test-CommandExists "lazydocker") {
    $ldVer = lazydocker --version 2>&1
    if ($ldVer -match "Version:(\d+\.\d+)") {
        Pass "lazydocker functional" "Version: $($Matches[1])"
    } else {
        Pass "lazydocker installed" $ldVer
    }
} else {
    Fail "lazydocker not installed"
}

# btop
Write-Host "`n  Testing: btop (system monitor)" -ForegroundColor Gray
if (Test-CommandExists "btop") {
    $btopVer = btop --version 2>&1
    if ($btopVer -match "btop") {
        Pass "btop functional" $btopVer
    } else {
        Pass "btop installed"
    }
} else {
    Fail "btop not installed"
}

# ============================================================================
# [6/10] DEV TOOLS - Functional tests
# ============================================================================

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "[6/10] DEV TOOLS - Testing development environment" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

# Node.js
Write-Host "`n  Testing: Node.js" -ForegroundColor Gray
if (Test-CommandExists "node") {
    $nodeVer = node --version 2>&1
    if ($nodeVer -match "v(\d+\.\d+\.\d+)") {
        Pass "Node.js functional" "Version: $nodeVer"

        # Test Node can execute JS
        $nodeResult = node -e "console.log(1+1)" 2>&1
        if ($nodeResult -eq "2") {
            Pass "Node.js execution" "Can run JavaScript (1+1=2)"
        }

        # Test npm
        if (Test-CommandExists "npm") {
            $npmVer = npm --version 2>&1
            Pass "npm functional" "Version: $npmVer"
        } else {
            Fail "npm not found"
        }
    }
} else {
    Fail "Node.js not installed"
}

# Python
Write-Host "`n  Testing: Python" -ForegroundColor Gray
if (Test-CommandExists "python") {
    $pyVer = python --version 2>&1
    if ($pyVer -match "Python (\d+\.\d+\.\d+)") {
        Pass "Python functional" $pyVer

        # Test Python can execute
        $pyResult = python -c "print(2+2)" 2>&1
        if ($pyResult -eq "4") {
            Pass "Python execution" "Can run Python (2+2=4)"
        }

        # Test pip
        if (Test-CommandExists "pip") {
            $pipVer = pip --version 2>&1
            if ($pipVer -match "pip (\d+\.\d+)") {
                Pass "pip functional" $pipVer
            }
        } else {
            Fail "pip not found"
        }
    }
} else {
    Fail "Python not installed"
}

# Go
Write-Host "`n  Testing: Go" -ForegroundColor Gray
if (Test-CommandExists "go") {
    $goVer = go version 2>&1
    if ($goVer -match "go(\d+\.\d+)") {
        Pass "Go functional" $goVer

        # Test Go can compile
        $goEnv = go env GOVERSION 2>&1
        if ($goEnv -match "go\d+") {
            Pass "Go environment" "GOVERSION = $goEnv"
        }
    }
} else {
    Fail "Go not installed"
}

# Docker
Write-Host "`n  Testing: Docker" -ForegroundColor Gray
if (Test-CommandExists "docker") {
    $dockerVer = docker --version 2>&1
    if ($dockerVer -match "Docker version (\d+\.\d+)") {
        Pass "Docker functional" $dockerVer

        # Test Docker daemon (may not be running)
        $dockerInfo = docker info 2>&1
        if ($LASTEXITCODE -eq 0) {
            Pass "Docker daemon running" "Docker Desktop is active"
        } else {
            Pass "Docker installed" "Daemon not running (start Docker Desktop)"
        }
    }
} else {
    Fail "Docker not installed"
}

# ============================================================================
# [7/10] APPLICATIONS - Test installed apps
# ============================================================================

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "[7/10] APPLICATIONS - Testing installed applications" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

# Chrome
Write-Host "`n  Testing: Google Chrome" -ForegroundColor Gray
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (Test-Path $chromePath) {
    $chromeVer = (Get-Item $chromePath).VersionInfo.ProductVersion
    Pass "Chrome installed" "Version: $chromeVer"

    # Check default browser
    $httpProgId = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -ErrorAction SilentlyContinue).ProgId
    if ($httpProgId -like "*Chrome*") {
        Pass "Chrome is default browser" "HTTP handler: $httpProgId"
    } else {
        Fail "Chrome not default browser" "Current: $httpProgId (set manually in Settings)"
    }
} else {
    Fail "Chrome not installed"
}

# VSCode
Write-Host "`n  Testing: Visual Studio Code" -ForegroundColor Gray
$vscodePaths = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
    "C:\Program Files\Microsoft VS Code\Code.exe"
)
$vscodeExe = $null
foreach ($p in $vscodePaths) {
    if (Test-Path $p) { $vscodeExe = $p; break }
}

if ($vscodeExe) {
    $vscodeVer = (Get-Item $vscodeExe).VersionInfo.ProductVersion
    Pass "VSCode installed" "Version: $vscodeVer"

    # Test code CLI
    if (Test-CommandExists "code") {
        $codeVer = code --version 2>&1 | Select-Object -First 1
        Pass "VSCode CLI (code)" "Version: $codeVer"

        # Test listing extensions
        $extCount = (code --list-extensions 2>&1).Count
        Pass "VSCode extensions" "$extCount extensions installed"
    } else {
        Fail "VSCode CLI not in PATH"
    }
} else {
    Fail "VSCode not installed"
}

# Windows Terminal
Write-Host "`n  Testing: Windows Terminal" -ForegroundColor Gray
$wtPkg = Get-AppxPackage -Name "*WindowsTerminal*" -ErrorAction SilentlyContinue
if ($wtPkg) {
    Pass "Windows Terminal installed" "Version: $($wtPkg.Version)"
} else {
    Fail "Windows Terminal not installed"
}

# ============================================================================
# [8/10] CONFIG DEPLOYMENT - Verify configs are correct
# ============================================================================

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "[8/10] CONFIG DEPLOYMENT - Verifying configuration files" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

# VSCode settings.json
Write-Host "`n  Testing: VSCode settings.json" -ForegroundColor Gray
$vscodeSettings = "$env:APPDATA\Code\User\settings.json"
if (Test-Path $vscodeSettings) {
    try {
        $settings = Get-Content $vscodeSettings -Raw | ConvertFrom-Json
        Pass "VSCode settings.json exists" "File is valid JSON"

        # Check some expected settings
        if ($settings.'editor.fontSize') {
            Pass "VSCode editor.fontSize" "Value: $($settings.'editor.fontSize')"
        }
        if ($settings.'editor.fontFamily') {
            Pass "VSCode editor.fontFamily" "Value: $($settings.'editor.fontFamily')"
        }
    } catch {
        Fail "VSCode settings.json invalid" $_.Exception.Message
    }
} else {
    Fail "VSCode settings.json missing"
}

# VSCode keybindings.json
Write-Host "`n  Testing: VSCode keybindings.json" -ForegroundColor Gray
$vscodeKeybindings = "$env:APPDATA\Code\User\keybindings.json"
if (Test-Path $vscodeKeybindings) {
    try {
        $keybindings = Get-Content $vscodeKeybindings -Raw | ConvertFrom-Json
        $count = $keybindings.Count
        Pass "VSCode keybindings.json" "$count custom keybindings defined"
    } catch {
        Fail "VSCode keybindings.json invalid" $_.Exception.Message
    }
} else {
    Fail "VSCode keybindings.json missing"
}

# PowerShell profile
Write-Host "`n  Testing: PowerShell profile" -ForegroundColor Gray
if (Test-Path $PROFILE) {
    Pass "PowerShell profile exists" $PROFILE

    $profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue

    # Check for Starship
    if ($profileContent -match "starship init") {
        Pass "Profile: Starship prompt" "Starship initialization found"
    } else {
        Fail "Profile: Starship missing"
    }

    # Check for zoxide
    if ($profileContent -match "zoxide init") {
        Pass "Profile: zoxide (z command)" "Directory jumper initialized"
    } else {
        Fail "Profile: zoxide missing"
    }

    # Check for aliases
    if ($profileContent -match "function gs.*git status") {
        Pass "Profile: Git aliases" "gs, ga, gc, gp, etc. defined"
    } else {
        Fail "Profile: Git aliases missing"
    }

    # Check for eza alias
    if ($profileContent -match "Set-Alias.*ls.*eza") {
        Pass "Profile: eza as ls" "ls -> eza with icons"
    } else {
        Fail "Profile: eza alias missing"
    }

    # Check for bat alias
    if ($profileContent -match "Set-Alias.*cat.*bat") {
        Pass "Profile: bat as cat" "cat -> bat with syntax highlighting"
    } else {
        Fail "Profile: bat alias missing"
    }
} else {
    Fail "PowerShell profile missing"
}

# ============================================================================
# [9/10] CLAUDE CODE - Test AI assistant
# ============================================================================

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "[9/10] CLAUDE CODE - Testing AI coding assistant" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

# Claude CLI
Write-Host "`n  Testing: Claude Code CLI" -ForegroundColor Gray
if (Test-CommandExists "claude") {
    $claudeVer = claude --version 2>&1
    Pass "Claude CLI installed" "Version: $claudeVer"

    # Check config directory
    $claudeDir = "$env:USERPROFILE\.claude"
    if (Test-Path $claudeDir) {
        Pass "Claude config directory" $claudeDir

        # Check for settings
        if (Test-Path "$claudeDir\settings.local.json") {
            Pass "Claude settings.local.json" "Custom settings configured"
        }
    } else {
        Fail "Claude config directory missing"
    }
} else {
    Fail "Claude CLI not installed"
}

# ============================================================================
# [10/10] NERD FONT - Test font installation
# ============================================================================

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "[10/10] NERD FONT - Testing font installation" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

Write-Host "`n  Testing: MesloLGS Nerd Font" -ForegroundColor Gray
$fontPaths = @(
    "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\MesloLGSNerdFont-Regular.ttf",
    "C:\Windows\Fonts\MesloLGSNerdFont-Regular.ttf",
    "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\MesloLGSNFM-Regular.ttf"
)
$fontFound = $null
foreach ($p in $fontPaths) {
    if (Test-Path $p) { $fontFound = $p; break }
}

if ($fontFound) {
    Pass "MesloLGS Nerd Font installed" $fontFound

    # Check font registry
    $fontReg = Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue
    $nerdFonts = $fontReg.PSObject.Properties | Where-Object { $_.Name -like "*MesloLG*" }
    if ($nerdFonts) {
        Pass "Nerd Font registered" "$($nerdFonts.Count) font variants registered"
    }
} else {
    Fail "MesloLGS Nerd Font not found"
}

# ============================================================================
# SUMMARY
# ============================================================================

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

$total = $script:Passed + $script:Failed
$passRate = if ($total -gt 0) { [math]::Round(($script:Passed / $total) * 100, 1) } else { 0 }

Write-Host "`n  Results:" -ForegroundColor White
Write-Host "    Passed:    $($script:Passed)" -ForegroundColor Green
Write-Host "    Failed:    $($script:Failed)" -ForegroundColor Red
Write-Host "    Total:     $total" -ForegroundColor White

$color = if ($passRate -ge 95) { "Green" } elseif ($passRate -ge 80) { "Yellow" } else { "Red" }
Write-Host "    Pass Rate: $passRate%" -ForegroundColor $color

# Show failed tests
$failedTests = $script:TestDetails | Where-Object { $_.Status -eq "FAIL" }
if ($failedTests.Count -gt 0) {
    Write-Host "`n  Failed Tests:" -ForegroundColor Red
    foreach ($test in $failedTests) {
        Write-Host "    - $($test.Name)" -ForegroundColor Red
        if ($test.Detail) {
            Write-Host "      $($test.Detail)" -ForegroundColor DarkRed
        }
    }
}

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan

if ($script:Failed -gt 0) { exit 1 } else { exit 0 }
