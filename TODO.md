# Dotfiles Project TODO

Comprehensive task list organized by topic. Check off items as completed.

---

## Table of Contents

1. [Core Infrastructure](#core-infrastructure)
2. [Shell Configuration](#shell-configuration)
3. [Editor Configuration](#editor-configuration)
4. [Terminal Multiplexer](#terminal-multiplexer)
5. [Git Configuration](#git-configuration)
6. [Claude Code Integration](#claude-code-integration)
7. [VSCode Configuration](#vscode-configuration)
8. [Package Management](#package-management)
9. [Windows Support](#windows-support)
10. [Remote Deployment](#remote-deployment)
11. [TUI Installer](#tui-installer)
12. [Testing](#testing)
13. [Documentation](#documentation)
14. [Security](#security)
15. [Future Enhancements](#future-enhancements)

---

## Core Infrastructure

### Bootstrap & Installation

- [x] Create bootstrap.sh for curl-able installation
- [x] Create install.sh main installer
- [x] Support --sudo flag for full installation
- [x] Support --no-sudo flag for config-only
- [x] Support --update flag for updates
- [ ] Add --dry-run flag to preview changes
- [ ] Add --verbose flag for detailed output
- [ ] Add --uninstall flag for removal
- [ ] Create rollback mechanism for failed installations
- [ ] Add checksum verification for downloaded files

### Library Functions

- [x] Create lib/utils.sh with logging helpers
- [x] Create lib/packages.sh for package management
- [ ] Create lib/os.sh for OS detection (currently in install.sh)
- [ ] Add lib/backup.sh for config backup/restore
- [ ] Add lib/symlink.sh for symlink management
- [ ] Add lib/verify.sh for post-install verification
- [ ] Standardize error handling across all scripts

### Directory Structure

- [x] Organize config/ subdirectories
- [x] Create packages/ for package lists
- [x] Create docs/ for documentation
- [x] Create tests/ for test suite
- [ ] Add scripts/ for utility scripts
- [ ] Add templates/ for config templates
- [ ] Add hooks/ for git hooks

---

## Shell Configuration

### Zsh Setup

- [x] Configure Zinit plugin manager
- [x] Enable Turbo mode for async loading
- [x] Configure zsh-autosuggestions
- [x] Configure zsh-syntax-highlighting
- [x] Configure zsh-completions
- [x] Configure fzf-tab completion
- [ ] Add custom completion scripts
- [ ] Optimize plugin loading order
- [ ] Add lazy loading for heavy plugins
- [ ] Create .zshrc.local template

### Prompt (Starship)

- [x] Create starship.toml configuration
- [x] Configure git status indicators
- [x] Configure language version display
- [ ] Add custom prompt segments
- [ ] Create multiple prompt themes
- [ ] Add prompt switching command
- [ ] Configure transient prompt

### Modern CLI Tools

- [x] Configure eza (ls replacement)
- [x] Configure bat (cat replacement)
- [x] Configure delta (diff replacement)
- [x] Configure fd (find replacement)
- [x] Configure ripgrep (grep replacement)
- [x] Configure zoxide (cd replacement)
- [x] Configure dust (du replacement)
- [ ] Configure procs (ps replacement)
- [ ] Configure sd (sed replacement)
- [ ] Add automatic fallbacks when tools missing
- [ ] Create unified config for all tools

### Key Bindings

- [x] Configure Ctrl+R for FZF history
- [x] Configure Ctrl+T for FZF files
- [x] Configure Alt+C for FZF directories
- [x] Configure Ctrl+F for quick jump
- [x] Configure Shift+Tab for autosuggestion
- [ ] Add Ctrl+G for git status
- [ ] Add Ctrl+B for branch switching
- [ ] Document all custom keybindings

### Aliases & Functions

- [x] Create modern tool aliases
- [x] Create git aliases
- [x] Create docker aliases
- [ ] Create kubernetes aliases
- [ ] Create terraform aliases
- [ ] Add mkcd function
- [ ] Add extract function (universal archive)
- [ ] Add backup function
- [ ] Add weather function
- [ ] Add cheatsheet function

---

## Editor Configuration

### Vim/Neovim

- [x] Configure vim-plug plugin manager
- [x] Install 40+ essential plugins
- [x] Configure EasyMotion
- [x] Configure FZF integration
- [x] Configure NERDTree
- [x] Configure vim-surround
- [x] Configure vim-fugitive
- [x] Configure Gruvbox colorscheme
- [x] Configure Airline statusline
- [ ] Add LSP configuration for Neovim
- [ ] Add Treesitter configuration
- [ ] Add Telescope configuration
- [ ] Create language-specific settings
- [ ] Add debugging configuration (DAP)
- [ ] Create custom snippets
- [ ] Add which-key configuration

### Neovim Specific

- [x] Create init.vim that sources .vimrc
- [ ] Migrate to init.lua
- [ ] Add lazy.nvim as alternative to vim-plug
- [ ] Configure Mason for LSP management
- [ ] Add nvim-cmp for completion
- [ ] Add null-ls for formatting/linting
- [ ] Create IDE-like experience

---

## Terminal Multiplexer

### Tmux

- [x] Configure based on gpakosz/.tmux
- [x] Enable TPM (Tmux Plugin Manager)
- [x] Configure tmux-resurrect
- [x] Configure tmux-continuum
- [x] Configure tmux-yank
- [x] Enable mouse support
- [x] Enable vi copy mode
- [ ] Create custom tmux themes
- [ ] Add session templates (dev, deploy, monitor)
- [ ] Configure tmux-fzf integration
- [ ] Add tmux-fingers for quick copy
- [ ] Create project-specific sessions
- [ ] Add tmuxinator/tmuxp configurations

---

## Git Configuration

### Global Config

- [x] Configure user settings
- [x] Configure delta for diffs
- [x] Create useful aliases
- [x] Configure global gitignore
- [ ] Add git hooks (pre-commit, commit-msg)
- [ ] Configure git-lfs
- [ ] Add signing configuration (GPG/SSH)
- [ ] Create branch naming convention
- [ ] Add git-flow configuration

### Aliases to Add

- [ ] git recent (recent branches)
- [ ] git contributors
- [ ] git changelog
- [ ] git undo (undo last commit)
- [ ] git wip (work in progress commit)
- [ ] git unwip (undo wip commit)

---

## Claude Code Integration

### MCP Servers

- [x] Configure Context7 MCP server
- [x] Configure Chrome DevTools MCP server
- [ ] Add filesystem MCP server
- [ ] Add GitHub MCP server
- [ ] Add database MCP server
- [ ] Add Slack MCP server
- [ ] Document MCP server usage

### Permissions

- [x] Configure WebSearch always allowed
- [x] Configure WebFetch always allowed
- [x] Pre-approve safe git commands
- [x] Pre-approve safe npm commands
- [x] Pre-approve safe pytest commands
- [x] Pre-approve safe docker commands
- [ ] Add project-specific permission profiles
- [ ] Document permission patterns

### CLAUDE.md Standards

- [x] Define code style guidelines
- [x] Define git commit conventions
- [x] Define language-specific rules
- [x] Define testing requirements
- [ ] Add architecture patterns
- [ ] Add API design guidelines
- [ ] Add database schema guidelines
- [ ] Add security guidelines
- [ ] Create project-type templates

### Chrome Integration

- [x] Add Chrome DevTools MCP
- [x] Configure auto-allow permissions
- [ ] Document Chrome integration setup
- [ ] Add browser automation examples
- [ ] Create testing workflows

---

## VSCode Configuration

### Settings

- [x] Configure editor settings
- [x] Enable format on save
- [x] Configure word wrap
- [x] Set MesloLGS NF font
- [x] Configure tab sizes per language
- [ ] Add workspace settings template
- [ ] Configure debugger settings
- [ ] Add task configurations
- [ ] Configure multi-root workspaces

### Extensions

- [x] Create extensions.txt list
- [x] Add Python extensions
- [x] Add JavaScript/TypeScript extensions
- [x] Add Go extensions
- [x] Add Docker extensions
- [x] Add Git extensions
- [x] Add theme extensions
- [ ] Add AI extensions (beyond Copilot)
- [ ] Add testing extensions
- [ ] Add database extensions
- [ ] Create extension profiles (minimal, web, data science)

### Keybindings

- [x] Create keybindings.json
- [ ] Add vim-like navigation
- [ ] Add terminal shortcuts
- [ ] Add git shortcuts
- [ ] Document custom keybindings

---

## Package Management

### macOS (Homebrew)

- [x] Create Brewfile
- [x] Include CLI tools
- [x] Include cask applications
- [ ] Add tap sources
- [ ] Create Brewfile.lock for versions
- [ ] Add mas (Mac App Store) apps
- [ ] Split into Brewfile.core and Brewfile.apps

### Ubuntu (apt)

- [x] Create apt.txt
- [ ] Add PPA sources
- [ ] Create apt-sources.list
- [ ] Add snap packages
- [ ] Add flatpak packages

### Rocky Linux (dnf)

- [x] Create dnf.txt
- [ ] Add EPEL repository setup
- [ ] Add Remi repository for PHP
- [ ] Create dnf-repos.txt

### Manjaro (pacman)

- [x] Create pacman.txt
- [ ] Add AUR packages (yay/paru)
- [ ] Create aur.txt for AUR packages
- [ ] Add custom repository setup

### Cross-Platform

- [ ] Create unified package manifest (YAML/TOML)
- [ ] Add version pinning support
- [ ] Create package groups (essential, development, data-science)
- [ ] Add Nix support for reproducibility

---

## Windows Support

### Setup Script

- [x] Create setup.ps1 main script
- [x] Add bloatware removal
- [x] Add telemetry disabling
- [x] Add winget package installation
- [x] Add Nerd Font installation
- [x] Add Git config deployment
- [x] Add Starship config deployment
- [x] Add VSCode config deployment
- [x] Add Claude Code deployment
- [x] Add PowerShell profile
- [x] Add installation profiles (minimal, deploy, development, full)
- [ ] Add Windows Terminal settings
- [ ] Add WSL integration
- [ ] Add scheduled task for updates
- [ ] Add system restore point creation
- [ ] Add registry backup/restore

### One-Liner Installers

- [x] Create install.ps1 for PowerShell
- [x] Create install.cmd for CMD
- [ ] Add parameter passing to one-liners
- [ ] Add error recovery

### PowerShell Profile

- [x] Configure Starship prompt
- [x] Add zoxide integration
- [x] Add basic aliases
- [ ] Add PSReadLine configuration
- [ ] Add Oh-My-Posh as alternative
- [ ] Add Posh-Git integration
- [ ] Add custom functions
- [ ] Add tab completion

### Windows Terminal

- [ ] Create settings.json
- [ ] Configure color schemes
- [ ] Configure font settings
- [ ] Add custom profiles
- [ ] Add keyboard shortcuts

---

## Remote Deployment

### SSH Deployment

- [x] Add machines.yaml configuration
- [x] Support password authentication
- [x] Support SSH key authentication
- [ ] Add host key verification
- [ ] Add connection retry logic
- [ ] Add parallel deployment
- [ ] Add deployment logging
- [ ] Add rollback on failure

### Machine Configuration

- [x] Define machine schema
- [x] Support macOS machines
- [x] Support Linux machines
- [x] Support Windows machines
- [ ] Add machine groups
- [ ] Add machine tags
- [ ] Add per-machine variables
- [ ] Add machine health checks

### Deployment Modes

- [ ] Add --dry-run for preview
- [ ] Add --diff to show changes
- [ ] Add --backup before deploy
- [ ] Add selective component deployment
- [ ] Add deployment verification

---

## TUI Installer

### Screens

- [x] Create welcome screen
- [x] Create mode selection screen
- [x] Create component selection screen
- [x] Create machine selection screen
- [x] Create progress screen
- [x] Create completion screen
- [ ] Add settings/preferences screen
- [ ] Add help screen
- [ ] Add log viewer screen
- [ ] Add diff preview screen

### Features

- [x] Real-time progress display
- [x] Component checkboxes
- [x] Machine list from YAML
- [ ] Search/filter components
- [ ] Preset profiles
- [ ] Dark/light theme toggle
- [ ] Keyboard shortcuts help
- [ ] Resume interrupted installation
- [ ] Export installation log

### UX Improvements

- [ ] Add progress percentage
- [ ] Add estimated time remaining
- [ ] Add success/failure sounds
- [ ] Add desktop notifications
- [ ] Add installation summary export
- [ ] Add undo last action

---

## Testing

### Test Suites

- [x] Create test_utils.sh for utility tests
- [x] Create test_packages.sh for package tests
- [x] Create test_configs.sh for config validation
- [x] Create test_architecture.sh for doc sync
- [x] Create test_integration.sh
- [x] Create test_functional.sh
- [ ] Create test_windows.ps1 for Windows
- [ ] Add performance benchmarks
- [ ] Add installation timing tests

### Test Coverage

- [x] Test all config files exist
- [x] Test JSON files are valid
- [x] Test scripts are executable
- [x] Test documentation sync
- [ ] Test symlink creation
- [ ] Test package installation
- [ ] Test shell startup time
- [ ] Test plugin loading
- [ ] Test alias functionality

### CI/CD

- [ ] Add GitHub Actions workflow
- [ ] Test on macOS runner
- [ ] Test on Ubuntu runner
- [ ] Test on Windows runner
- [ ] Add scheduled tests
- [ ] Add release automation
- [ ] Add changelog generation

---

## Documentation

### Core Docs

- [x] Create README.md
- [x] Create ARCHITECTURE.md with Mermaid diagrams
- [x] Create COMPATIBILITY.md
- [x] Create TODO.md (this file)
- [ ] Create CONTRIBUTING.md
- [ ] Create CHANGELOG.md
- [ ] Create FAQ.md
- [ ] Create TROUBLESHOOTING.md

### Topic Guides

- [ ] Shell customization guide
- [ ] Vim/Neovim setup guide
- [ ] Tmux usage guide
- [ ] Git workflow guide
- [ ] Claude Code integration guide
- [ ] VSCode configuration guide
- [ ] Windows setup guide
- [ ] Remote deployment guide

### Reference

- [ ] Keybinding reference card
- [ ] Alias cheat sheet
- [ ] Command quick reference
- [ ] Configuration options reference

---

## Security

### Credentials

- [x] Add machines.yaml to .gitignore
- [x] Use environment variables for secrets
- [ ] Add secret scanning pre-commit hook
- [ ] Document secret management
- [ ] Add encrypted secrets support
- [ ] Add credential rotation reminders

### Permissions

- [x] Use minimal sudo operations
- [x] Separate sudo and non-sudo modes
- [ ] Audit all permission requirements
- [ ] Document permission justifications
- [ ] Add permission verification

### Code Security

- [ ] Add shellcheck to CI
- [ ] Add security linting
- [ ] Audit third-party dependencies
- [ ] Pin dependency versions
- [ ] Add SBOM generation

---

## Future Enhancements

### Phase 1 - Near Term

- [ ] WSL (Windows Subsystem for Linux) support
- [ ] Rich progress bars in TUI
- [ ] Configuration profiles (work, personal, minimal)
- [ ] Auto-update mechanism
- [ ] Backup before update

### Phase 2 - Medium Term

- [ ] Nix/Home Manager support
- [ ] Ansible playbooks for enterprise
- [ ] Container-based installation
- [ ] Cloud sync for settings
- [ ] Web-based configuration UI

### Phase 3 - Long Term

- [ ] GUI installer (Electron/Tauri)
- [ ] Mobile companion app
- [ ] Team sharing features
- [ ] Plugin system for extensions
- [ ] AI-powered configuration suggestions

### Ideas to Explore

- [ ] Chezmoi integration
- [ ] Dotbot alternative
- [ ] yadm alternative
- [ ] GNU Stow integration
- [ ] Version-controlled secrets (age/sops)
- [ ] Configuration drift detection
- [ ] Multi-machine sync
- [ ] Time-based configuration (work hours vs personal)

---

## Quick Wins

Easy tasks to tackle first:

1. [ ] Add --dry-run flag to install.sh
2. [ ] Create .zshrc.local template
3. [ ] Add git recent alias
4. [ ] Document all keybindings
5. [ ] Add GitHub Actions basic CI
6. [ ] Create CONTRIBUTING.md
7. [ ] Add shellcheck to tests
8. [ ] Create alias cheat sheet

---

## Priority Matrix

### High Priority + Quick

- Add --dry-run flag
- Create CONTRIBUTING.md
- Document keybindings
- Add basic CI

### High Priority + Complex

- WSL support
- Configuration profiles
- Backup/restore mechanism
- Auto-update system

### Low Priority + Quick

- Add more git aliases
- Create shell functions
- Add weather function
- Theme variations

### Low Priority + Complex

- GUI installer
- Nix support
- Web configuration UI
- Plugin system

---

## Notes

- Keep this file updated as tasks are completed
- Add new ideas to appropriate sections
- Move completed items to a CHANGELOG.md
- Review priorities monthly
