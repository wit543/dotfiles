# TUI Installer Specification

## Purpose

Interactive terminal UI for dotfiles installation using Python Textual framework.
This provides a modern, user-friendly alternative to the shell-based installer.

Supports both local Unix/macOS installation and remote Windows deployment with debloating.

## Architecture

| Aspect | Value |
|--------|-------|
| Framework | [Textual](https://github.com/Textualize/textual) (Python TUI) |
| Integration | Hybrid (calls bash `setup_*` functions via subprocess) |
| Entry Point | `./install-tui.py` (standalone script) |
| Dependencies | `requirements-tui.txt` |

### Why Hybrid Integration?

- **No code duplication**: All installation logic stays in shell scripts
- **Easy maintenance**: Update shell functions, TUI automatically uses them
- **Fallback**: Users can still use `./install.sh` directly

## Profiles

Quick-select presets for common use cases:

| Profile | Components | Use Case |
|---------|------------|----------|
| Minimal | zsh, git, editorconfig | Server/minimal setup |
| Medium | + vim, tmux | Developer without IDE |
| Full | + vscode, claude | Complete workstation |
| Custom | User selects | Advanced users |

## Components

| ID | Name | Shell Function | Default |
|----|------|----------------|---------|
| `zsh` | Shell (Zsh + Zinit + Starship + zoxide + fzf) | `setup_zsh()` | Selected |
| `vim` | Vim/Neovim (vim-plug + plugins) | `setup_vim()` | Selected |
| `tmux` | Tmux (gpakosz config + TPM) | `setup_tmux()` | Selected |
| `git` | Git (gitconfig + delta + gitignore) | `setup_git()` | Selected |
| `vscode` | VSCode (settings + keybindings + extensions) | `setup_vscode()` | Selected |
| `claude` | Claude Code (MCP + settings) | `setup_claude()` | Selected |
| `editorconfig` | EditorConfig (universal formatting) | `setup_editorconfig()` | Selected |

## Windows Components

For remote Windows machines (via SSH):

| ID | Name | Description |
|----|------|-------------|
| `debloat` | Remove Bloatware | 80+ apps: Cortana, Bing, Candy Crush, social media, etc. |
| `telemetry` | Disable Telemetry | Ads, Copilot, Bing search, Start menu suggestions |
| `system` | System Settings | Hibernate off, Cursor 150% black |
| `chrome` | Chrome | Install + set as default browser |
| `vscode` | VSCode | Install + settings + keybindings + extensions |

## Install Modes

| Mode | Flag | Description |
|------|------|-------------|
| Full Install | `--sudo` | Install packages + symlink configs |
| Config Only | `--no-sudo` | Symlink configs only (no sudo required) |
| Update | `--update` | Upgrade packages + refresh configs |

## Remote Machines Configuration

Remote machines are configured in `machines.yaml`:

```yaml
machines:
  macbook-pro:
    user: myuser
    host: 192.168.1.41
    os: macos
    description: Personal MacBook Pro

  home-pc:
    user: Home
    host: 192.168.1.53
    password: "mypassword"  # Optional, uses SSH keys if not set
    os: windows
    description: Home Windows 11 PC

  server:
    user: admin
    host: 10.0.0.5
    os: ubuntu
    description: Dev server
```

| Field | Required | Description |
|-------|----------|-------------|
| `user` | Yes | SSH username |
| `host` | Yes | IP address or hostname |
| `os` | Yes | `macos`, `ubuntu`, `rocky`, `manjaro`, or `windows` |
| `password` | No | SSH password (requires `sshpass`). Uses SSH keys if not set. |
| `description` | No | Human-readable description |

## Screens

### Local Installation Flow
```
┌─────────────┐     ┌─────────────┐     ┌──────────────────┐     ┌─────────────┐     ┌──────────────┐
│   Welcome   │ ──► │   Profile   │ ──► │ Component Select │ ──► │  Progress   │ ──► │   Complete   │
│   Screen    │     │   Select    │     │  (if Custom)     │     │   Screen    │     │    Screen    │
└─────────────┘     └─────────────┘     └──────────────────┘     └─────────────┘     └──────────────┘
```

### Remote Deployment Flow (Unix/macOS)
```
┌─────────────┐     ┌─────────────┐     ┌──────────────────┐     ┌─────────────┐     ┌──────────────┐
│   Welcome   │ ──► │  Machine    │ ──► │  Remote Profile  │ ──► │   Remote    │ ──► │   Complete   │
│   Screen    │     │   Select    │     │     Select       │     │  Progress   │     │    Screen    │
└─────────────┘     └─────────────┘     └──────────────────┘     └─────────────┘     └──────────────┘
```

### Remote Deployment Flow (Windows)
```
┌─────────────┐     ┌─────────────┐     ┌──────────────────┐     ┌─────────────┐     ┌──────────────┐
│   Welcome   │ ──► │  Machine    │ ──► │    Windows       │ ──► │  Windows    │ ──► │   Complete   │
│   Screen    │     │   Select    │     │   Components     │     │  Progress   │     │    Screen    │
└─────────────┘     └─────────────┘     └──────────────────┘     └─────────────┘     └──────────────┘
```

### 1. Welcome Screen

- Display ASCII banner
- Show detected OS and architecture
- Show dotfiles directory path
- Show number of configured remote machines
- Two buttons: **Local Install** / **Remote Deploy**

### 2. Machine Select Screen (Remote only)

- List machines from `machines.yaml`
- Shows: name, user@host, OS type
- Auto-routes to Windows or Unix flow based on OS

### 3. Profile Screen (Local)

- Radio buttons: Minimal, Medium, Full (Recommended), Custom
- Installation mode: Full Install, Config Only, Update
- Brief description of each profile
- Continue button

### 4. Remote Profile Screen (Unix/macOS remote)

- Shows target machine info
- Radio buttons: Full, Medium, Minimal
- Deploy button

### 5. Windows Component Screen

- Checkbox list of Windows components:
  - Remove Bloatware (80+ apps)
  - Disable Telemetry
  - System Settings
  - Chrome
  - VSCode
- Deploy button

### 6. Component Screen (Custom only)

- Checkbox list of all components
- Select All / Deselect All buttons
- Back and Install buttons

### 7. Progress Screen

- Log widget showing real-time output
- Progress bar
- Current component being installed
- Variants: Local, Remote Unix, Remote Windows

### 8. Complete Screen

- Success/failure summary
- List of installed components with ✓/✗ status
- Target info (local or remote machine name)
- Next steps (restart shell)
- Exit button

## UI Mockup

```
╔═══════════════════════════════════════════════════════════════╗
║  DOTFILES INSTALLER                               macOS arm64 ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Select components to install:                                ║
║  ─────────────────────────────                                ║
║  [x] Shell (Zsh + Zinit + Starship + zoxide + fzf)           ║
║  [x] Vim/Neovim (vim-plug + plugins)                         ║
║  [x] Tmux (gpakosz config + TPM)                             ║
║  [x] Git (gitconfig + delta + gitignore)                     ║
║  [ ] VSCode (settings + keybindings + extensions)            ║
║  [x] Claude Code (MCP + settings)                            ║
║  [x] EditorConfig                                            ║
║                                                               ║
║  ─────────────────────────────                                ║
║  Installation mode:                                           ║
║  (•) Full Install    ( ) Config Only    ( ) Update           ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║  [Select All]  [Deselect All]           [Cancel]  [Install]  ║
╚═══════════════════════════════════════════════════════════════╝
```

## Keybindings

| Key | Action |
|-----|--------|
| Tab | Navigate between widgets |
| Space | Toggle checkbox / select radio |
| Enter | Confirm / Continue |
| Escape | Back / Cancel |
| q | Quit application |

## Integration Code Pattern

The TUI calls shell functions via subprocess:

```python
def run_setup_function(self, component: str) -> tuple[bool, str]:
    """Source bash libs and call setup_* function."""
    script = f'''
        set -e
        source "{self.dotfiles_dir}/lib/utils.sh"
        source "{self.dotfiles_dir}/lib/os.sh"
        source "{self.dotfiles_dir}/lib/packages.sh"
        detect_os
        setup_{component}
    '''
    result = subprocess.run(
        ["bash", "-c", script],
        capture_output=True,
        text=True,
        cwd=self.dotfiles_dir
    )
    return (result.returncode == 0, result.stdout + result.stderr)
```

## Error Handling

- Missing Python/Textual: Show install instructions and exit
- Component failure: Log error, continue with next component
- All failures: Show summary with failed components

## Testing

```bash
# Install dependency
pip install textual

# Run TUI installer
./install-tui.py

# Or explicitly with Python
python3 install-tui.py
```

## Future Enhancements

- [x] Remote Windows deployment via SSH
- [x] Windows debloating (80+ apps)
- [x] Telemetry/ads disable
- [ ] Add dry-run mode to preview changes
- [ ] Add component dependency checking
- [ ] Add rollback functionality
- [ ] Add theme selection (dark/light)
- [ ] Add package-only install option
