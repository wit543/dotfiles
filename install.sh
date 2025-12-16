#!/usr/bin/env bash
# ============================================================================
#                         DOTFILES INSTALLER
#                    github.com/wit543/dotfiles
# ============================================================================
# Main installation script for dotfiles
#
# Usage:
#   ./install.sh              # Full install (packages + configs)
#   ./install.sh --no-sudo    # Config only (no packages)
#   ./install.sh --update     # Update packages and configs
#   ./install.sh --help       # Show help
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

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

USE_SUDO=true
UPDATE_MODE=false

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
        -h|--help)
            echo "Usage: $0 [--sudo|--no-sudo|--update]"
            echo ""
            echo "Options:"
            echo "  --sudo     Install packages + configs (default)"
            echo "  --no-sudo  Config only, skip package installation"
            echo "  --update   Update packages and pull latest configs"
            echo "  -h, --help Show this help message"
            exit 0
            ;;
    esac
done

# Detect operating system
detect_os

# ============================================================================
# ZSH SETUP
# ============================================================================
# NOTE: Installs Oh My Zsh, Powerlevel10k theme, and useful plugins

setup_zsh() {
    log_info "Setting up Zsh..."

    # --------------------------
    # Oh My Zsh
    # --------------------------
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        log_success "Oh My Zsh already installed"
        if $UPDATE_MODE; then
            git_update "$HOME/.oh-my-zsh"
        fi
    fi

    # --------------------------
    # Powerlevel10k Theme
    # --------------------------
    git_clone "https://github.com/romkatv/powerlevel10k.git" \
              "$HOME/.oh-my-zsh/themes/powerlevel10k"
    if $UPDATE_MODE; then
        git_update "$HOME/.oh-my-zsh/themes/powerlevel10k"
    fi

    # --------------------------
    # Zsh Plugins
    # --------------------------
    mkdir -p "$HOME/.zsh"

    # Pre-clone plugins for faster shell startup
    local zsh_plugins=(
        "https://github.com/zsh-users/zsh-autosuggestions"      # History-based suggestions
        "https://github.com/zsh-users/zsh-syntax-highlighting"  # Command highlighting
        "https://github.com/zsh-users/zsh-completions"          # Extra completions
        "https://github.com/zsh-users/zsh-history-substring-search"  # Better history search
        "https://github.com/supasorn/fzf-z"                     # Fuzzy z integration
        "https://github.com/changyuheng/zsh-interactive-cd"     # Interactive cd with fzf
        "https://github.com/hchbaw/zce.zsh"                     # Quick navigation
        "https://github.com/urbainvaes/fzf-marks"               # Bookmark directories
    )

    for plugin_url in "${zsh_plugins[@]}"; do
        local plugin_name
        plugin_name=$(basename "$plugin_url" .git)
        git_clone "$plugin_url" "$HOME/.zsh/$plugin_name"
        if $UPDATE_MODE; then
            git_update "$HOME/.zsh/$plugin_name"
        fi
    done

    # --------------------------
    # FZF (Fuzzy Finder)
    # --------------------------
    git_clone "https://github.com/junegunn/fzf.git" "$HOME/.fzf"
    if $UPDATE_MODE; then
        git_update "$HOME/.fzf"
    fi
    if [[ -f "$HOME/.fzf/install" ]]; then
        "$HOME/.fzf/install" --all --no-bash --no-fish --no-update-rc
    fi

    # --------------------------
    # Symlinks
    # --------------------------
    symlink "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
    symlink "$DOTFILES_DIR/config/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

    log_success "Zsh setup complete"
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

    log_success "Git setup complete"
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
    # Configuration Setup
    # --------------------------
    setup_zsh
    setup_vim
    setup_tmux
    setup_git

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
    log_info "Please restart your shell or run: exec zsh"
    echo ""
}

# ============================================================================
# ENTRY POINT
# ============================================================================

main
