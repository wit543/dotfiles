#!/usr/bin/env bash
# ============================================================================
#                         UTILITY FUNCTIONS
#                    github.com/wit543/dotfiles
# ============================================================================
# Shared utilities for dotfiles installation
# Provides: logging, symlinks, git helpers, and common functions
# ============================================================================

# ============================================================================
# COLORS
# ============================================================================
# NOTE: ANSI color codes for terminal output

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color (reset)

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================
# NOTE: Colored output for different message types
# Usage: log_info "message", log_success "message", etc.

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# ============================================================================
# SYMLINK MANAGEMENT
# ============================================================================
# NOTE: Safe symlink creation with automatic backup of existing files

# Create symlink with backup (idempotent)
# Usage: symlink "/path/to/source" "/path/to/destination"
symlink() {
    local src="$1"
    local dst="$2"
    local dst_dir

    dst_dir=$(dirname "$dst")

    # Create parent directory if needed
    if [[ ! -d "$dst_dir" ]]; then
        mkdir -p "$dst_dir"
    fi

    # Backup existing file (not symlink) with timestamp
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        local backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
        log_warn "Backing up $dst to $backup"
        mv "$dst" "$backup"
    fi

    # Remove existing symlink
    if [[ -L "$dst" ]]; then
        rm "$dst"
    fi

    # Create symlink
    ln -sf "$src" "$dst"
    log_success "Linked $dst -> $src"
}

# ============================================================================
# GIT HELPERS
# ============================================================================
# NOTE: Functions for cloning and updating git repositories

# Clone git repo if not exists (shallow clone for faster downloads)
# Usage: git_clone "https://github.com/user/repo" "/path/to/destination"
git_clone() {
    local repo="$1"
    local dest="$2"

    if [[ -d "$dest" ]]; then
        log_info "Already exists: $dest"
    else
        log_info "Cloning $repo..."
        git clone --depth=1 "$repo" "$dest"
    fi
}

# Update existing git repo (silent failure for offline use)
# Usage: git_update "/path/to/repo"
git_update() {
    local dest="$1"

    if [[ -d "$dest/.git" ]]; then
        log_info "Updating $dest..."
        git -C "$dest" pull --rebase --quiet || true
    fi
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================
# NOTE: Common helper functions

# Check if command exists
# Usage: if command_exists nvim; then ...
command_exists() {
    command -v "$1" &>/dev/null
}

# Ask for user confirmation
# Usage: if confirm "Proceed?" "y"; then ...
# Second argument is default (y/n)
confirm() {
    local prompt="$1"
    local default="${2:-n}"

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi

    read -r -p "$prompt" response
    response=${response:-$default}

    [[ "$response" =~ ^[Yy]$ ]]
}

# ============================================================================
# END OF UTILS
# ============================================================================
