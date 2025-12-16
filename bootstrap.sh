#!/usr/bin/env bash
# ============================================================================
#                         BOOTSTRAP SCRIPT
#                    github.com/wit543/dotfiles
# ============================================================================
# Curl-able entry point for dotfiles installation
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/wit543/dotfiles/main/bootstrap.sh | bash
#   curl -fsSL ... | bash -s -- --no-sudo    # Config only, no packages
#   curl -fsSL ... | bash -s -- --update     # Update existing installation
#
# This script:
#   1. Installs git if not present
#   2. Clones the dotfiles repository
#   3. Runs the main installer
# ============================================================================

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

DOTFILES_REPO="https://github.com/wit543/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# ============================================================================
# COLORS
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# LOGGING
# ============================================================================

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ============================================================================
# PACKAGE MANAGER DETECTION
# ============================================================================
# NOTE: Minimal detection for git installation only

detect_pkg_mgr() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "brew"
    elif command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# ============================================================================
# GIT INSTALLATION
# ============================================================================
# NOTE: Ensures git is available for cloning the repository

install_git() {
    # Skip if git already exists
    if command -v git &>/dev/null; then
        return 0
    fi

    info "Git not found. Installing..."
    local pkg_mgr
    pkg_mgr=$(detect_pkg_mgr)

    case "$pkg_mgr" in
        brew)
            # On macOS, install Xcode Command Line Tools (includes git)
            if ! xcode-select -p &>/dev/null; then
                info "Installing Xcode Command Line Tools..."
                xcode-select --install 2>/dev/null || true
                # Wait for installation to complete
                until xcode-select -p &>/dev/null; do
                    sleep 5
                done
            fi
            ;;
        apt)
            sudo apt-get update && sudo apt-get install -y git
            ;;
        dnf|yum)
            sudo "$pkg_mgr" install -y git
            ;;
        pacman)
            sudo pacman -Sy --noconfirm git
            ;;
        *)
            error "Could not install git. Please install it manually."
            ;;
    esac
}

# ============================================================================
# MAIN FUNCTION
# ============================================================================

main() {
    echo ""
    echo "============================================"
    echo "  Dotfiles Bootstrap"
    echo "============================================"
    echo ""

    info "Bootstrapping dotfiles..."

    # Step 1: Ensure git is installed
    install_git

    # Step 2: Clone or update repository
    if [[ -d "$DOTFILES_DIR" ]]; then
        info "Dotfiles directory exists. Updating..."
        git -C "$DOTFILES_DIR" pull --rebase || true
    else
        info "Cloning dotfiles repository..."
        git clone --depth=1 "$DOTFILES_REPO" "$DOTFILES_DIR"
    fi

    # Step 3: Make installer executable and run it
    chmod +x "$DOTFILES_DIR/install.sh"

    info "Running installer..."
    "$DOTFILES_DIR/install.sh" "$@"

    echo ""
    success "Bootstrap complete!"
    echo ""
}

# ============================================================================
# ENTRY POINT
# ============================================================================

main "$@"
