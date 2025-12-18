#!/usr/bin/env bash
# ============================================================================
#                         DOTFILES VERIFICATION SCRIPT
#                    github.com/wit543/dotfiles
# ============================================================================
# Checks if all components are properly installed and configured
# Usage: ./verify.sh
# ============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASS=0
FAIL=0
WARN=0

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASS++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAIL++))
}

warn() {
    echo -e "${YELLOW}!${NC} $1"
    ((WARN++))
}

info() {
    echo -e "${BLUE}→${NC} $1"
}

section() {
    echo ""
    echo -e "${BLUE}━━━ $1 ━━━${NC}"
}

check_command() {
    local cmd="$1"
    local name="${2:-$1}"
    if command -v "$cmd" &>/dev/null; then
        pass "$name installed ($(command -v "$cmd"))"
        return 0
    else
        fail "$name not found"
        return 1
    fi
}

check_file() {
    local file="$1"
    local name="${2:-$1}"
    if [[ -f "$file" ]] || [[ -L "$file" ]]; then
        if [[ -L "$file" ]]; then
            pass "$name linked → $(readlink "$file")"
        else
            pass "$name exists"
        fi
        return 0
    else
        fail "$name not found"
        return 1
    fi
}

check_dir() {
    local dir="$1"
    local name="${2:-$1}"
    if [[ -d "$dir" ]]; then
        pass "$name exists"
        return 0
    else
        fail "$name not found"
        return 1
    fi
}

check_app() {
    local app="$1"
    if [[ -d "/Applications/$app.app" ]]; then
        pass "$app installed"
        return 0
    else
        fail "$app not installed"
        return 1
    fi
}

# ============================================================================
# SYSTEM INFO
# ============================================================================

echo ""
echo "============================================"
echo "  Dotfiles Verification"
echo "============================================"
echo ""
info "System: $(uname -s) $(uname -m)"
info "User: $(whoami)"
info "Home: $HOME"
info "Shell: $SHELL"

# ============================================================================
# SHELL & PROMPT
# ============================================================================

section "Shell & Prompt"

check_command zsh "Zsh"
check_command starship "Starship prompt"
check_command zoxide "Zoxide (smart cd)"
check_command fzf "FZF (fuzzy finder)"

check_file ~/.zshrc ".zshrc"
check_file ~/.config/starship.toml "Starship config"
check_dir ~/.local/share/zinit "Zinit plugins"
check_file ~/.fzf.zsh "FZF integration"

# ============================================================================
# CLI TOOLS (Modern Replacements)
# ============================================================================

section "CLI Tools (Modern)"

check_command bat "bat (cat replacement)"
check_command eza "eza (ls replacement)"
check_command fd "fd (find replacement)"
check_command rg "ripgrep (grep replacement)"
check_command delta "delta (diff viewer)"
check_command dust "dust (du replacement)"
check_command procs "procs (ps replacement)"
check_command sd "sd (sed replacement)"
check_command jq "jq (JSON processor)"
check_command yq "yq (YAML processor)"

# ============================================================================
# CLI TOOLS (2025 Additions)
# ============================================================================

section "CLI Tools (2025)"

check_command tldr "tldr (man pages)"
check_command thefuck "thefuck (typo corrector)" || warn "thefuck optional"
check_command hyperfine "hyperfine (benchmarking)"
check_command yazi "yazi (file manager)"
check_command btop "btop (system monitor)"

# ============================================================================
# TUI TOOLS
# ============================================================================

section "TUI Tools"

check_command lazygit "lazygit (git TUI)"
check_command lazydocker "lazydocker (docker TUI)"

# ============================================================================
# DEVELOPMENT
# ============================================================================

section "Development Tools"

check_command git "Git"
check_command node "Node.js"
check_command npm "npm"
check_command python3 "Python 3"
check_command go "Go" || warn "Go optional"

# ============================================================================
# EDITORS
# ============================================================================

section "Editors"

check_command vim "Vim"
check_command nvim "Neovim"
check_command code "VSCode CLI"

check_file ~/.vimrc ".vimrc"
check_file ~/.config/nvim/init.vim "Neovim config"
check_dir ~/.vim/plugged "Vim plugins" || check_dir ~/.local/share/nvim/plugged "Neovim plugins"

# ============================================================================
# TMUX
# ============================================================================

section "Tmux"

check_command tmux "Tmux"
check_file ~/.tmux.conf ".tmux.conf"
check_dir ~/.tmux/plugins/tpm "TPM (plugin manager)"

# ============================================================================
# GIT
# ============================================================================

section "Git Configuration"

check_file ~/.gitconfig ".gitconfig"
check_file ~/.gitignore_global ".gitignore_global"

if command -v delta &>/dev/null && git config --get core.pager | grep -q delta; then
    pass "Git using delta for diffs"
else
    warn "Git not configured to use delta"
fi

# ============================================================================
# MACOS APPS
# ============================================================================

if [[ "$(uname -s)" == "Darwin" ]]; then
    section "macOS Applications"

    check_app "Docker"
    check_app "Visual Studio Code"
    check_app "iTerm"
    check_app "Ghostty"
    check_app "Raycast"
    check_app "Google Chrome"
fi

# ============================================================================
# HOMEBREW (macOS)
# ============================================================================

if [[ "$(uname -s)" == "Darwin" ]]; then
    section "Homebrew"

    check_command brew "Homebrew"

    if command -v brew &>/dev/null; then
        info "Homebrew prefix: $(brew --prefix)"
        info "Installed formulae: $(brew list --formula | wc -l | tr -d ' ')"
        info "Installed casks: $(brew list --cask | wc -l | tr -d ' ')"
    fi
fi

# ============================================================================
# CLAUDE CODE
# ============================================================================

section "Claude Code"

check_file ~/.claude/settings.json "Claude settings"
check_file ~/.claude/CLAUDE.md "Claude instructions"

if [[ -f ~/.claude/settings.json ]]; then
    if grep -q "context7" ~/.claude/settings.json; then
        pass "Context7 MCP configured"
    else
        warn "Context7 MCP not configured"
    fi

    if grep -q "mcp__context7" ~/.claude/settings.json; then
        pass "Context7 auto-allowed in permissions"
    else
        warn "Context7 not in auto-allow list"
    fi
fi

# ============================================================================
# EDITORCONFIG
# ============================================================================

section "Editor Configuration"

check_file ~/.editorconfig ".editorconfig"

# ============================================================================
# VSCODE
# ============================================================================

section "VSCode"

if [[ "$(uname -s)" == "Darwin" ]]; then
    VSCODE_DIR="$HOME/Library/Application Support/Code/User"
else
    VSCODE_DIR="$HOME/.config/Code/User"
fi

check_file "$VSCODE_DIR/settings.json" "VSCode settings"
check_file "$VSCODE_DIR/keybindings.json" "VSCode keybindings"

if command -v code &>/dev/null; then
    EXT_COUNT=$(code --list-extensions 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$EXT_COUNT" -gt 20 ]]; then
        pass "VSCode extensions installed ($EXT_COUNT extensions)"
    else
        warn "Few VSCode extensions ($EXT_COUNT installed)"
    fi
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "============================================"
echo "  Summary"
echo "============================================"
echo ""
echo -e "${GREEN}Passed:${NC}  $PASS"
echo -e "${RED}Failed:${NC}  $FAIL"
echo -e "${YELLOW}Warnings:${NC} $WARN"
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    exit 0
elif [[ $FAIL -lt 5 ]]; then
    echo -e "${YELLOW}! Some components missing, but mostly working${NC}"
    exit 0
else
    echo -e "${RED}✗ Multiple components missing, review installation${NC}"
    exit 1
fi
