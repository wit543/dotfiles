#!/usr/bin/env bash
# ============================================================================
#                         DOTFILES RESET/UNINSTALL
#                    github.com/wit543/dotfiles
# ============================================================================
# Removes all dotfiles configurations and optionally installed tools
#
# Usage:
#   ./reset.sh              # Remove symlinks and configs only
#   ./reset.sh --full       # Also remove installed tools (fzf, zinit, etc.)
#   ./reset.sh --dry-run    # Show what would be removed without removing
#   ./reset.sh --help       # Show help
#
# Supports: macOS, Ubuntu, Rocky Linux, Manjaro
# ============================================================================

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities for logging
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/os.sh"

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

FULL_RESET=false
DRY_RUN=false

for arg in "$@"; do
    case "$arg" in
        --full)
            FULL_RESET=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        -h|--help)
            echo "Usage: $0 [--full] [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --full     Remove installed tools (fzf, zinit, oh-my-zsh, p10k, tpm, vim-plug)"
            echo "  --dry-run  Show what would be removed without removing"
            echo "  -h, --help Show this help message"
            echo ""
            echo "What gets removed:"
            echo "  Default:   Symlinks to dotfiles configs"
            echo "  --full:    Also removes fzf, zinit, oh-my-zsh, p10k, tpm, vim plugins, etc."
            exit 0
            ;;
    esac
done

# Detect OS
detect_os

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Remove a symlink if it points to our dotfiles
remove_symlink() {
    local target="$1"

    if [[ -L "$target" ]]; then
        local link_dest
        link_dest=$(readlink "$target")

        # Check if it points to our dotfiles
        if [[ "$link_dest" == *"dotfiles"* ]]; then
            if $DRY_RUN; then
                log_info "[DRY-RUN] Would remove symlink: $target -> $link_dest"
            else
                rm "$target"
                log_success "Removed symlink: $target"
            fi
        else
            log_warn "Skipping $target (not a dotfiles symlink)"
        fi
    elif [[ -e "$target" ]]; then
        log_warn "Skipping $target (not a symlink)"
    fi
}

# Remove a directory
remove_dir() {
    local target="$1"
    local description="${2:-$target}"

    if [[ -d "$target" ]]; then
        if $DRY_RUN; then
            log_info "[DRY-RUN] Would remove directory: $description"
        else
            rm -rf "$target"
            log_success "Removed: $description"
        fi
    fi
}

# Remove a file
remove_file() {
    local target="$1"
    local description="${2:-$target}"

    if [[ -f "$target" ]]; then
        if $DRY_RUN; then
            log_info "[DRY-RUN] Would remove file: $description"
        else
            rm -f "$target"
            log_success "Removed: $description"
        fi
    fi
}

# ============================================================================
# RESET ZSH
# ============================================================================

reset_zsh() {
    log_info "Resetting Zsh configuration..."

    # Remove symlinks
    remove_symlink "$HOME/.zshrc"
    remove_symlink "$HOME/.config/starship.toml"

    # Old-style p10k config
    remove_symlink "$HOME/.p10k.zsh"

    if $FULL_RESET; then
        # --------------------------
        # New-style (2025): Zinit + Starship
        # --------------------------
        remove_dir "${XDG_DATA_HOME:-$HOME/.local/share}/zinit" "Zinit"

        # --------------------------
        # Old-style: Oh My Zsh + Powerlevel10k
        # --------------------------
        remove_dir "$HOME/.oh-my-zsh" "Oh My Zsh"

        # Powerlevel10k (standalone install)
        remove_dir "$HOME/powerlevel10k" "Powerlevel10k (standalone)"

        # Powerlevel10k (as Oh My Zsh custom theme)
        remove_dir "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" "Powerlevel10k (OMZ theme)"

        # p10k cache (use glob to find cache dirs)
        for dir in "$HOME"/.cache/p10k-*; do
            [[ -d "$dir" ]] && remove_dir "$dir" "p10k cache: $(basename "$dir")"
        done
        remove_file "$HOME/.p10k.zsh" "p10k config"

        # Zsh-specific caches/histories (optional - commented out to preserve history)
        # remove_file "$HOME/.zsh_history" "Zsh history"
        # remove_dir "$HOME/.zsh_sessions" "Zsh sessions"

        # --------------------------
        # Common tools
        # --------------------------
        remove_dir "$HOME/.fzf" "fzf"

        # zoxide database (optional - user data)
        # remove_dir "$HOME/.local/share/zoxide" "zoxide database"

        # Note: Starship binary installed to ~/.local/bin or /usr/local/bin
        log_info "Note: Starship binary not removed (may be system-wide)"
        log_info "  To remove: rm ~/.local/bin/starship or sudo rm /usr/local/bin/starship"
    fi

    log_success "Zsh reset complete"
}

# ============================================================================
# RESET VIM / NEOVIM
# ============================================================================

reset_vim() {
    log_info "Resetting Vim/Neovim configuration..."

    # Remove symlinks
    remove_symlink "$HOME/.vimrc"
    remove_symlink "$HOME/.gvimrc"
    remove_symlink "$HOME/.vim.function"
    remove_symlink "$HOME/.vim/colors/gruvbox.vim"
    remove_symlink "$HOME/.config/nvim/init.vim"

    if $FULL_RESET; then
        # Remove vim-plug
        remove_file "$HOME/.vim/autoload/plug.vim" "vim-plug (Vim)"
        remove_file "$HOME/.local/share/nvim/site/autoload/plug.vim" "vim-plug (Neovim)"

        # Remove vim plugins
        remove_dir "$HOME/.vim/plugged" "Vim plugins"
        remove_dir "$HOME/.local/share/nvim/plugged" "Neovim plugins"
    fi

    log_success "Vim/Neovim reset complete"
}

# ============================================================================
# RESET TMUX
# ============================================================================

reset_tmux() {
    log_info "Resetting Tmux configuration..."

    # Remove symlinks
    remove_symlink "$HOME/.tmux.conf"
    remove_symlink "$HOME/.tmux.conf.local"

    if $FULL_RESET; then
        # Remove TPM and plugins
        remove_dir "$HOME/.tmux/plugins" "Tmux plugins"
    fi

    log_success "Tmux reset complete"
}

# ============================================================================
# RESET GIT
# ============================================================================

reset_git() {
    log_info "Resetting Git configuration..."

    # Remove symlinks
    remove_symlink "$HOME/.gitconfig"
    remove_symlink "$HOME/.gitignore_global"

    log_success "Git reset complete"
}

# ============================================================================
# RESET EDITORCONFIG
# ============================================================================

reset_editorconfig() {
    log_info "Resetting EditorConfig..."

    remove_symlink "$HOME/.editorconfig"

    log_success "EditorConfig reset complete"
}

# ============================================================================
# RESET VSCODE
# ============================================================================

reset_vscode() {
    log_info "Resetting VSCode configuration..."

    local vscode_settings_dir
    if is_macos; then
        vscode_settings_dir="$HOME/Library/Application Support/Code/User"
    else
        vscode_settings_dir="$HOME/.config/Code/User"
    fi

    # Remove symlinks
    remove_symlink "$vscode_settings_dir/settings.json"
    remove_symlink "$vscode_settings_dir/keybindings.json"

    log_info "Note: VSCode extensions not removed"

    log_success "VSCode reset complete"
}

# ============================================================================
# RESET CLAUDE
# ============================================================================

reset_claude() {
    log_info "Resetting Claude Code configuration..."

    # Remove symlinks
    remove_symlink "$HOME/.claude/settings.json"
    remove_symlink "$HOME/.claude/CLAUDE.md"

    log_success "Claude Code reset complete"
}

# ============================================================================
# RESET LINUX-SPECIFIC TOOLS
# ============================================================================

reset_linux_tools() {
    if ! is_linux; then
        return 0
    fi

    if ! $FULL_RESET; then
        return 0
    fi

    log_info "Resetting Linux-specific tools..."

    # Remove lazygit if installed to local bin
    remove_file "$HOME/.local/bin/lazygit" "lazygit (local)"

    # Remove lazydocker if installed to local bin
    remove_file "$HOME/.local/bin/lazydocker" "lazydocker (local)"

    log_success "Linux tools reset complete"
}

# ============================================================================
# RESTORE BACKUPS
# ============================================================================

restore_backups() {
    log_info "Checking for backups to restore..."

    local backup_files
    backup_files=$(find "$HOME" -maxdepth 3 -name "*.backup.*" -type f 2>/dev/null || true)

    if [[ -n "$backup_files" ]]; then
        echo ""
        log_warn "Found backup files that may be restored:"
        echo "$backup_files" | head -20
        echo ""
        log_info "To restore a backup, rename it to remove the .backup.TIMESTAMP suffix"
        log_info "Example: mv ~/.zshrc.backup.20240101120000 ~/.zshrc"
    else
        log_success "No backup files found"
    fi
}

# ============================================================================
# MAIN FUNCTION
# ============================================================================

main() {
    echo ""
    echo "============================================"
    echo "  Dotfiles Reset/Uninstall"
    echo "============================================"
    echo ""

    # Display mode
    if $DRY_RUN; then
        log_warn "DRY-RUN MODE: No changes will be made"
    fi

    if $FULL_RESET; then
        log_warn "FULL RESET: Will also remove installed tools"
    else
        log_info "CONFIG RESET: Will only remove symlinks"
    fi

    echo ""

    # Confirm before proceeding
    if ! $DRY_RUN; then
        if ! confirm "This will remove dotfiles configurations. Continue?" "n"; then
            log_info "Aborted."
            exit 0
        fi
        echo ""
    fi

    # --------------------------
    # Reset All Components
    # --------------------------
    reset_zsh
    reset_vim
    reset_tmux
    reset_git
    reset_editorconfig
    reset_vscode
    reset_claude
    reset_linux_tools

    # --------------------------
    # Show Backups
    # --------------------------
    restore_backups

    # --------------------------
    # Complete
    # --------------------------
    echo ""
    echo "============================================"
    if $DRY_RUN; then
        log_info "Dry run complete. No changes were made."
    else
        log_success "Dotfiles reset complete!"
    fi
    echo "============================================"
    echo ""

    if ! $DRY_RUN; then
        log_info "Your shell configuration has been reset."
        log_info "Please restart your shell or run: exec \$SHELL"
        echo ""

        if ! $FULL_RESET; then
            log_info "To also remove installed tools, run: ./reset.sh --full"
        fi
    fi
}

# ============================================================================
# ENTRY POINT
# ============================================================================

main
