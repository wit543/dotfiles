#!/usr/bin/env bash
# ============================================================================
#                      PACKAGE MANAGER ABSTRACTION
#                    github.com/wit543/dotfiles
# ============================================================================
# Unified interface for package management across different systems
# Supports: Homebrew (macOS), APT (Debian/Ubuntu), DNF/YUM (RHEL), Pacman (Arch)
# ============================================================================

# ============================================================================
# PACKAGE MANAGER OPERATIONS
# ============================================================================
# NOTE: These functions automatically use the correct package manager
# based on the PKG_MGR variable set by detect_os()

# Update package manager cache
# Usage: pkg_update
pkg_update() {
    log_info "Updating package manager..."
    case "$PKG_MGR" in
        brew)
            brew update
            ;;
        apt)
            sudo apt-get update
            ;;
        dnf|yum)
            sudo "$PKG_MGR" check-update || true  # Returns 100 if updates available
            ;;
        pacman)
            sudo pacman -Sy
            ;;
    esac
}

# Upgrade all installed packages
# Usage: pkg_upgrade
pkg_upgrade() {
    log_info "Upgrading packages..."
    case "$PKG_MGR" in
        brew)
            brew upgrade              # CLI packages
            brew upgrade --cask       # GUI applications
            ;;
        apt)
            sudo apt-get upgrade -y
            ;;
        dnf|yum)
            sudo "$PKG_MGR" upgrade -y
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            ;;
    esac
}

# Install one or more packages
# Usage: pkg_install git neovim tmux
pkg_install() {
    local packages=("$@")
    log_info "Installing packages: ${packages[*]}"
    case "$PKG_MGR" in
        brew)
            brew install "${packages[@]}"
            ;;
        apt)
            sudo apt-get install -y "${packages[@]}"
            ;;
        dnf|yum)
            sudo "$PKG_MGR" install -y "${packages[@]}"
            ;;
        pacman)
            sudo pacman -S --noconfirm --needed "${packages[@]}"
            ;;
    esac
}

# ============================================================================
# FILE-BASED INSTALLATION
# ============================================================================
# NOTE: Install packages from a text file (one package per line)
# Comments (#) and empty lines are ignored

# Install packages from a text file
# Usage: pkg_install_from_file "/path/to/packages.txt"
pkg_install_from_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        log_warn "Package file not found: $file"
        return 0
    fi

    # Read packages, skip comments and empty lines
    local packages=()
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Remove comments and trim whitespace
        line="${line%%#*}"
        line="${line// /}"
        line="${line%"${line##*[![:space:]]}"}"
        line="${line#"${line%%[![:space:]]*}"}"
        [[ -n "$line" ]] && packages+=("$line")
    done < "$file"

    if [[ ${#packages[@]} -gt 0 ]]; then
        pkg_install "${packages[@]}"
    fi
}

# ============================================================================
# HOMEBREW (macOS)
# ============================================================================
# NOTE: Homebrew is the package manager for macOS
# Automatically installs and configures for both Intel and Apple Silicon

# Install Homebrew if not present
# Usage: install_homebrew
install_homebrew() {
    if ! command_exists brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add to PATH (different locations for Intel vs Apple Silicon)
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon (M1/M2/M3)
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"     # Intel Mac
        fi
    else
        log_success "Homebrew already installed"
    fi
}

# Install packages from a Brewfile
# Usage: install_from_brewfile "/path/to/Brewfile"
install_from_brewfile() {
    local brewfile="$1"

    if [[ ! -f "$brewfile" ]]; then
        log_warn "Brewfile not found: $brewfile"
        return 0
    fi

    # Docker Desktop requires /usr/local/cli-plugins for docker-compose
    # Create it before installing casks to avoid sudo prompt during brew bundle
    if [[ ! -d /usr/local/cli-plugins ]]; then
        log_info "Creating /usr/local/cli-plugins for Docker..."
        sudo mkdir -p /usr/local/cli-plugins
        sudo chown -R "$(whoami)" /usr/local/cli-plugins
    fi

    log_info "Installing from Brewfile..."
    brew bundle --file="$brewfile"
}

# ============================================================================
# GOOGLE CLOUD SDK
# ============================================================================
# NOTE: macOS gets gcloud via Homebrew cask, Linux uses official installer

# Install and configure Google Cloud SDK
# Usage: setup_gcloud
setup_gcloud() {
    log_info "Setting up Google Cloud SDK..."

    if is_macos; then
        # On macOS, gcloud is installed via Homebrew cask in Brewfile
        if command_exists gcloud; then
            log_success "Google Cloud SDK already installed"
        else
            log_info "Google Cloud SDK will be installed via Brewfile"
        fi
    else
        # On Linux, install via official script if not present
        if ! command_exists gcloud; then
            log_info "Installing Google Cloud SDK..."
            curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts
        else
            log_success "Google Cloud SDK already installed"
        fi
    fi
}

# ============================================================================
# ESSENTIAL PACKAGES
# ============================================================================
# NOTE: Minimal packages needed for the installer to function

# Install essential packages (git, curl, wget)
# Usage: install_essentials
install_essentials() {
    log_info "Installing essential packages..."

    case "$PKG_MGR" in
        brew)
            install_homebrew
            brew install git curl wget
            ;;
        apt)
            sudo apt-get update
            sudo apt-get install -y git curl wget
            ;;
        dnf|yum)
            sudo "$PKG_MGR" install -y git curl wget
            ;;
        pacman)
            sudo pacman -Sy --noconfirm --needed git curl wget
            ;;
    esac
}

# ============================================================================
# END OF PACKAGES
# ============================================================================
