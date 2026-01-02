# Compatibility Matrix

Detailed compatibility information for all supported platforms and components.

## Platform Support Matrix

| Feature | macOS | Ubuntu | Rocky Linux | Manjaro | Windows 11 |
|---------|-------|--------|-------------|---------|------------|
| **Installation** |
| One-liner install | ✓ curl | ✓ curl | ✓ curl | ✓ curl | ✓ irm/iex |
| TUI installer | ✓ | ✓ | ✓ | ✓ | ✗ |
| Remote deploy | ✓ | ✓ | ✓ | ✓ | ✓ (SSH) |
| **Package Manager** |
| Primary | Homebrew | apt | dnf | pacman | winget |
| Package file | Brewfile | apt.txt | dnf.txt | pacman.txt | setup.ps1 |
| **Shell** |
| Default shell | zsh | zsh | zsh | zsh | PowerShell |
| Plugin manager | Zinit | Zinit | Zinit | Zinit | N/A |
| Prompt | Starship | Starship | Starship | Starship | Starship |
| **Config Deployment** |
| Method | symlink | symlink | symlink | symlink | copy |
| User config | ~/.config/ | ~/.config/ | ~/.config/ | ~/.config/ | %APPDATA% |

## CLI Tools Compatibility

| Tool | macOS | Ubuntu | Rocky | Manjaro | Windows | Fallback |
|------|-------|--------|-------|---------|---------|----------|
| **Core** |
| git | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| neovim | ✓ | ✓ | ✓ | ✓ | ✓ | vim |
| tmux | ✓ | ✓ | ✓ | ✓ | ✗ | - |
| **Modern Replacements** |
| eza | ✓ | ✓ | ✓ | ✓ | ✓ | ls |
| bat | ✓ | ✓ | ✓ | ✓ | ✓ | cat |
| delta | ✓ | ✓ | ✓ | ✓ | ✓ | diff |
| fd | ✓ | ✓ | ✓ | ✓ | ✓ | find |
| ripgrep | ✓ | ✓ | ✓ | ✓ | ✓ | grep |
| dust | ✓ | ✓ | ✓ | ✓ | ✓ | du |
| procs | ✓ | ✓ | ✓ | ✓ | ✗ | ps |
| sd | ✓ | ✓ | ✓ | ✓ | ✗ | sed |
| **Navigation** |
| fzf | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| zoxide | ✓ | ✓ | ✓ | ✓ | ✓ | cd |
| **Data Processing** |
| jq | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| yq | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| **TUI Tools** |
| lazygit | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| lazydocker | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| btop | ✓ | ✓ | ✓ | ✓ | ✓ | htop/top |

## Zsh Plugin Compatibility

| Plugin | Purpose | Load Time | Dependencies |
|--------|---------|-----------|--------------|
| zsh-autosuggestions | Command suggestions | wait"1" | - |
| zsh-syntax-highlighting | Syntax colors | wait"0" | - |
| zsh-completions | Extra completions | wait"2" | - |
| fzf-tab | FZF completion menu | wait"2" | fzf |

## Configuration File Mapping

### Unix Systems (macOS/Linux)

| Source | Target | Method |
|--------|--------|--------|
| config/zsh/.zshrc | ~/.zshrc | symlink |
| config/zsh/starship.toml | ~/.config/starship.toml | symlink |
| config/vim/.vimrc | ~/.vimrc | symlink |
| config/vim/.gvimrc | ~/.gvimrc | symlink |
| config/nvim/init.vim | ~/.config/nvim/init.vim | symlink |
| config/tmux/.tmux.conf | ~/.tmux.conf | symlink |
| config/tmux/.tmux.conf.local | ~/.tmux.conf.local | symlink |
| config/git/.gitconfig | ~/.gitconfig | symlink |
| config/git/.gitignore_global | ~/.gitignore_global | symlink |
| config/vscode/settings.json | ~/Library/Application Support/Code/User/settings.json (macOS) | symlink |
| config/vscode/settings.json | ~/.config/Code/User/settings.json (Linux) | symlink |
| config/claude/settings.json | ~/.claude/settings.json | symlink |
| config/claude/CLAUDE.md | ~/.claude/CLAUDE.md | symlink |

### Windows

| Source | Target | Method |
|--------|--------|--------|
| config/git/.gitconfig | %USERPROFILE%\\.gitconfig | copy |
| config/zsh/starship.toml | %USERPROFILE%\\.config\\starship.toml | copy |
| config/vscode/settings.json | %APPDATA%\\Code\\User\\settings.json | copy |
| config/vscode/keybindings.json | %APPDATA%\\Code\\User\\keybindings.json | copy |
| config/claude/settings.json | %APPDATA%\\claude-code\\settings.json | copy |
| config/claude/settings.json | %USERPROFILE%\\.claude\\settings.json | copy |
| config/claude/CLAUDE.md | %USERPROFILE%\\.claude\\CLAUDE.md | copy |

## Claude Code Permissions

### Always Allowed (No Prompt)

| Category | Permissions |
|----------|-------------|
| **Web** | WebSearch, WebFetch |
| **MCP** | mcp__context7 |
| **Git (read)** | git status, git diff, git log, git branch, git show, git stash, git fetch, git remote, git rev-parse, git ls-files, git config --get |
| **Git (write)** | git add |
| **File ops** | ls, cat, find, head, tail, wc, grep, rg, fd, fdfind, tree, pwd, which, echo, env, printenv, date, uname, file, stat, du, df |
| **Node.js** | npm run, npm test, npm lint, npm build, npm list, npm outdated, npm ls, yarn/pnpm equivalents |
| **Python** | pytest, python -m pytest, python --version, pip list, pip show, pip freeze, poetry show |
| **Go** | go test, go build, go list, go version, go mod tidy |
| **Rust** | cargo test, cargo build, cargo check, cargo clippy, cargo fmt --check |
| **Make** | make, make test, make build, make lint |
| **Docker** | docker ps, docker images, docker logs, docker inspect, docker-compose ps, docker-compose logs |
| **K8s** | kubectl get, kubectl describe, kubectl logs |
| **Terraform** | terraform plan, terraform validate, terraform fmt |
| **Data** | jq, yq, curl -s, http |

## Version Requirements

| Component | Minimum Version | Recommended |
|-----------|-----------------|-------------|
| macOS | 12.0 (Monterey) | 14.0+ (Sonoma) |
| Ubuntu | 20.04 LTS | 24.04 LTS |
| Rocky Linux | 8.0 | 9.0+ |
| Manjaro | 21.0 | Latest |
| Windows | 10 (1903) | 11 |
| Zsh | 5.8 | 5.9+ |
| Git | 2.30 | 2.40+ |
| Node.js | 18.0 | 20.0+ |
| Python | 3.9 | 3.12+ |

## Known Limitations

### Windows
- No tmux support (Windows Terminal provides tabs/panes)
- No procs/sd tools (use native alternatives)
- Symlinks require admin or developer mode
- Some Unix tools behave differently

### Linux (without sudo)
- Cannot install system packages
- Limited to user-space installations
- Some tools may need manual PATH configuration

### Remote Deployment
- Requires SSH access
- Windows remote requires OpenSSH server
- Password auth needs sshpass installed locally

## Feature Flags

| Flag | Description | Platforms |
|------|-------------|-----------|
| --sudo | Full installation with packages | Unix only |
| --no-sudo | Config-only installation | Unix only |
| --update | Update existing installation | All |
| --remote | Deploy to remote machine | Unix (TUI) |

## Testing Coverage

The test suite validates:

1. **Configuration Files** - All config files exist and are valid
2. **Package Definitions** - Package lists for each platform
3. **Script Functions** - Utility and setup functions
4. **Integration** - End-to-end installation flow
5. **Architecture Sync** - Documentation matches implementation

Run tests with:
```bash
./tests/run_all.sh        # Full test suite
./tests/run_all.sh --quick # Skip integration tests
```
