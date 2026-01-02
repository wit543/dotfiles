# Dotfiles

Cross-platform dotfiles for macOS, Ubuntu, Rocky Linux, Manjaro, and Windows.

## Quick Start

### One-liner Installation

**macOS / Linux:**

```bash
# Full installation (packages + configs)
curl -fsSL https://raw.githubusercontent.com/wit543/dotfiles/main/bootstrap.sh | bash

# Config only (no sudo required)
curl -fsSL https://raw.githubusercontent.com/wit543/dotfiles/main/bootstrap.sh | bash -s -- --no-sudo

# Update existing installation
curl -fsSL https://raw.githubusercontent.com/wit543/dotfiles/main/bootstrap.sh | bash -s -- --update
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/wit543/dotfiles/main/config/windows/install.ps1 | iex
```

**Windows (CMD):**

```cmd
curl -fsSL https://raw.githubusercontent.com/wit543/dotfiles/main/config/windows/install.cmd -o install.cmd && install.cmd && del install.cmd
```

### Manual Installation

```bash
git clone https://github.com/wit543/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh          # Full installation
./install.sh --no-sudo # Config only
./install.sh --update  # Update packages and configs
```

## What's Included

### Shell (Zsh)

- **Zinit** (plugin manager) - Fast, Turbo mode for async plugin loading
- **Starship** (prompt) - Cross-shell, Rust-based, P10k-style theme
- **zoxide** (cd replacement) - Smarter directory jumping with frecency
- **Plugins**: fzf, git, docker, syntax-highlighting, autosuggestions
- **FZF** for fuzzy finding (Ctrl+R for history, Ctrl+T for files)
- **Key bindings**:
  - `Ctrl+F` - Quick jump (zce)
  - `Shift+Tab` - Accept suggestion
  - `Ctrl+H` - Jump to bookmark

### Modern CLI Tools (with fallbacks)

| Modern | Traditional | Description |
|--------|-------------|-------------|
| eza | ls | File listing with icons and git |
| bat | cat | Syntax highlighting |
| delta | diff | Better git diffs |
| dust | du | Disk usage visualization |
| procs | ps | Process viewer |
| fd | find | Fast file finder |
| sd | sed | Find & replace |
| ripgrep | grep | Fast search |

*Note: Falls back silently to traditional tools if modern versions unavailable*

### TUI Productivity Tools

| Tool | Alias | Description |
|------|-------|-------------|
| lazygit | `lg` | Git terminal UI |
| lazydocker | `lzd` | Docker terminal UI |

### Editor (Neovim/Vim)

- **vim-plug** for plugin management
- **40+ plugins** including:
  - EasyMotion, FZF integration, NERDTree
  - vim-surround, vim-fugitive, vim-gitgutter
  - Gruvbox colorscheme, Airline status line
  - Vimtex for LaTeX support
- **Key mappings**:
  - `Ctrl+S` - Save
  - `Ctrl+N` - NERDTree toggle
  - `Space` - EasyMotion search
  - `F2-F5` - File navigation

### Terminal Multiplexer (Tmux)

- **TPM** (Tmux Plugin Manager)
- Based on **gpakosz/.tmux** configuration
- **Plugins**: resurrect, continuum, yank, sysstat
- **Key features**:
  - Mouse support enabled
  - Session auto-restore
  - Vi copy mode

### VSCode

- **Word wrap enabled by default**
- **Format on save**
- **40+ extensions** for Python, JavaScript/TypeScript, Go, Docker, etc.
- **Themes**: One Dark Pro, Material Icons
- **Key settings**:
  - Tab size: 4 (2 for JS/TS/JSON/YAML)
  - Font: MesloLGS NF with ligatures
  - Auto-save enabled
  - Trailing whitespace trimming

### Claude Code

- **WebSearch & WebFetch** always allowed (no prompts)
- **MCP Servers**: Context7 for library documentation
- **Global CLAUDE.md** with coding standards across all projects
- **Pre-approved commands** for safe operations (git, npm, pytest, etc.)
- **Deployed to**:
  - `~/.claude/` - User-level config (CLI + VSCode extension)
  - `%APPDATA%\claude-code\` - Windows CLI config
- **Coding standards**:
  - Conventional commits format
  - Language-specific style guides
  - Security best practices
  - Testing requirements

### macOS Apps (via Homebrew)

| Application | Description |
|------------|-------------|
| iTerm2 | Terminal emulator |
| Visual Studio Code | Code editor |
| Docker Desktop | Container platform |
| Google Chrome | Web browser |
| Google Cloud SDK | gcloud, gsutil, bq |

## Supported Platforms

| Platform | Package Manager | Status |
|----------|----------------|--------|
| macOS | Homebrew | Full support |
| Ubuntu | apt | Full support |
| Rocky Linux | dnf | Full support |
| Manjaro | pacman | Full support |
| Windows 11 | winget | Full support |

### Windows Setup

The Windows installer provides full feature parity with macOS/Linux:

**System Tweaks:**

- Remove 80+ bloatware apps (Cortana, Bing, Candy Crush, etc.)
- Disable telemetry, ads, and Copilot
- Hibernate disabled
- Cursor: Black, 150% size

**CLI Tools (via winget):**

| Tool | Description |
| ---- | ----------- |
| git, neovim | Version control, editor |
| fzf, ripgrep, fd | Fuzzy finder, fast search |
| bat, eza, delta | Modern cat, ls, diff |
| zoxide, starship | Smart cd, cross-shell prompt |
| jq, yq, tldr, dust | JSON/YAML, man pages, disk usage |

**TUI Productivity:**

| Tool | Alias | Description |
| ---- | ----- | ----------- |
| lazygit | `lg` | Git terminal UI |
| lazydocker | `lzd` | Docker terminal UI |
| btop | - | System monitor |

**Development:**

- Node.js, Python 3.12, Go
- Docker Desktop

**Applications:**

- Chrome (set as default)
- VSCode (with settings + extensions)
- Windows Terminal

**Configs Deployed:**

- Git config (with delta)
- Starship prompt
- VSCode settings & keybindings
- Claude Code (WebSearch, WebFetch, MCP, CLAUDE.md)
- PowerShell profile with aliases

Run as Administrator for full functionality.

## Directory Structure

```
dotfiles/
├── bootstrap.sh           # Curl-able entry point
├── install.sh             # Main installer
├── lib/
│   ├── utils.sh           # Logging, symlink helpers
│   ├── os.sh              # OS detection
│   └── packages.sh        # Package manager abstraction
├── config/
│   ├── zsh/               # Zsh configuration
│   │   ├── .zshrc         # Main config (Zinit + Starship)
│   │   └── starship.toml  # Starship prompt theme
│   ├── vim/               # Vim configuration
│   │   ├── .vimrc         # Main config
│   │   ├── .gvimrc        # GUI config
│   │   ├── .vim.function  # Custom functions
│   │   └── colors/        # Color schemes
│   ├── nvim/              # Neovim configuration
│   │   └── init.vim       # Sources .vimrc
│   ├── tmux/              # Tmux configuration
│   │   ├── .tmux.conf     # Base config (gpakosz)
│   │   └── .tmux.conf.local # User customizations
│   ├── git/               # Git configuration
│   │   └── .gitconfig     # Global git config (with delta)
│   ├── vscode/            # VSCode configuration
│   │   ├── settings.json  # User settings
│   │   └── extensions.txt # Extensions list
│   ├── claude/            # Claude Code configuration
│   │   ├── CLAUDE.md      # Global coding standards
│   │   └── settings.json  # Permissions & settings
│   └── windows/           # Windows configuration
│       ├── setup.ps1      # Full setup script
│       ├── install.ps1    # One-liner (PowerShell)
│       └── install.cmd    # One-liner (CMD)
└── packages/
    ├── Brewfile           # macOS packages
    ├── apt.txt            # Ubuntu/Debian packages
    ├── dnf.txt            # Rocky/RHEL packages
    └── pacman.txt         # Manjaro/Arch packages
```

## Customization

### Local Configuration

Add machine-specific settings to `~/.zshrc.local` (not tracked by git):

```bash
# ~/.zshrc.local
export MY_CUSTOM_VAR="value"
alias myalias="my-command"

# Work-specific settings
export WORK_API_KEY="xxx"
```

### Adding Packages

Edit the appropriate package file:

- **macOS**: `packages/Brewfile`
- **Ubuntu**: `packages/apt.txt`
- **Rocky**: `packages/dnf.txt`
- **Manjaro**: `packages/pacman.txt`

### Starship Prompt Customization

Edit `~/.config/starship.toml` to customize the prompt:

```toml
# Change prompt character
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"

# Disable git status
[git_status]
disabled = true
```

See [Starship docs](https://starship.rs/config/) for all options.

### VSCode Settings

Edit `~/dotfiles/config/vscode/settings.json` directly - it's symlinked to your VSCode config.

To add/remove extensions, edit `~/dotfiles/config/vscode/extensions.txt`:

```bash
# Add extension
echo "publisher.extension-name" >> ~/dotfiles/config/vscode/extensions.txt

# Install all extensions
cat ~/dotfiles/config/vscode/extensions.txt | grep -v '^#' | xargs -L 1 code --install-extension
```

### Claude Code Settings

Edit `~/dotfiles/config/claude/CLAUDE.md` to customize global coding standards:

```markdown
# Add project-specific rules
## My Custom Rules
- Always use TypeScript strict mode
- Prefer functional components in React
```

Edit `~/dotfiles/config/claude/settings.json` to add pre-approved commands:

```json
{
  "permissions": {
    "allow": [
      "Bash(my-custom-command:*)"
    ]
  }
}
```

For project-specific overrides, create a `CLAUDE.md` in your project root.

### Conda Environment

The `.zshrc` automatically detects and initializes Conda from common paths:

- `/opt/anaconda3`
- `$HOME/anaconda3`
- `$HOME/miniconda3`

To use a specific environment by default, edit the `conda activate` line in `.zshrc`.

## Key Bindings Reference

### Zsh

| Key | Action |
|-----|--------|
| `Ctrl+R` | FZF history search |
| `Ctrl+T` | FZF file search |
| `Alt+C` | FZF cd to directory |
| `Ctrl+F` | Quick jump (zce) |
| `Shift+Tab` | Accept autosuggestion |
| `z <path>` | Jump to directory (zoxide) |
| `zi` | Interactive directory selection |

### Modern Tool Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | eza | List with icons |
| `ll` | eza -lah | Long list with git status |
| `lt` | eza --tree | Tree view |
| `cat` | bat | View with syntax highlighting |
| `catp` | bat (full) | With pager |
| `du` | dust | Disk usage |
| `psa` | procs | Process list |
| `pst` | procs --tree | Process tree |
| `f` | fd | Fast find |
| `replace` | sd | Find & replace |
| `lg` | lazygit | Git TUI |
| `lzd` | lazydocker | Docker TUI |

### Vim/Neovim

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+S` | Normal/Insert | Save file |
| `Ctrl+N` | Normal | Toggle NERDTree |
| `Space` | Normal | EasyMotion search |
| `Ctrl+J/K` | Normal | EasyMotion line jump |
| `F2` | Normal | FuzzyFinder |
| `F3` | Normal | Buffer list |
| `F4` | Normal | MRU files |
| `F8` | Normal | Tagbar toggle |
| `\m` | Normal | Make current file |

### Tmux

| Key | Action |
|-----|--------|
| `Prefix + I` | Install plugins |
| `Prefix + U` | Update plugins |
| `Prefix + r` | Reload config |
| `Prefix + e` | Edit local config |
| `Prefix + -` | Split horizontal |
| `Prefix + _` | Split vertical |
| `Prefix + m` | Toggle mouse |

## Troubleshooting

### Zinit plugins not loading

```bash
# Reinstall Zinit and plugins
rm -rf ~/.local/share/zinit
exec zsh
```

### Starship prompt not showing

```bash
# Verify starship is installed
starship --version

# Reinstall if needed
curl -sS https://starship.rs/install.sh | sh

# Check config
starship config
```

### Vim plugins not installed

```bash
# Install vim-plug plugins
vim +PlugInstall +qall
# or for Neovim
nvim +PlugInstall +qall
```

### Tmux plugins not installed

```bash
# Start tmux and press Prefix + I
tmux
# Then press: Ctrl+B, Shift+I
```

### Icons not showing (boxes instead)

Install a Nerd Font:

```bash
# macOS
brew install --cask font-meslo-lg-nerd-font

# Then set your terminal font to "MesloLGS NF"
```

### zoxide not jumping

```bash
# zoxide needs to learn directories first
# Visit directories normally, then use z:
cd ~/projects/myapp
cd ~/documents
z myapp  # Now it knows about myapp!
```

### VSCode settings not applying

```bash
# Check if settings are symlinked correctly
ls -la ~/Library/Application\ Support/Code/User/settings.json  # macOS
ls -la ~/.config/Code/User/settings.json                       # Linux

# Re-run setup
cd ~/dotfiles && ./install.sh --update
```

### VSCode extensions not installing

```bash
# Install manually
code --install-extension publisher.extension-name

# Or install all from list
cat ~/dotfiles/config/vscode/extensions.txt | grep -v '^#' | xargs -L 1 code --install-extension
```

## Migration from Oh-My-Zsh

If upgrading from the previous version with Oh-My-Zsh:

```bash
# Backup and remove old configs
mv ~/.oh-my-zsh ~/.oh-my-zsh.bak
rm -f ~/.p10k.zsh

# Re-run installer
cd ~/dotfiles && git pull
./install.sh --update
```

## License

MIT

## Author

Norawit Urailertprasert ([@wit543](https://github.com/wit543))
