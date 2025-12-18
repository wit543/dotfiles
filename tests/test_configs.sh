#!/usr/bin/env bash
# ============================================================================
#                         UNIT TESTS - CONFIGURATION FILES
#                    github.com/wit543/dotfiles
# ============================================================================
# Tests for configuration file validity
# Run: ./tests/test_configs.sh
# ============================================================================

set -uo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# ============================================================================
# TEST FRAMEWORK
# ============================================================================

test_start() {
    echo -e "\n${YELLOW}Testing:${NC} $1"
}

assert_true() {
    local condition="$1"
    local message="${2:-}"
    ((TESTS_RUN++))

    if eval "$condition"; then
        echo -e "  ${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        echo -e "    Condition failed: $condition"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File exists: $file}"
    ((TESTS_RUN++))

    if [[ -f "$file" ]]; then
        echo -e "  ${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_json_valid() {
    local file="$1"
    local message="${2:-JSON valid: $file}"
    ((TESTS_RUN++))

    if command -v jq &>/dev/null; then
        if jq empty "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $message"
            ((TESTS_PASSED++))
            return 0
        else
            echo -e "  ${RED}✗${NC} $message"
            echo -e "    Invalid JSON in: $file"
            ((TESTS_FAILED++))
            return 1
        fi
    else
        # Skip if jq not available
        echo -e "  ${YELLOW}⊘${NC} $message (jq not available, skipped)"
        ((TESTS_PASSED++))
        return 0
    fi
}

assert_contains() {
    local file="$1"
    local pattern="$2"
    local message="${3:-File contains pattern}"
    ((TESTS_RUN++))

    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        echo -e "    Pattern not found: $pattern"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ============================================================================
# TESTS: Zsh configuration
# ============================================================================

test_zsh_config() {
    test_start "Zsh configuration"

    local zshrc="$DOTFILES_DIR/config/zsh/.zshrc"

    assert_file_exists "$zshrc" ".zshrc exists"
    assert_contains "$zshrc" "zinit" "Uses Zinit plugin manager"
    assert_contains "$zshrc" "starship" "Uses Starship prompt"
    assert_contains "$zshrc" "zoxide" "Uses zoxide for cd"
    assert_contains "$zshrc" "fzf" "FZF integration"
    assert_contains "$zshrc" "bat" "bat alias configured"
    assert_contains "$zshrc" "eza" "eza alias configured"

    # Check starship config
    local starship_config="$DOTFILES_DIR/config/zsh/starship.toml"
    assert_file_exists "$starship_config" "starship.toml exists"
}

# ============================================================================
# TESTS: Vim configuration
# ============================================================================

test_vim_config() {
    test_start "Vim configuration"

    local vimrc="$DOTFILES_DIR/config/vim/.vimrc"

    assert_file_exists "$vimrc" ".vimrc exists"
    assert_contains "$vimrc" "plug#begin" "Uses vim-plug"
    assert_contains "$vimrc" "set number" "Line numbers enabled"

    # Check neovim config
    local nvim_init="$DOTFILES_DIR/config/nvim/init.vim"
    assert_file_exists "$nvim_init" "Neovim init.vim exists"
}

# ============================================================================
# TESTS: Tmux configuration
# ============================================================================

test_tmux_config() {
    test_start "Tmux configuration"

    local tmux_conf="$DOTFILES_DIR/config/tmux/.tmux.conf"

    assert_file_exists "$tmux_conf" ".tmux.conf exists"
}

# ============================================================================
# TESTS: Git configuration
# ============================================================================

test_git_config() {
    test_start "Git configuration"

    local gitconfig="$DOTFILES_DIR/config/git/.gitconfig"
    local gitignore="$DOTFILES_DIR/config/git/.gitignore_global"

    assert_file_exists "$gitconfig" ".gitconfig exists"
    assert_file_exists "$gitignore" ".gitignore_global exists"
    assert_contains "$gitconfig" "delta" "Uses delta for diffs"
    assert_contains "$gitconfig" "excludesfile" "References global gitignore"

    # Check gitignore has common patterns
    assert_contains "$gitignore" ".DS_Store" "Ignores .DS_Store"
    assert_contains "$gitignore" "node_modules" "Ignores node_modules"
    assert_contains "$gitignore" ".env" "Ignores .env files"
}

# ============================================================================
# TESTS: VSCode configuration
# ============================================================================

test_vscode_config() {
    test_start "VSCode configuration"

    local settings="$DOTFILES_DIR/config/vscode/settings.json"
    local keybindings="$DOTFILES_DIR/config/vscode/keybindings.json"
    local extensions="$DOTFILES_DIR/config/vscode/extensions.txt"

    assert_file_exists "$settings" "settings.json exists"
    assert_file_exists "$keybindings" "keybindings.json exists"
    assert_file_exists "$extensions" "extensions.txt exists"

    assert_json_valid "$settings" "settings.json is valid JSON"
    assert_json_valid "$keybindings" "keybindings.json is valid JSON"

    # Check settings content
    assert_contains "$settings" "editor.wordWrap" "Word wrap setting present"
    assert_contains "$settings" "editor.formatOnSave" "Format on save setting present"

    # Check extensions list
    assert_contains "$extensions" "esbenp.prettier-vscode" "Prettier extension listed"
    assert_contains "$extensions" "dbaeumer.vscode-eslint" "ESLint extension listed"
    assert_contains "$extensions" "github.copilot" "Copilot extension listed"
}

# ============================================================================
# TESTS: Claude Code configuration
# ============================================================================

test_claude_config() {
    test_start "Claude Code configuration"

    local settings="$DOTFILES_DIR/config/claude/settings.json"
    local claude_md="$DOTFILES_DIR/config/claude/CLAUDE.md"

    assert_file_exists "$settings" "settings.json exists"
    assert_file_exists "$claude_md" "CLAUDE.md exists"

    assert_json_valid "$settings" "settings.json is valid JSON"

    # Check settings content
    assert_contains "$settings" "mcpServers" "MCP servers configured"
    assert_contains "$settings" "context7" "Context7 MCP configured"
    assert_contains "$settings" "mcp__context7" "Context7 auto-allowed"
    assert_contains "$settings" "permissions" "Permissions configured"

    # Check CLAUDE.md content
    assert_contains "$claude_md" "Context7" "Context7 instructions present"
    assert_contains "$claude_md" "Code Style" "Code style guidelines present"
}

# ============================================================================
# TESTS: EditorConfig
# ============================================================================

test_editorconfig() {
    test_start "EditorConfig"

    local editorconfig="$DOTFILES_DIR/config/editor/.editorconfig"

    assert_file_exists "$editorconfig" ".editorconfig exists"
    assert_contains "$editorconfig" "root = true" "Root directive present"
    assert_contains "$editorconfig" "indent_style" "Indent style configured"
    assert_contains "$editorconfig" "end_of_line" "EOL configured"
}

# ============================================================================
# TESTS: Install script
# ============================================================================

test_install_script() {
    test_start "Install script"

    local install_script="$DOTFILES_DIR/install.sh"

    assert_file_exists "$install_script" "install.sh exists"
    assert_true "[[ -x \"$install_script\" ]]" "install.sh is executable"

    # Check script has expected functions
    assert_contains "$install_script" "setup_zsh" "setup_zsh function present"
    assert_contains "$install_script" "setup_vim" "setup_vim function present"
    assert_contains "$install_script" "setup_tmux" "setup_tmux function present"
    assert_contains "$install_script" "setup_git" "setup_git function present"
    assert_contains "$install_script" "setup_vscode" "setup_vscode function present"
    assert_contains "$install_script" "setup_claude" "setup_claude function present"
}

# ============================================================================
# TESTS: Library scripts
# ============================================================================

test_lib_scripts() {
    test_start "Library scripts"

    assert_file_exists "$DOTFILES_DIR/lib/utils.sh" "lib/utils.sh exists"
    assert_file_exists "$DOTFILES_DIR/lib/packages.sh" "lib/packages.sh exists"

    assert_true "[[ -x \"$DOTFILES_DIR/lib/utils.sh\" ]]" "lib/utils.sh is executable"
    assert_true "[[ -x \"$DOTFILES_DIR/lib/packages.sh\" ]]" "lib/packages.sh is executable"
}

# ============================================================================
# TESTS: Verify script
# ============================================================================

test_verify_script() {
    test_start "Verify script"

    local verify_script="$DOTFILES_DIR/verify.sh"

    assert_file_exists "$verify_script" "verify.sh exists"
    assert_true "[[ -x \"$verify_script\" ]]" "verify.sh is executable"
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

echo "============================================"
echo "  Unit Tests: Configuration Files"
echo "============================================"

test_zsh_config
test_vim_config
test_tmux_config
test_git_config
test_vscode_config
test_claude_config
test_editorconfig
test_install_script
test_lib_scripts
test_verify_script

echo ""
echo "============================================"
echo "  Results"
echo "============================================"
echo -e "Tests run:    $TESTS_RUN"
echo -e "${GREEN}Passed:${NC}       $TESTS_PASSED"
echo -e "${RED}Failed:${NC}       $TESTS_FAILED"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
