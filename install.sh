#!/usr/bin/env bash
# ============================================================================
#                         DOTFILES INSTALLER
#                    github.com/wit543/dotfiles
# ============================================================================
# Main installation script for dotfiles
#
# Usage:
#   ./install.sh                      # Interactive profile selection
#   ./install.sh --profile=minimal    # Minimal setup (servers)
#   ./install.sh --profile=deploy     # Deploy machine (+ docker)
#   ./install.sh --profile=development # Dev environment (+ editors)
#   ./install.sh --profile=full       # Everything (+ AI tools)
#   ./install.sh --no-sudo            # Config only (no packages)
#   ./install.sh --update             # Update packages and configs
#   ./install.sh --list-profiles      # Show available profiles
#
# Supports: macOS, Ubuntu, Rocky Linux, Manjaro
# ============================================================================

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

# ============================================================================
# SOURCE LIBRARIES
# ============================================================================

# shellcheck source=lib/utils.sh
source "$SCRIPT_DIR/lib/utils.sh"
# shellcheck source=lib/os.sh
source "$SCRIPT_DIR/lib/os.sh"
# shellcheck source=lib/packages.sh
source "$SCRIPT_DIR/lib/packages.sh"
# shellcheck source=lib/profiles.sh
source "$SCRIPT_DIR/lib/profiles.sh"

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

USE_SUDO=true
UPDATE_MODE=false
PROFILE=""
COMPONENTS=""
INTERACTIVE=false

for arg in "$@"; do
    case "$arg" in
        --no-sudo)
            USE_SUDO=false
            ;;
        --sudo)
            USE_SUDO=true
            ;;
        --update)
            UPDATE_MODE=true
            USE_SUDO=true
            ;;
        --profile=*)
            PROFILE="${arg#*=}"
            ;;
        --components=*)
            COMPONENTS="${arg#*=}"
            ;;
        --interactive|-i)
            INTERACTIVE=true
            ;;
        --list-profiles)
            list_profiles
            exit 0
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --profile=NAME   Use installation profile (minimal|deploy|development|full)"
            echo "  --components=... Comma-separated list of components to install"
            echo "  --interactive    Interactive profile/component selection"
            echo "  --sudo           Install packages + configs (default)"
            echo "  --no-sudo        Config only, skip package installation"
            echo "  --update         Update packages and pull latest configs"
            echo "  --list-profiles  Show available profiles and components"
            echo "  -h, --help       Show this help message"
            echo ""
            echo "Profiles:"
            echo "  minimal     - Basic shell (zsh, git, editorconfig)"
            echo "  deploy      - Deployment (minimal + docker)"
            echo "  development - Dev environment (+ vim, tmux, vscode)"
            echo "  full        - Everything (+ claude AI)"
            echo ""
            echo "Examples:"
            echo "  $0 --profile=minimal           # Server setup"
            echo "  $0 --profile=development       # Dev workstation"
            echo "  $0 --components=zsh,git,vim    # Custom selection"
            exit 0
            ;;
    esac
done

# Detect operating system
detect_os

# ============================================================================
# ZSH SETUP
# ============================================================================
# NOTE: Installs Zinit (plugin manager), Starship (prompt), zoxide (cd)

setup_zsh() {
    log_info "Setting up Zsh with Zinit + Starship..."

    # --------------------------
    # Zinit (Plugin Manager)
    # --------------------------
    # NOTE: Zinit auto-installs on first shell startup via .zshrc
    #       This pre-install ensures it's ready before first use
    local ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
    if [[ ! -d "$ZINIT_HOME" ]]; then
        log_info "Installing Zinit..."
        mkdir -p "$(dirname "$ZINIT_HOME")"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    else
        log_success "Zinit already installed"
        if $UPDATE_MODE; then
            git_update "$ZINIT_HOME"
        fi
    fi

    # --------------------------
    # Starship (Prompt)
    # --------------------------
    if ! command_exists starship; then
        log_info "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        log_success "Starship already installed"
        if $UPDATE_MODE && ! is_macos; then
            # Update starship (macOS updates via brew)
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        fi
    fi

    # --------------------------
    # Zoxide (Directory Jumping)
    # --------------------------
    if ! command_exists zoxide; then
        log_info "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    else
        log_success "zoxide already installed"
    fi

    # --------------------------
    # FZF (Fuzzy Finder)
    # --------------------------
    git_clone "https://github.com/junegunn/fzf.git" "$HOME/.fzf"
    if $UPDATE_MODE; then
        git_update "$HOME/.fzf"
    fi
    if [[ -f "$HOME/.fzf/install" ]]; then
        "$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
    fi

    # --------------------------
    # TUI Tools (Linux only - macOS uses brew)
    # --------------------------
    if is_linux; then
        install_lazygit
        install_lazydocker
    fi

    # --------------------------
    # Starship Config Directory
    # --------------------------
    mkdir -p "$HOME/.config"

    # --------------------------
    # Symlinks
    # --------------------------
    symlink "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
    symlink "$DOTFILES_DIR/config/zsh/starship.toml" "$HOME/.config/starship.toml"

    log_success "Zsh setup complete"
}

# ============================================================================
# LAZYGIT INSTALLATION (Linux)
# ============================================================================

install_lazygit() {
    if command_exists lazygit; then
        log_success "lazygit already installed"
        return 0
    fi

    log_info "Installing lazygit..."
    local LAZYGIT_VERSION
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

    if [[ -n "$LAZYGIT_VERSION" ]]; then
        local arch
        arch=$(uname -m)
        case "$arch" in
            x86_64) arch="x86_64" ;;
            aarch64) arch="arm64" ;;
            *) log_warn "Unsupported architecture for lazygit: $arch"; return 1 ;;
        esac

        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${arch}.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
        install /tmp/lazygit "$HOME/.local/bin/lazygit" 2>/dev/null || sudo install /tmp/lazygit /usr/local/bin/lazygit
        rm -f /tmp/lazygit.tar.gz /tmp/lazygit
        log_success "lazygit installed"
    else
        log_warn "Could not determine lazygit version"
    fi
}

# ============================================================================
# LAZYDOCKER INSTALLATION (Linux)
# ============================================================================

install_lazydocker() {
    if command_exists lazydocker; then
        log_success "lazydocker already installed"
        return 0
    fi

    log_info "Installing lazydocker..."
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    log_success "lazydocker installed"
}

# ============================================================================
# VIM / NEOVIM SETUP
# ============================================================================
# NOTE: Installs vim-plug and plugins for both Vim and Neovim

setup_vim() {
    log_info "Setting up Vim/Neovim..."

    # --------------------------
    # Create Directories
    # --------------------------
    mkdir -p "$HOME/.vim/autoload"
    mkdir -p "$HOME/.vim/colors"
    mkdir -p "$HOME/.config/nvim"

    # --------------------------
    # Symlinks
    # --------------------------
    symlink "$DOTFILES_DIR/config/vim/.vimrc" "$HOME/.vimrc"
    symlink "$DOTFILES_DIR/config/vim/.gvimrc" "$HOME/.gvimrc"
    symlink "$DOTFILES_DIR/config/vim/.vim.function" "$HOME/.vim.function"
    symlink "$DOTFILES_DIR/config/vim/colors/gruvbox.vim" "$HOME/.vim/colors/gruvbox.vim"
    symlink "$DOTFILES_DIR/config/nvim/init.vim" "$HOME/.config/nvim/init.vim"

    # --------------------------
    # vim-plug (Plugin Manager)
    # --------------------------
    # Install for Vim
    if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
        log_info "Installing vim-plug..."
        curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    # Install for Neovim
    if [[ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]]; then
        curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    # --------------------------
    # Install Plugins
    # --------------------------
    if command_exists nvim; then
        log_info "Installing Neovim plugins..."
        nvim --headless +PlugInstall +qall 2>/dev/null || true
        if $UPDATE_MODE; then
            nvim --headless +PlugUpdate +qall 2>/dev/null || true
        fi
    elif command_exists vim; then
        log_info "Installing Vim plugins..."
        vim +PlugInstall +qall 2>/dev/null || true
        if $UPDATE_MODE; then
            vim +PlugUpdate +qall 2>/dev/null || true
        fi
    fi

    log_success "Vim/Neovim setup complete"
}

# ============================================================================
# PYTHON / MICROMAMBA SETUP
# ============================================================================
# NOTE: Installs micromamba and creates the troik environment

setup_python() {
    log_info "Setting up Python with micromamba..."

    local MAMBA_ROOT="$HOME/.local/share/mamba"
    local MAMBA_BIN="$HOME/.local/bin/micromamba"

    # --------------------------
    # Install micromamba
    # --------------------------
    if [[ ! -f "$MAMBA_BIN" ]]; then
        log_info "Installing micromamba..."
        mkdir -p "$HOME/.local/bin"

        # Download and install micromamba
        if is_macos; then
            if [[ "$(uname -m)" == "arm64" ]]; then
                curl -Ls https://micro.mamba.pm/api/micromamba/osx-arm64/latest | tar -xvj -C "$HOME/.local/bin" --strip-components=1 bin/micromamba
            else
                curl -Ls https://micro.mamba.pm/api/micromamba/osx-64/latest | tar -xvj -C "$HOME/.local/bin" --strip-components=1 bin/micromamba
            fi
        else
            # Linux
            if [[ "$(uname -m)" == "aarch64" ]]; then
                curl -Ls https://micro.mamba.pm/api/micromamba/linux-aarch64/latest | tar -xvj -C "$HOME/.local/bin" --strip-components=1 bin/micromamba
            else
                curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj -C "$HOME/.local/bin" --strip-components=1 bin/micromamba
            fi
        fi
        log_success "micromamba installed"
    else
        log_success "micromamba already installed"
        if $UPDATE_MODE; then
            log_info "Updating micromamba..."
            "$MAMBA_BIN" self-update || true
        fi
    fi

    # --------------------------
    # Initialize micromamba
    # --------------------------
    mkdir -p "$MAMBA_ROOT"
    export MAMBA_ROOT_PREFIX="$MAMBA_ROOT"

    # --------------------------
    # Create troik environment
    # --------------------------
    if [[ -f "$DOTFILES_DIR/config/python/troik-environment.yml" ]]; then
        if [[ ! -d "$MAMBA_ROOT/envs/troik" ]]; then
            log_info "Creating troik environment..."
            "$MAMBA_BIN" create -n troik -f "$DOTFILES_DIR/config/python/troik-environment.yml" -y
            log_success "troik environment created"
        else
            log_success "troik environment already exists"
            if $UPDATE_MODE; then
                log_info "Updating troik environment..."
                "$MAMBA_BIN" update -n troik --all -y || true
            fi
        fi
    fi

    log_success "Python setup complete"
}

# ============================================================================
# TMUX SETUP
# ============================================================================
# NOTE: Uses gpakosz/.tmux configuration with TPM

setup_tmux() {
    log_info "Setting up Tmux..."

    # --------------------------
    # TPM (Tmux Plugin Manager)
    # --------------------------
    git_clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
    if $UPDATE_MODE; then
        git_update "$HOME/.tmux/plugins/tpm"
    fi

    # --------------------------
    # Symlinks
    # --------------------------
    symlink "$DOTFILES_DIR/config/tmux/.tmux.conf" "$HOME/.tmux.conf"
    symlink "$DOTFILES_DIR/config/tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"

    log_success "Tmux setup complete"
}

# ============================================================================
# GIT SETUP
# ============================================================================

setup_git() {
    log_info "Setting up Git..."

    symlink "$DOTFILES_DIR/config/git/.gitconfig" "$HOME/.gitconfig"
    symlink "$DOTFILES_DIR/config/git/.gitignore_global" "$HOME/.gitignore_global"

    log_success "Git setup complete"
}

# ============================================================================
# EDITOR CONFIG SETUP
# ============================================================================
# NOTE: Universal editor settings (works with VSCode, Vim, etc.)

setup_editorconfig() {
    log_info "Setting up EditorConfig..."

    symlink "$DOTFILES_DIR/config/editor/.editorconfig" "$HOME/.editorconfig"

    log_success "EditorConfig setup complete"
}

# ============================================================================
# VSCODE SETUP
# ============================================================================
# NOTE: Syncs settings and installs extensions

setup_vscode() {
    log_info "Setting up VSCode..."

    # Determine VSCode settings path based on OS
    local vscode_settings_dir
    if is_macos; then
        vscode_settings_dir="$HOME/Library/Application Support/Code/User"
    else
        vscode_settings_dir="$HOME/.config/Code/User"
    fi

    # Check if VSCode is installed
    if ! command_exists code; then
        log_warn "VSCode not installed, skipping settings sync"
        log_info "Install VSCode first, then run: ./install.sh --update"
        return 0
    fi

    # --------------------------
    # Settings & Keybindings
    # --------------------------
    mkdir -p "$vscode_settings_dir"
    symlink "$DOTFILES_DIR/config/vscode/settings.json" "$vscode_settings_dir/settings.json"
    symlink "$DOTFILES_DIR/config/vscode/keybindings.json" "$vscode_settings_dir/keybindings.json"

    # --------------------------
    # Extensions
    # --------------------------
    if [[ -f "$DOTFILES_DIR/config/vscode/extensions.txt" ]]; then
        log_info "Installing VSCode extensions..."
        local extension
        while IFS= read -r line; do
            # Skip comments and empty lines
            [[ "$line" =~ ^#.*$ ]] && continue
            [[ -z "$line" ]] && continue

            # Extract extension ID (first word, ignore comments)
            extension=$(echo "$line" | awk '{print $1}')
            [[ -z "$extension" ]] && continue

            # Install extension (silently skip if already installed)
            code --install-extension "$extension" --force 2>/dev/null || true
        done < "$DOTFILES_DIR/config/vscode/extensions.txt"
        log_success "VSCode extensions installed"
    fi

    log_success "VSCode setup complete"
}

# ============================================================================
# CLAUDE CODE SETUP
# ============================================================================
# NOTE: Sets up Claude Code CLI with global standards

setup_claude() {
    log_info "Setting up Claude Code..."

    # --------------------------
    # Global Claude Directory
    # --------------------------
    mkdir -p "$HOME/.claude"

    # --------------------------
    # Global Settings
    # --------------------------
    symlink "$DOTFILES_DIR/config/claude/settings.json" "$HOME/.claude/settings.json"

    # --------------------------
    # Global CLAUDE.md (coding standards)
    # --------------------------
    symlink "$DOTFILES_DIR/config/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

    log_success "Claude Code setup complete"
}

# ============================================================================
# MACOS SETUP
# ============================================================================
# NOTE: macOS-specific configurations

setup_macos() {
    if ! is_macos; then
        return 0
    fi

    log_info "Applying macOS-specific settings..."

    # --------------------------
    # Default Shell
    # --------------------------
    if [[ "$SHELL" != *"zsh"* ]]; then
        local zsh_path
        zsh_path=$(which zsh)
        if grep -q "$zsh_path" /etc/shells 2>/dev/null; then
            log_info "Changing default shell to zsh..."
            chsh -s "$zsh_path"
        fi
    fi

    # --------------------------
    # macOS Defaults (appearance, power, finder, dock, etc.)
    # --------------------------
    if [[ -f "$DOTFILES_DIR/config/macos/defaults.sh" ]]; then
        log_info "Applying macOS defaults..."
        "$DOTFILES_DIR/config/macos/defaults.sh"
    fi

    # --------------------------
    # Google Cloud SDK
    # --------------------------
    if [[ -d "/opt/homebrew/Caskroom/google-cloud-sdk" ]]; then
        log_success "Google Cloud SDK installed via Homebrew"
    fi

    log_success "macOS setup complete"
}

# ============================================================================
# PACKAGE INSTALLATION
# ============================================================================

install_packages() {
    log_info "Installing packages..."

    case "$PKG_MGR" in
        brew)
            install_homebrew
            pkg_update
            install_from_brewfile "$DOTFILES_DIR/packages/Brewfile"
            ;;
        apt)
            pkg_update
            pkg_install_from_file "$DOTFILES_DIR/packages/apt.txt"
            ;;
        dnf|yum)
            pkg_update
            pkg_install_from_file "$DOTFILES_DIR/packages/dnf.txt"
            ;;
        pacman)
            pkg_update
            pkg_install_from_file "$DOTFILES_DIR/packages/pacman.txt"
            ;;
        *)
            log_warn "Unknown package manager: $PKG_MGR"
            ;;
    esac

    log_success "Package installation complete"
}

# ============================================================================
# PACKAGE UPGRADE
# ============================================================================

upgrade_packages() {
    log_info "Upgrading packages..."

    case "$PKG_MGR" in
        brew)
            pkg_update
            pkg_upgrade
            install_from_brewfile "$DOTFILES_DIR/packages/Brewfile"
            ;;
        apt)
            pkg_update
            pkg_upgrade
            ;;
        dnf|yum)
            pkg_update
            pkg_upgrade
            ;;
        pacman)
            pkg_upgrade
            ;;
    esac

    log_success "Package upgrade complete"
}

# ============================================================================
# COMPONENT SELECTION
# ============================================================================

# Check if a component should be installed
should_install() {
    local component="$1"
    [[ " $SELECTED_COMPONENTS " == *" $component "* ]]
}

# Resolve components from profile or custom list
resolve_components() {
    # If components specified directly, use them
    if [[ -n "$COMPONENTS" ]]; then
        SELECTED_COMPONENTS="${COMPONENTS//,/ }"
        return
    fi

    # If profile specified, get its components
    if [[ -n "$PROFILE" ]]; then
        if validate_profile "$PROFILE"; then
            SELECTED_COMPONENTS=$(get_profile_components "$PROFILE")
        else
            log_error "Invalid profile: $PROFILE"
            log_info "Use --list-profiles to see available profiles"
            exit 1
        fi
        return
    fi

    # Interactive mode
    if $INTERACTIVE || [[ -t 0 ]]; then
        local selected_profile
        selected_profile=$(select_profile)

        if [[ "$selected_profile" == "custom" ]]; then
            SELECTED_COMPONENTS=$(select_components)
        else
            SELECTED_COMPONENTS=$(get_profile_components "$selected_profile")
            PROFILE="$selected_profile"
        fi
        return
    fi

    # Default to full profile
    PROFILE="full"
    SELECTED_COMPONENTS=$(get_profile_components "full")
}

# ============================================================================
# MAIN FUNCTION
# ============================================================================

main() {
    echo ""
    echo "============================================"
    echo "  Dotfiles Installer"
    echo "============================================"
    echo ""

    # Display detected system info
    log_info "Detected: $OS_NAME ($OS_TYPE)"
    log_info "Package manager: $PKG_MGR"

    # Display installation mode
    if $UPDATE_MODE; then
        log_info "Mode: UPDATE (upgrade packages + update configs)"
    elif $USE_SUDO; then
        log_info "Mode: FULL (install packages + configs)"
    else
        log_info "Mode: CONFIG ONLY (no package installation)"
    fi

    # --------------------------
    # Resolve Profile/Components
    # --------------------------
    resolve_components

    if [[ -n "$PROFILE" ]]; then
        log_info "Profile: $PROFILE"
    fi
    log_info "Components: $SELECTED_COMPONENTS"

    echo ""

    # --------------------------
    # Package Installation/Upgrade
    # --------------------------
    if $UPDATE_MODE; then
        upgrade_packages
    elif $USE_SUDO; then
        install_packages
    fi

    # --------------------------
    # Configuration Setup (based on selected components)
    # --------------------------
    if should_install "zsh"; then
        setup_zsh
    fi

    if should_install "vim"; then
        setup_vim
    fi

    if should_install "tmux"; then
        setup_tmux
    fi

    if should_install "git"; then
        setup_git
    fi

    if should_install "editorconfig"; then
        setup_editorconfig
    fi

    if should_install "vscode"; then
        setup_vscode
    fi

    if should_install "claude"; then
        setup_claude
    fi

    if should_install "docker"; then
        # Docker-related setup (lazydocker already in setup_zsh for Linux)
        log_info "Docker tools configured"
    fi

    # Python setup only for development/full profiles
    if should_install "vim" || should_install "vscode"; then
        setup_python
    fi

    # --------------------------
    # OS-Specific Setup
    # --------------------------
    if is_macos; then
        setup_macos
    fi

    # Setup Google Cloud SDK on Linux (macOS gets it via Brewfile)
    if is_linux && $USE_SUDO; then
        setup_gcloud
    fi

    # --------------------------
    # Complete
    # --------------------------
    echo ""
    echo "============================================"
    log_success "Dotfiles installation complete!"
    echo "============================================"
    echo ""
    log_info "Profile: ${PROFILE:-custom}"
    log_info "Installed: $SELECTED_COMPONENTS"
    echo ""
    log_info "Please restart your shell or run: exec zsh"
    echo ""
}

# ============================================================================
# ENTRY POINT
# ============================================================================

main
