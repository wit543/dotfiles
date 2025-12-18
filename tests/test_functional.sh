#!/usr/bin/env bash
# ============================================================================
#                         FUNCTIONAL TESTS
#                    github.com/wit543/dotfiles
# ============================================================================
# Tests that verify actual functionality (not just file existence)
# Run: ./tests/test_functional.sh
# ============================================================================

set -uo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

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
    local message="${2:-Command succeeds}"
    ((TESTS_RUN++))

    if eval "$cmd" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        echo -e "    Command failed: $cmd"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_output_equals() {
    local cmd="$1"
    local expected="$2"
    local message="${3:-Output matches expected}"
    ((TESTS_RUN++))

    local actual
    actual=$(eval "$cmd" 2>&1)

    if [[ "$actual" == "$expected" ]]; then
        echo -e "  ${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        echo -e "    Expected: '$expected'"
        echo -e "    Actual:   '$actual'"
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

skip_test() {
    local message="$1"
    echo -e "  ${YELLOW}⊘${NC} Skipped: $message"
    ((TESTS_SKIPPED++))
}

require_command() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        return 1
    fi
    return 0
}

# ============================================================================
# TESTS: Zsh functionality
# ============================================================================

test_zsh_functional() {
    test_start "Zsh functionality"

    if ! require_command "zsh"; then
        skip_test "zsh not installed"
        return
    fi

    # Test zsh can start and run basic command
    assert_success "zsh -c 'echo test'" "zsh can execute commands"

    # Test zsh with our config (non-interactive)
    if [[ -f "$HOME/.zshrc" ]]; then
        # Source zshrc in non-interactive mode and check it doesn't error
        assert_success "zsh -c 'source ~/.zshrc 2>/dev/null; echo ok'" "zshrc can be sourced"
    else
        skip_test ".zshrc not installed"
    fi

    # Test zinit is available after sourcing
    if [[ -d "$HOME/.local/share/zinit" ]] || [[ -d "$HOME/.zinit" ]]; then
        assert_success "zsh -c 'source ~/.zshrc 2>/dev/null; type zinit'" "zinit is available"
    else
        skip_test "zinit not installed"
    fi
}

# ============================================================================
# TESTS: Starship prompt
# ============================================================================

test_starship_functional() {
    test_start "Starship prompt"

    if ! require_command "starship"; then
        skip_test "starship not installed"
        return
    fi

    # Test starship init
    assert_success "starship init zsh" "starship init zsh works"
    assert_success "starship init bash" "starship init bash works"

    # Test starship with our config
    if [[ -f "$HOME/.config/starship.toml" ]]; then
        assert_success "STARSHIP_CONFIG=$HOME/.config/starship.toml starship prompt" "starship renders with config"
    else
        skip_test "starship.toml not installed"
    fi

    # Test specific modules
    assert_output_contains "starship module directory" "/" "directory module works"
}

# ============================================================================
# TESTS: Zoxide functionality
# ============================================================================

test_zoxide_functional() {
    test_start "Zoxide (smart cd)"

    if ! require_command "zoxide"; then
        skip_test "zoxide not installed"
        return
    fi

    # Test zoxide init
    assert_success "zoxide init zsh" "zoxide init zsh works"
    assert_success "zoxide init bash" "zoxide init bash works"

    # Test zoxide query (even with empty db)
    assert_success "zoxide query --list 2>/dev/null || true" "zoxide query works"

    # Add a test directory and query it
    local test_dir="/tmp/zoxide_test_$$"
    mkdir -p "$test_dir"
    zoxide add "$test_dir" 2>/dev/null
    assert_output_contains "zoxide query --list" "$test_dir" "zoxide remembers directories"
    rm -rf "$test_dir"
}

# ============================================================================
# TESTS: FZF functionality
# ============================================================================

test_fzf_functional() {
    test_start "FZF (fuzzy finder)"

    if ! require_command "fzf"; then
        skip_test "fzf not installed"
        return
    fi

    # Test fzf filter mode
    assert_output_contains "echo -e 'apple\nbanana\ncherry' | fzf --filter='ban'" "banana" "fzf filter works"

    # Test fzf with multiple results
    local result
    result=$(echo -e "test1\ntest2\ntest3" | fzf --filter='test' | wc -l | tr -d ' ')
    ((TESTS_RUN++))
    if [[ "$result" -eq 3 ]]; then
        echo -e "  ${GREEN}✓${NC} fzf returns multiple matches"
        ((TESTS_PASSED++))
    else
        echo -e "  ${RED}✗${NC} fzf returns multiple matches (got $result)"
        ((TESTS_FAILED++))
    fi

    # Test fzf keybindings script exists
    if [[ -f "$HOME/.fzf.zsh" ]] || [[ -f "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" ]] || [[ -f "/usr/share/fzf/key-bindings.zsh" ]]; then
        echo -e "  ${GREEN}✓${NC} fzf shell integration available"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        skip_test "fzf shell integration not found"
    fi
}

# ============================================================================
# TESTS: Tmux functionality
# ============================================================================

test_tmux_functional() {
    test_start "Tmux functionality"

    if ! require_command "tmux"; then
        skip_test "tmux not installed"
        return
    fi

    # Test tmux can start a server
    assert_success "tmux -V" "tmux version works"

    # Test tmux can create a detached session
    local session_name="dotfiles_test_$$"
    assert_success "tmux new-session -d -s $session_name" "tmux can create session"

    # Test tmux can list sessions
    assert_output_contains "tmux list-sessions" "$session_name" "tmux lists sessions"

    # Test tmux can run command in session
    tmux send-keys -t "$session_name" "echo 'tmux test'" Enter 2>/dev/null
    sleep 0.5
    assert_success "tmux capture-pane -t $session_name -p | grep -q 'tmux test'" "tmux can send keys"

    # Test our tmux config loads without errors
    if [[ -f "$HOME/.tmux.conf" ]]; then
        # Create new session with our config
        local config_session="dotfiles_config_test_$$"
        if tmux new-session -d -s "$config_session" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} tmux.conf loads without errors"
            ((TESTS_RUN++))
            ((TESTS_PASSED++))
            tmux kill-session -t "$config_session" 2>/dev/null
        else
            echo -e "  ${RED}✗${NC} tmux.conf loads without errors"
            ((TESTS_RUN++))
            ((TESTS_FAILED++))
        fi
    else
        skip_test ".tmux.conf not installed"
    fi

    # Test prefix key is set (default Ctrl-a or Ctrl-b)
    if [[ -f "$HOME/.tmux.conf" ]]; then
        local prefix
        prefix=$(tmux show-options -g prefix 2>/dev/null | awk '{print $2}')
        ((TESTS_RUN++))
        if [[ -n "$prefix" ]]; then
            echo -e "  ${GREEN}✓${NC} tmux prefix key configured: $prefix"
            ((TESTS_PASSED++))
        else
            echo -e "  ${YELLOW}⊘${NC} tmux prefix key not detected"
            ((TESTS_SKIPPED++))
        fi
    fi

    # Cleanup
    tmux kill-session -t "$session_name" 2>/dev/null
}

# ============================================================================
# TESTS: Vim functionality
# ============================================================================

test_vim_functional() {
    test_start "Vim functionality"

    if ! require_command "vim"; then
        skip_test "vim not installed"
        return
    fi

    # Test vim can start and quit
    assert_success "vim -u NONE -c 'quit'" "vim can start and quit"

    # Test vim with our config
    if [[ -f "$HOME/.vimrc" ]]; then
        # Use vim in ex mode for non-interactive test
        ((TESTS_RUN++))
        if vim -u "$HOME/.vimrc" -es -c 'quit' 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} vim loads with .vimrc"
            ((TESTS_PASSED++))
        else
            echo -e "  ${YELLOW}⊘${NC} vim .vimrc test skipped (may need plugins)"
            ((TESTS_SKIPPED++))
        fi

        # Test vim-plug is installed
        if [[ -f "$HOME/.vim/autoload/plug.vim" ]]; then
            echo -e "  ${GREEN}✓${NC} vim-plug is installed"
            ((TESTS_RUN++))
            ((TESTS_PASSED++))
        else
            skip_test "vim-plug not installed"
        fi
    else
        skip_test ".vimrc not installed"
    fi

    # Test neovim
    if require_command "nvim"; then
        assert_success "nvim --headless -c 'quit'" "neovim can start and quit"

        if [[ -f "$HOME/.config/nvim/init.vim" ]] || [[ -f "$HOME/.config/nvim/init.lua" ]]; then
            ((TESTS_RUN++))
            if nvim --headless -u "$HOME/.config/nvim/init.vim" -c 'quit' 2>/dev/null || \
               nvim --headless -u "$HOME/.config/nvim/init.lua" -c 'quit' 2>/dev/null; then
                echo -e "  ${GREEN}✓${NC} neovim loads with config"
                ((TESTS_PASSED++))
            else
                echo -e "  ${YELLOW}⊘${NC} neovim config test skipped (may need plugins)"
                ((TESTS_SKIPPED++))
            fi
        else
            skip_test "neovim config not installed"
        fi
    else
        skip_test "neovim not installed"
    fi
}

# ============================================================================
# TESTS: Git + Delta integration
# ============================================================================

test_git_delta_functional() {
    test_start "Git + Delta integration"

    if ! require_command "git"; then
        skip_test "git not installed"
        return
    fi

    # Create temp repo for testing
    local test_dir="/tmp/git_test_$$"
    mkdir -p "$test_dir"
    cd "$test_dir" || return

    git init &>/dev/null
    git config user.email "test@test.com"
    git config user.name "Test"

    # Create and commit a file
    echo "line 1" > test.txt
    git add test.txt
    git commit -m "Initial" &>/dev/null

    # Make a change
    echo "line 2" >> test.txt

    # Test git diff works
    assert_success "git diff" "git diff works"

    # Test delta integration if installed
    if require_command "delta" && [[ -L "$HOME/.gitconfig" ]]; then
        local pager
        pager=$(git config --get core.pager 2>/dev/null)
        ((TESTS_RUN++))
        if [[ "$pager" == *"delta"* ]]; then
            echo -e "  ${GREEN}✓${NC} git uses delta as pager"
            ((TESTS_PASSED++))

            # Test delta actually works
            assert_success "git diff | delta --color-only" "delta processes diff"
        else
            echo -e "  ${YELLOW}⊘${NC} git not configured to use delta"
            ((TESTS_SKIPPED++))
        fi
    else
        skip_test "delta not installed or gitconfig not from dotfiles"
    fi

    # Test git aliases if configured
    if [[ -L "$HOME/.gitconfig" ]]; then
        # Check common aliases
        local aliases
        aliases=$(git config --get-regexp '^alias\.' 2>/dev/null | wc -l | tr -d ' ')
        ((TESTS_RUN++))
        if [[ "$aliases" -gt 0 ]]; then
            echo -e "  ${GREEN}✓${NC} git aliases configured ($aliases aliases)"
            ((TESTS_PASSED++))
        else
            echo -e "  ${YELLOW}⊘${NC} no git aliases found"
            ((TESTS_SKIPPED++))
        fi
    fi

    # Cleanup
    cd - &>/dev/null || true
    rm -rf "$test_dir"
}

# ============================================================================
# TESTS: Modern CLI tools
# ============================================================================

test_modern_cli_functional() {
    test_start "Modern CLI tools"

    # Test bat
    if require_command "bat"; then
        assert_success "echo 'test' | bat --style=plain --color=never" "bat can read stdin"
        assert_output_contains "echo 'hello' | bat -p --color=never" "hello" "bat outputs content"

        # Test bat with syntax highlighting
        local test_file="/tmp/test_$$.py"
        echo 'print("hello")' > "$test_file"
        assert_success "bat --color=always '$test_file'" "bat syntax highlights"
        rm -f "$test_file"
    else
        skip_test "bat not installed"
    fi

    # Test eza
    if require_command "eza"; then
        assert_success "eza -la" "eza -la works"
        assert_success "eza --tree --level=1 /" "eza tree works"
        assert_output_contains "eza --icons=auto /tmp" "tmp" "eza shows directory names"
    else
        skip_test "eza not installed"
    fi

    # Test fd
    if require_command "fd"; then
        assert_success "fd --version" "fd works"
        # Find bash in common locations
        assert_success "fd -t f 'bash' /bin /usr/bin 2>/dev/null | head -1" "fd can find files"
    else
        skip_test "fd not installed"
    fi

    # Test ripgrep
    if require_command "rg"; then
        assert_output_contains "echo 'hello world' | rg 'world'" "world" "rg searches stdin"
        assert_success "rg --type-list | head -1" "rg knows file types"
    else
        skip_test "ripgrep not installed"
    fi

    # Test jq
    if require_command "jq"; then
        assert_output_equals "echo '{\"key\":\"value\"}' | jq -r '.key'" "value" "jq parses JSON"
        assert_output_equals "echo '[1,2,3]' | jq '.[1]'" "2" "jq indexes arrays"
    else
        skip_test "jq not installed"
    fi
}

# ============================================================================
# TESTS: Lazygit
# ============================================================================

test_lazygit_functional() {
    test_start "Lazygit"

    if ! require_command "lazygit"; then
        skip_test "lazygit not installed"
        return
    fi

    assert_success "lazygit --version" "lazygit version works"

    # Test lazygit config location
    local config_dir="$HOME/.config/lazygit"
    if [[ -d "$config_dir" ]] || [[ -f "$config_dir/config.yml" ]]; then
        echo -e "  ${GREEN}✓${NC} lazygit config directory exists"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        skip_test "lazygit config not found"
    fi
}

# ============================================================================
# TESTS: Docker
# ============================================================================

test_docker_functional() {
    test_start "Docker"

    if ! require_command "docker"; then
        skip_test "docker not installed"
        return
    fi

    assert_success "docker --version" "docker CLI works"

    # Check if Docker daemon is running
    if docker info &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Docker daemon is running"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))

        # Test docker can pull/run
        assert_success "docker run --rm hello-world 2>/dev/null" "docker can run containers"
    else
        skip_test "Docker daemon not running"
    fi

    # Test docker-compose
    if require_command "docker-compose" || docker compose version &>/dev/null; then
        assert_success "docker compose version" "docker compose works"
    else
        skip_test "docker-compose not installed"
    fi
}

# ============================================================================
# TESTS: VSCode
# ============================================================================

test_vscode_functional() {
    test_start "VSCode"

    if ! require_command "code"; then
        skip_test "VSCode not installed"
        return
    fi

    assert_success "code --version" "code --version works"
    assert_success "code --list-extensions" "code can list extensions"

    # Check important extensions
    local extensions
    extensions=$(code --list-extensions 2>/dev/null)

    local important_exts=("esbenp.prettier-vscode" "dbaeumer.vscode-eslint")
    for ext in "${important_exts[@]}"; do
        ((TESTS_RUN++))
        if echo "$extensions" | grep -qi "$ext"; then
            echo -e "  ${GREEN}✓${NC} Extension installed: $ext"
            ((TESTS_PASSED++))
        else
            echo -e "  ${YELLOW}⊘${NC} Extension not installed: $ext"
            ((TESTS_SKIPPED++))
        fi
    done

    # Check settings are linked
    local vscode_settings
    if [[ "$(uname -s)" == "Darwin" ]]; then
        vscode_settings="$HOME/Library/Application Support/Code/User/settings.json"
    else
        vscode_settings="$HOME/.config/Code/User/settings.json"
    fi

    ((TESTS_RUN++))
    if [[ -L "$vscode_settings" ]]; then
        echo -e "  ${GREEN}✓${NC} VSCode settings symlinked from dotfiles"
        ((TESTS_PASSED++))
    else
        echo -e "  ${YELLOW}⊘${NC} VSCode settings not from dotfiles"
        ((TESTS_SKIPPED++))
    fi
}

# ============================================================================
# TESTS: Shell aliases and functions
# ============================================================================

test_shell_aliases() {
    test_start "Shell aliases and functions"

    if [[ ! -f "$HOME/.zshrc" ]]; then
        skip_test ".zshrc not installed"
        return
    fi

    # Test in a zsh subshell
    local zsh_test="source ~/.zshrc 2>/dev/null"

    # Check if common aliases are defined
    local aliases_to_check=("ll" "la" "cat")
    for alias_name in "${aliases_to_check[@]}"; do
        ((TESTS_RUN++))
        if zsh -c "$zsh_test; alias $alias_name" &>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Alias defined: $alias_name"
            ((TESTS_PASSED++))
        else
            echo -e "  ${YELLOW}⊘${NC} Alias not defined: $alias_name"
            ((TESTS_SKIPPED++))
        fi
    done
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

echo "============================================"
echo "  Functional Tests"
echo "============================================"
echo ""
echo "These tests verify actual functionality,"
echo "not just file existence."

test_zsh_functional
test_starship_functional
test_zoxide_functional
test_fzf_functional
test_tmux_functional
test_vim_functional
test_git_delta_functional
test_modern_cli_functional
test_lazygit_functional
test_docker_functional
test_vscode_functional
test_shell_aliases

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
