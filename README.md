# Dotfiles

Cross-platform dotfiles for macOS, Ubuntu, Rocky Linux, and Manjaro.

## Quick Start

### One-liner Installation

```bash
# Full installation (packages + configs)
curl -fsSL https://raw.githubusercontent.com/wit543/dotfiles/main/bootstrap.sh | bash

# Config only (no sudo required)
curl -fsSL https://raw.githubusercontent.com/wit543/dotfiles/main/bootstrap.sh | bash -s -- --no-sudo

# Update existing installation
curl -fsSL https://raw.githubusercontent.com/wit543/dotfiles/main/bootstrap.sh | bash -s -- --update
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

- **Oh My Zsh** with Powerlevel10k theme
- **Plugins**: fzf, z, git, docker, syntax-highlighting, autosuggestions
- **FZF** for fuzzy finding (Ctrl+R for history, Ctrl+T for files)
- **Key bindings**:
  - `Ctrl+F` - Quick jump (zce)
  - `Shift+Tab` - Accept suggestion
  - `Ctrl+H` - Jump to bookmark

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
│   │   ├── .zshrc         # Main config
│   │   └── .p10k.zsh      # Powerlevel10k theme
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
│   └── git/               # Git configuration
│       └── .gitconfig     # Global git config
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

### Zsh plugins not loading

```bash
# Reinstall plugins
rm -rf ~/.zsh
exec zsh
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

### Powerlevel10k icons not showing

Install a Nerd Font:

```bash
# macOS
brew install --cask font-meslo-lg-nerd-font

# Then set your terminal font to "MesloLGS NF"
```

## License

MIT

## Author

Norawit Urailertprasert ([@wit543](https://github.com/wit543))
