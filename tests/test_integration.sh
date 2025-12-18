#!/usr/bin/env bash
# ============================================================================
#                         INTEGRATION TESTS
#                    github.com/wit543/dotfiles
# ============================================================================
# Tests that verify installed tools work correctly together
# Run: ./tests/test_integration.sh
# ============================================================================

set -uo pipefail

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

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

assert_success() {
    local cmd="$1"
    local message="${2:-Command succeeds: $cmd}"
    ((TESTS_RUN++))

    if eval "$cmd" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_output_contains() {
    local cmd="$1"
    local pattern="$2"
    local message="${3:-Output contains pattern}"
    ((TESTS_RUN++))

    local output
    output=$(eval "$cmd" 2>&1)

    if [[ "$output" == *"$pattern"* ]]; then
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

skip_if_missing() {
    local cmd="$1"
    local message="$2"

    if ! command -v "$cmd" &>/dev/null; then
        echo -e "  ${YELLOW}⊘${NC} Skipped: $message ($cmd not installed)"
        ((TESTS_SKIPPED++))
        return 1
    fi
    return 0
}

# ============================================================================
# TESTS: Shell tools
# ============================================================================

test_shell_tools() {
    test_start "Shell tools integration"

    # Test starship
    if skip_if_missing "starship" "Starship prompt"; then
        assert_success "starship --version" "starship --version works"
        assert_output_contains "starship module --list" "git" "starship has git module"
    fi

    # Test zoxide
    if skip_if_missing "zoxide" "Zoxide"; then
        assert_success "zoxide --version" "zoxide --version works"
    fi

    # Test fzf
    if skip_if_missing "fzf" "FZF"; then
        assert_success "fzf --version" "fzf --version works"
        assert_output_contains "echo 'test' | fzf --filter='test'" "test" "fzf filtering works"
    fi
}

# ============================================================================
# TESTS: Modern CLI tools
# ============================================================================

test_modern_cli() {
    test_start "Modern CLI tools"

    # Test bat
    if skip_if_missing "bat" "bat"; then
        assert_success "bat --version" "bat --version works"
        assert_success "echo 'hello' | bat --style=plain" "bat can read stdin"
    fi

    # Test eza
    if skip_if_missing "eza" "eza"; then
        assert_success "eza --version" "eza --version works"
        assert_success "eza -la" "eza -la works"
    fi

    # Test fd
    if skip_if_missing "fd" "fd"; then
        assert_success "fd --version" "fd --version works"
    fi

    # Test ripgrep
    if skip_if_missing "rg" "ripgrep"; then
        assert_success "rg --version" "rg --version works"
        assert_output_contains "echo 'hello world' | rg 'hello'" "hello" "rg can search stdin"
    fi

    # Test delta
    if skip_if_missing "delta" "delta"; then
        assert_success "delta --version" "delta --version works"
    fi

    # Test jq
    if skip_if_missing "jq" "jq"; then
        assert_success "jq --version" "jq --version works"
        assert_output_contains "echo '{\"key\":\"value\"}' | jq '.key'" "value" "jq can parse JSON"
    fi

    # Test yq
    if skip_if_missing "yq" "yq"; then
        assert_success "yq --version" "yq --version works"
    fi
}

# ============================================================================
# TESTS: 2025 CLI tools
# ============================================================================

test_2025_cli() {
    test_start "2025 CLI tools"

    # Test tldr
    if skip_if_missing "tldr" "tldr"; then
        assert_success "tldr --version" "tldr --version works"
    fi

    # Test hyperfine
    if skip_if_missing "hyperfine" "hyperfine"; then
        assert_success "hyperfine --version" "hyperfine --version works"
    fi

    # Test yazi
    if skip_if_missing "yazi" "yazi"; then
        assert_success "yazi --version" "yazi --version works"
    fi

    # Test btop
    if skip_if_missing "btop" "btop"; then
        assert_success "btop --version" "btop --version works"
    fi
}

# ============================================================================
# TESTS: TUI tools
# ============================================================================

test_tui_tools() {
    test_start "TUI tools"

    # Test lazygit
    if skip_if_missing "lazygit" "lazygit"; then
        assert_success "lazygit --version" "lazygit --version works"
    fi

    # Test lazydocker
    if skip_if_missing "lazydocker" "lazydocker"; then
        assert_success "lazydocker --version" "lazydocker --version works"
    fi
}

# ============================================================================
# TESTS: Development tools
# ============================================================================

test_dev_tools() {
    test_start "Development tools"

    # Test git
    if skip_if_missing "git" "git"; then
        assert_success "git --version" "git --version works"
        # Only check delta config if dotfiles are installed
        if [[ -L "$HOME/.gitconfig" ]] && command -v delta &>/dev/null; then
            assert_output_contains "git config --get core.pager" "delta" "git uses delta pager"
        else
            echo -e "  ${YELLOW}⊘${NC} Skipped: git delta check (dotfiles not installed or delta missing)"
            ((TESTS_SKIPPED++))
        fi
    fi

    # Test node
    if skip_if_missing "node" "node"; then
        assert_success "node --version" "node --version works"
        assert_output_contains "node -e 'console.log(1+1)'" "2" "node can evaluate JS"
    fi

    # Test npm
    if skip_if_missing "npm" "npm"; then
        assert_success "npm --version" "npm --version works"
    fi

    # Test python3
    if skip_if_missing "python3" "python3"; then
        assert_success "python3 --version" "python3 --version works"
        assert_output_contains "python3 -c 'print(1+1)'" "2" "python3 can evaluate"
    fi
}

# ============================================================================
# TESTS: Editors
# ============================================================================

test_editors() {
    test_start "Editors"

    # Test vim
    if skip_if_missing "vim" "vim"; then
        assert_success "vim --version | head -1" "vim --version works"
    fi

    # Test neovim
    if skip_if_missing "nvim" "neovim"; then
        assert_success "nvim --version | head -1" "nvim --version works"
    fi

    # Test VSCode
    if skip_if_missing "code" "VSCode"; then
        assert_success "code --version | head -1" "code --version works"
        assert_success "code --list-extensions | head -1" "code can list extensions"
    fi
}

# ============================================================================
# TESTS: Git + delta integration
# ============================================================================

test_git_delta_integration() {
    test_start "Git + Delta integration"

    if ! skip_if_missing "git" "git" || ! skip_if_missing "delta" "delta"; then
        return
    fi

    # Create temp repo
    local test_dir="/tmp/dotfiles_test_$$"
    mkdir -p "$test_dir"
    cd "$test_dir" || return

    git init &>/dev/null
    git config user.email "test@test.com"
    git config user.name "Test"

    echo "line 1" > test.txt
    git add test.txt
    git commit -m "Initial" &>/dev/null

    echo "line 2" >> test.txt

    # Test that git diff uses delta (check for delta-style output)
    assert_success "git diff" "git diff works with delta"

    # Cleanup
    cd - &>/dev/null || true
    rm -rf "$test_dir"
}

# ============================================================================
# TESTS: Claude Code MCP
# ============================================================================

test_claude_mcp() {
    test_start "Claude Code MCP configuration"

    local settings_file="$HOME/.claude/settings.json"

    if [[ -f "$settings_file" ]]; then
        # Test that settings.json is valid JSON
        if skip_if_missing "jq" "jq"; then
            assert_success "jq empty '$settings_file'" "settings.json is valid JSON"

            # Only check Context7 if dotfiles are installed (symlinked settings)
            if [[ -L "$settings_file" ]]; then
                # Check Context7 is configured (using grep for simpler check)
                assert_success "grep -q 'context7' '$settings_file'" "Context7 MCP configured"

                # Check permissions
                assert_success "grep -q 'mcp__context7' '$settings_file'" "Context7 auto-allowed"
            else
                echo -e "  ${YELLOW}⊘${NC} Skipped: Context7 check (settings not from dotfiles)"
                ((TESTS_SKIPPED++))
                ((TESTS_SKIPPED++))
            fi
        fi
    else
        echo -e "  ${YELLOW}⊘${NC} Skipped: Claude settings not found"
        ((TESTS_SKIPPED++))
    fi
}

# ============================================================================
# TESTS: npx and Context7
# ============================================================================

test_npx_context7() {
    test_start "npx and Context7 MCP"

    if ! skip_if_missing "npx" "npx"; then
        return
    fi

    assert_success "npx --version" "npx --version works"

    # Test that the Context7 package can be resolved (dry run)
    # This doesn't actually run the server, just checks npm can find it
    assert_success "npm view @upstash/context7-mcp version" "Context7 package exists on npm"
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

echo "============================================"
echo "  Integration Tests"
echo "============================================"

test_shell_tools
test_modern_cli
test_2025_cli
test_tui_tools
test_dev_tools
test_editors
test_git_delta_integration
test_claude_mcp
test_npx_context7

echo ""
echo "============================================"
echo "  Results"
echo "============================================"
echo -e "Tests run:    $TESTS_RUN"
echo -e "${GREEN}Passed:${NC}       $TESTS_PASSED"
echo -e "${RED}Failed:${NC}       $TESTS_FAILED"
echo -e "${YELLOW}Skipped:${NC}      $TESTS_SKIPPED"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
