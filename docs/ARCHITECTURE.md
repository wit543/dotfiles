# Dotfiles Architecture

Comprehensive documentation of the dotfiles system architecture, workflows, and components.

## Overview

```mermaid
graph TB
    subgraph "Entry Points"
        A[curl bootstrap.sh] --> B[install.sh]
        C[python install-tui.py] --> B
        D[irm install.ps1] --> E[setup.ps1]
    end

    subgraph "Installation Modes"
        B --> F{Mode?}
        F -->|--sudo| G[Full Install]
        F -->|--no-sudo| H[Config Only]
        F -->|--update| I[Update]
        F -->|--remote| J[Remote Deploy]
    end

    subgraph "Package Managers"
        G --> K[Homebrew/apt/dnf/pacman]
        E --> L[winget]
    end

    subgraph "Config Deployment"
        G --> M[Symlink Configs]
        H --> M
        E --> N[Copy Configs]
    end

    subgraph "Target Locations"
        M --> O[~/.zshrc]
        M --> P[~/.config/]
        M --> Q[~/.claude/]
        N --> R[%USERPROFILE%]
        N --> S[%APPDATA%]
    end
```

## System Components

### 1. Entry Points

```mermaid
flowchart LR
    subgraph "macOS/Linux"
        A[bootstrap.sh] -->|curl| B[install.sh]
        C[install-tui.py] -->|textual| B
    end

    subgraph "Windows"
        D[install.ps1] -->|irm/iex| E[setup.ps1]
        F[install.cmd] -->|curl| D
    end

    subgraph "Remote"
        G[machines.yaml] --> H[SSH Deploy]
        H --> B
        H --> E
    end
```

### 2. Installation Flow

```mermaid
sequenceDiagram
    participant User
    participant Bootstrap
    participant Installer
    participant ProfileResolver
    participant PackageManager
    participant ConfigDeployer

    User->>Bootstrap: curl | bash
    Bootstrap->>Bootstrap: Clone dotfiles repo
    Bootstrap->>Installer: Execute install.sh

    Installer->>ProfileResolver: Resolve profile/components
    alt --profile specified
        ProfileResolver-->>Installer: Profile components
    else --interactive or TTY
        ProfileResolver->>User: Select profile
        User-->>ProfileResolver: Choice
        ProfileResolver-->>Installer: Selected components
    else default
        ProfileResolver-->>Installer: full profile
    end

    alt Full Install (--sudo)
        Installer->>PackageManager: Install packages
        PackageManager-->>Installer: Done
    end

    loop For each component
        Installer->>ConfigDeployer: Deploy if should_install()
    end
    ConfigDeployer->>ConfigDeployer: Create symlinks
    ConfigDeployer->>ConfigDeployer: Setup plugins
    ConfigDeployer-->>User: Installation complete
```

### 2.1 Profile-Based Installation

```mermaid
flowchart TD
    A[Start] --> B{Profile specified?}
    B -->|--profile=X| C[Use profile X]
    B -->|--components=X,Y| D[Use custom list]
    B -->|--interactive| E[Show menu]
    B -->|No args + TTY| E
    B -->|No args + pipe| F[Default: full]

    E --> G{User choice}
    G -->|1-4| H[Use selected profile]
    G -->|5| I[Custom selection]

    C --> J[Get profile components]
    D --> J
    H --> J
    I --> J
    F --> J

    J --> K[SELECTED_COMPONENTS]
    K --> L{For each setup function}
    L --> M{should_install component?}
    M -->|Yes| N[Run setup]
    M -->|No| O[Skip]
    N --> L
    O --> L
```

### 2.2 Profile Definitions

| Profile | Components | Use Case |
|---------|------------|----------|
| `minimal` | zsh, git, editorconfig | Servers, VMs |
| `deploy` | minimal + docker | CI/CD, containers |
| `development` | deploy + vim, tmux, vscode | Workstations |
| `full` | development + claude | Power users |

**Unix/Linux Components:**
```
zsh         → Zinit, Starship, zoxide, fzf, plugins
vim         → vim-plug, Neovim, 40+ plugins
tmux        → TPM, gpakosz config
git         → .gitconfig, .gitignore_global
vscode      → settings.json, keybindings, extensions
claude      → settings.json, CLAUDE.md
editorconfig→ .editorconfig
docker      → lazydocker (Linux only)
```

**Windows Components:**
```
system      → Cursor size, hibernate
bloatware   → Remove 80+ apps
telemetry   → Disable tracking/ads
cli-basic   → git, fzf, ripgrep
cli-full    → neovim, fd, bat, eza, delta, zoxide, starship, jq, yq
tui         → lazygit, lazydocker, btop
devtools    → Node.js, Python, Go, Docker
apps        → Chrome, VSCode, Terminal
font        → MesloLGS Nerd Font
git         → .gitconfig
vscode      → settings, extensions
claude      → CLI, settings, CLAUDE.md
profile     → PowerShell profile
```

### 3. Package Installation

```mermaid
flowchart TD
    A[detect_os] --> B{OS Type?}

    B -->|macOS| C[Homebrew]
    B -->|Ubuntu/Debian| D[apt]
    B -->|Rocky/RHEL| E[dnf]
    B -->|Manjaro/Arch| F[pacman]
    B -->|Windows| G[winget]

    C --> H[packages/Brewfile]
    D --> I[packages/apt.txt]
    E --> J[packages/dnf.txt]
    F --> K[packages/pacman.txt]
    G --> L[setup.ps1 arrays]

    H --> M[brew bundle]
    I --> N[apt install]
    J --> O[dnf install]
    K --> P[pacman -S]
    L --> Q[winget install]
```

## Configuration Deployment

### File Mapping

```mermaid
graph LR
    subgraph "Source (dotfiles/config/)"
        A1[zsh/.zshrc]
        A2[zsh/starship.toml]
        A3[vim/.vimrc]
        A4[tmux/.tmux.conf]
        A5[git/.gitconfig]
        A6[vscode/settings.json]
        A7[claude/settings.json]
        A8[claude/CLAUDE.md]
    end

    subgraph "Target (Home)"
        B1[~/.zshrc]
        B2[~/.config/starship.toml]
        B3[~/.vimrc]
        B4[~/.tmux.conf]
        B5[~/.gitconfig]
        B6[~/Library/Application Support/Code/User/settings.json]
        B7[~/.claude/settings.json]
        B8[~/.claude/CLAUDE.md]
    end

    A1 -->|symlink| B1
    A2 -->|symlink| B2
    A3 -->|symlink| B3
    A4 -->|symlink| B4
    A5 -->|symlink| B5
    A6 -->|symlink| B6
    A7 -->|symlink| B7
    A8 -->|symlink| B8
```

### Windows Deployment

```mermaid
graph LR
    subgraph "Source"
        A1[config/git/.gitconfig]
        A2[config/zsh/starship.toml]
        A3[config/vscode/settings.json]
        A4[config/claude/settings.json]
        A5[config/claude/CLAUDE.md]
    end

    subgraph "Target"
        B1[%USERPROFILE%\.gitconfig]
        B2[%USERPROFILE%\.config\starship.toml]
        B3[%APPDATA%\Code\User\settings.json]
        B4[%APPDATA%\claude-code\settings.json]
        B5[%USERPROFILE%\.claude\settings.json]
        B6[%USERPROFILE%\.claude\CLAUDE.md]
    end

    A1 -->|copy| B1
    A2 -->|copy| B2
    A3 -->|copy| B3
    A4 -->|copy| B4
    A4 -->|copy| B5
    A5 -->|copy| B6
```

## Shell Environment

### Zsh Initialization

```mermaid
flowchart TD
    A[Terminal Start] --> B[/etc/zshenv]
    B --> C[~/.zshenv]
    C --> D[~/.zshrc]

    D --> E[Zinit Init]
    E --> F[Load Plugins]

    F --> G[zsh-autosuggestions]
    F --> H[zsh-syntax-highlighting]
    F --> I[zsh-completions]
    F --> J[fzf-tab]

    D --> K[Starship Init]
    K --> L[Load starship.toml]

    D --> M[Zoxide Init]
    D --> N[FZF Init]
    D --> O[Aliases & Functions]

    O --> P[Modern CLI Aliases]
    P --> Q[eza → ls]
    P --> R[bat → cat]
    P --> S[delta → diff]
```

### Plugin Loading (Turbo Mode)

```mermaid
sequenceDiagram
    participant Shell
    participant Zinit
    participant Plugins

    Shell->>Zinit: source zinit.zsh
    Zinit->>Shell: Prompt ready (instant)

    Note over Zinit,Plugins: Async loading after prompt

    Zinit->>Plugins: wait"0" - syntax-highlighting
    Zinit->>Plugins: wait"1" - autosuggestions
    Zinit->>Plugins: wait"2" - completions

    Plugins-->>Shell: Plugins loaded in background
```

## Claude Code Configuration

### Permission Flow

```mermaid
flowchart TD
    A[Claude Code Request] --> B{Permission Check}

    B --> C[settings.json]
    C --> D{In allow list?}

    D -->|Yes| E[Execute]
    D -->|No| F{In deny list?}

    F -->|Yes| G[Block]
    F -->|No| H[Prompt User]

    subgraph "Always Allowed"
        I[WebSearch]
        J[WebFetch]
        K[mcp__context7]
        L[Bash git:*]
        M[Bash npm test:*]
    end

    I --> E
    J --> E
    K --> E
    L --> E
    M --> E
```

### MCP Server Integration

```mermaid
flowchart LR
    A[Claude Code] --> B[MCP Protocol]

    B --> C[Context7 Server]
    C --> D[npx @upstash/context7-mcp]
    D --> E[Library Documentation]

    E --> F[resolve-library-id]
    E --> G[get-library-docs]

    F --> H[Return library info]
    G --> I[Return documentation]
```

## Remote Deployment

### SSH Workflow

```mermaid
sequenceDiagram
    participant Local
    participant machines.yaml
    participant SSH
    participant Remote

    Local->>machines.yaml: Load machine config
    machines.yaml-->>Local: user, host, os, password

    alt Has Password
        Local->>SSH: sshpass + ssh
    else SSH Key
        Local->>SSH: ssh
    end

    SSH->>Remote: Connect

    alt macOS/Linux
        Local->>Remote: rsync dotfiles
        Remote->>Remote: Run install.sh
    else Windows
        Local->>Remote: PowerShell commands
        Remote->>Remote: Run setup via SSH
    end

    Remote-->>Local: Installation complete
```

### Machine Configuration

```mermaid
erDiagram
    MACHINES_YAML {
        string name PK
        string user
        string host
        string password "optional"
        string os "macos|ubuntu|rocky|windows"
        string description
    }

    MACHINE_TYPES {
        string type PK
        string installer
        string package_manager
    }

    MACHINES_YAML ||--o{ MACHINE_TYPES : "os type"
```

## TUI Application

### Screen Flow

```mermaid
stateDiagram-v2
    [*] --> Welcome
    Welcome --> ModeSelect: Continue
    ModeSelect --> ComponentSelect: Local Install
    ModeSelect --> MachineSelect: Remote Install
    MachineSelect --> ComponentSelect: Select Machine
    MachineSelect --> WindowsComponentSelect: Windows Machine
    ComponentSelect --> Progress: Start Install
    WindowsComponentSelect --> WindowsProgress: Start Install
    Progress --> Complete: Done
    WindowsProgress --> Complete: Done
    Complete --> [*]: Exit
```

### Component Architecture

```mermaid
classDiagram
    class App {
        +SCREENS dict
        +push_screen()
        +pop_screen()
    }

    class WelcomeScreen {
        +compose()
        +on_button_pressed()
    }

    class ModeSelectScreen {
        +mode: str
        +compose()
    }

    class ComponentSelectScreen {
        +components: list
        +compose()
    }

    class ProgressScreen {
        +log: RichLog
        +run_installation()
    }

    App --> WelcomeScreen
    App --> ModeSelectScreen
    App --> ComponentSelectScreen
    App --> ProgressScreen
```

## Windows Setup Process

### Profile-Based Installation

```mermaid
flowchart TD
    A[Start setup.ps1] --> B{Parse -Profile}
    B --> C[Get SelectedComponents]

    C --> D{Should-Install bloatware?}
    D -->|Yes| E[Remove Bloatware]
    D -->|No| F{Should-Install telemetry?}
    E --> F

    F -->|Yes| G[Disable Telemetry]
    F -->|No| H{Should-Install system?}
    G --> H

    H -->|Yes| I[System Settings]
    H -->|No| J{Should-Install cli-basic?}
    I --> J

    J -->|Yes| K[Basic CLI: git, fzf, rg]
    J -->|No| L{Should-Install cli-full?}
    K --> L

    L -->|Yes| M[Full CLI: neovim, bat, eza...]
    L -->|No| N{Should-Install tui?}
    M --> N

    N -->|Yes| O[TUI: lazygit, btop]
    N -->|No| P{Continue...}
    O --> P

    P --> Q[More components...]
    Q --> R[Summary]
```

### Windows Profile Components

| Profile | Components Installed |
|---------|---------------------|
| `minimal` | system, bloatware, telemetry, git, cli-basic |
| `deploy` | minimal + docker |
| `development` | deploy + cli-full, tui, devtools, vscode, apps, font, profile |
| `full` | development + claude |

### Step-by-Step Flow (Full Profile)

```mermaid
flowchart TD
    A[Start setup.ps1 -Profile full] --> B[1. Remove Bloatware]
    B --> C[2. Disable Telemetry]
    C --> D[3. System Settings]
    D --> E[4. Basic CLI Tools]
    E --> F[5. Full CLI Tools]
    F --> G[6. TUI Tools]
    G --> H[7. Dev Tools]
    H --> I[8. Applications]
    I --> J[9. Nerd Font]
    J --> K[10. Git Config]
    K --> L[11. Starship Config]
    L --> M[12. VSCode Config]
    M --> N[13. Claude Config]
    N --> O[14. PowerShell Profile]
    O --> P[Summary]

    subgraph "Bloatware Removal"
        B1[Get-AppxPackage]
        B2[Remove-AppxPackage]
        B3[Remove Provisioned]
    end

    subgraph "CLI Tools"
        E1[git, fzf, ripgrep]
        F1[neovim, fd, bat, eza]
        F2[delta, zoxide, starship]
        F3[jq, yq, tldr, dust]
    end

    B --> B1 --> B2 --> B3
    E --> E1
    F --> F1 --> F2 --> F3
```

## Directory Structure

```mermaid
graph TD
    A[dotfiles/] --> B[bootstrap.sh]
    A --> C[install.sh]
    A --> D[install-tui.py]
    A --> E[lib/]
    A --> F[config/]
    A --> G[packages/]
    A --> H[docs/]

    E --> E1[utils.sh]
    E --> E2[os.sh]
    E --> E3[packages.sh]
    E --> E4[profiles.sh]

    F --> F1[zsh/]
    F --> F2[vim/]
    F --> F3[nvim/]
    F --> F4[tmux/]
    F --> F5[git/]
    F --> F6[vscode/]
    F --> F7[claude/]
    F --> F8[windows/]

    G --> G1[Brewfile]
    G --> G2[apt.txt]
    G --> G3[dnf.txt]
    G --> G4[pacman.txt]

    F8 --> W1[setup.ps1]
    F8 --> W2[install.ps1]
    F8 --> W3[install.cmd]
```

## Version Control

### Git Workflow

```mermaid
gitGraph
    commit id: "Initial"
    branch feature
    commit id: "Add feature"
    commit id: "Fix tests"
    checkout main
    merge feature id: "Merge feature"
    commit id: "Update docs"
```

### Commit Convention

```mermaid
flowchart LR
    A[Commit Message] --> B{Type}
    B --> C[feat: New feature]
    B --> D[fix: Bug fix]
    B --> E[docs: Documentation]
    B --> F[refactor: Code change]
    B --> G[test: Tests]
    B --> H[chore: Maintenance]

    C --> I["feat(zsh): Add fzf keybindings"]
    D --> J["fix(vim): Correct plugin path"]
    E --> K["docs: Update README"]
```

## Security Model

### Permissions Flow

```mermaid
flowchart TD
    A[User Request] --> B{Requires Sudo?}

    B -->|Yes| C{--sudo flag?}
    B -->|No| D[Execute]

    C -->|Yes| E[Run with sudo]
    C -->|No| F[Skip/Warn]

    E --> G{Admin Check}
    G -->|Pass| H[Execute]
    G -->|Fail| I[Error]

    subgraph "Sudo Operations"
        J[Package Install]
        K[System Config]
        L[Hibernate Control]
    end

    subgraph "Non-Sudo Operations"
        M[Config Symlinks]
        N[User Directories]
        O[Shell Plugins]
    end
```

### Sensitive Data Handling

```mermaid
flowchart LR
    A[machines.yaml] -->|gitignore| B[Not Tracked]
    C[machines.yaml.example] --> D[Tracked Template]

    E[.gitignore] --> F{File Type}
    F --> G[*.local - Excluded]
    F --> H[machines.yaml - Excluded]
    F --> I[.DS_Store - Excluded]

    J[Passwords in YAML] --> K[Local Only]
    K --> L[SSH Auth]
```

## Troubleshooting Flow

```mermaid
flowchart TD
    A[Issue] --> B{Category?}

    B -->|Zinit| C[rm -rf ~/.local/share/zinit]
    B -->|Starship| D[starship --version]
    B -->|Vim Plugins| E[vim +PlugInstall +qall]
    B -->|Tmux| F[Prefix + I]
    B -->|Icons| G[Install Nerd Font]
    B -->|zoxide| H[Visit directories first]

    C --> I[exec zsh]
    D --> J[curl install script]
    E --> K[Plugins installed]
    F --> L[TPM plugins installed]
    G --> M[Set terminal font]
    H --> N[z command works]
```

## Platform Comparison

| Feature | macOS | Ubuntu | Rocky | Manjaro | Windows |
|---------|-------|--------|-------|---------|---------|
| Package Manager | Homebrew | apt | dnf | pacman | winget |
| Shell | zsh | zsh | zsh | zsh | PowerShell |
| Config Method | symlink | symlink | symlink | symlink | copy |
| Claude CLI | npm | npm | npm | npm | npm |
| Nerd Font | brew cask | manual | manual | pacman | download |
| One-liner | curl\|bash | curl\|bash | curl\|bash | curl\|bash | irm\|iex |

## Future Enhancements

```mermaid
timeline
    title Roadmap
    section Phase 1
        WSL Support : Windows Subsystem for Linux
        Better TUI : Rich progress bars
    section Phase 2
        Nix Support : Cross-platform packages
        Ansible : Enterprise deployment
    section Phase 3
        GUI Installer : Electron/Tauri app
        Cloud Sync : Settings backup
```
