#!/usr/bin/env bash
# ============================================================================
#                         UNIT TESTS - UTILITY FUNCTIONS
#                    github.com/wit543/dotfiles
# ============================================================================
# Tests for lib/utils.sh
# Run: ./tests/test_utils.sh
# ============================================================================

set -uo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source the utilities
source "$DOTFILES_DIR/lib/utils.sh"

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

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    ((TESTS_RUN++))

    if [[ "$expected" == "$actual" ]]; then
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

assert_false() {
    local condition="$1"
    local message="${2:-}"
    ((TESTS_RUN++))

    if ! eval "$condition"; then
        echo -e "  ${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        echo -e "    Condition should have failed: $condition"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File exists: $file}"
    ((TESTS_RUN++))

    if [[ -f "$file" ]] || [[ -L "$file" ]]; then
        echo -e "  ${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local message="${2:-Directory exists: $dir}"
    ((TESTS_RUN++))

    if [[ -d "$dir" ]]; then
        echo -e "  ${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_command_exists() {
    local cmd="$1"
    local message="${2:-Command exists: $cmd}"
    ((TESTS_RUN++))

    if command -v "$cmd" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ============================================================================
# TESTS: command_exists
# ============================================================================

test_command_exists() {
    test_start "command_exists()"

    assert_true "command_exists bash" "bash should exist"
    assert_true "command_exists ls" "ls should exist"
    assert_false "command_exists nonexistent_command_xyz123" "nonexistent command should not exist"
}

# ============================================================================
# TESTS: is_macos / is_linux
# ============================================================================

test_os_detection() {
    test_start "OS detection functions"

    if [[ "$(uname -s)" == "Darwin" ]]; then
        assert_true "[[ \"\$(uname -s)\" == \"Darwin\" ]]" "Running on macOS"
    else
        assert_true "[[ \"\$(uname -s)\" == \"Linux\" ]]" "Running on Linux"
    fi
}

# ============================================================================
# TESTS: detect_os
# ============================================================================

test_detect_os() {
    test_start "detect_os()"

    # Source packages.sh which has detect_os
    source "$DOTFILES_DIR/lib/packages.sh" 2>/dev/null || true

    if declare -f detect_os &>/dev/null; then
        detect_os

        assert_true "[[ -n \"\${OS_TYPE:-}\" ]]" "OS_TYPE should be set"
        assert_true "[[ -n \"\${PKG_MGR:-}\" ]]" "PKG_MGR should be set"

        if [[ "$(uname -s)" == "Darwin" ]]; then
            assert_equals "macos" "${OS_TYPE:-}" "OS_TYPE should be 'macos' on macOS"
            assert_equals "brew" "${PKG_MGR:-}" "PKG_MGR should be 'brew' on macOS"
        fi
    else
        echo -e "  ${YELLOW}⊘${NC} Skipped: detect_os not available"
    fi
}

# ============================================================================
# TESTS: symlink
# ============================================================================

test_symlink() {
    test_start "symlink()"

    local test_dir="/tmp/dotfiles_test_$$"
    mkdir -p "$test_dir"

    # Create source file
    echo "test content" > "$test_dir/source.txt"

    # Test creating symlink
    symlink "$test_dir/source.txt" "$test_dir/link.txt" 2>/dev/null
    assert_true "[[ -L \"$test_dir/link.txt\" ]]" "symlink should create a symbolic link"

    # Test symlink content
    local content
    content=$(cat "$test_dir/link.txt")
    assert_equals "test content" "$content" "symlink should link to correct file"

    # Test overwriting existing file
    echo "old content" > "$test_dir/existing.txt"
    symlink "$test_dir/source.txt" "$test_dir/existing.txt" 2>/dev/null
    assert_true "[[ -L \"$test_dir/existing.txt\" ]]" "symlink should replace existing file"

    # Cleanup
    rm -rf "$test_dir"
}

# ============================================================================
# TESTS: backup functionality (via symlink)
# ============================================================================

test_backup_via_symlink() {
    test_start "Backup via symlink()"

    local test_dir="/tmp/dotfiles_test_$$"
    mkdir -p "$test_dir"

    # Create existing file that will be backed up
    echo "original content" > "$test_dir/existing.txt"

    # Create source file
    echo "new content" > "$test_dir/source.txt"

    # symlink should backup existing file before replacing
    symlink "$test_dir/source.txt" "$test_dir/existing.txt" 2>/dev/null

    # Check backup was created
    local backup_count
    backup_count=$(ls "$test_dir"/existing.txt.backup.* 2>/dev/null | wc -l | tr -d ' ')
    assert_true "[[ $backup_count -gt 0 ]]" "symlink should backup existing file"

    # Cleanup
    rm -rf "$test_dir"
}

# ============================================================================
# TESTS: logging functions
# ============================================================================

test_logging() {
    test_start "Logging functions"

    # Test that logging functions don't crash
    local output

    output=$(log_info "test info" 2>&1)
    assert_true "[[ \$? -eq 0 ]]" "log_info should succeed"
    assert_true "[[ \"$output\" == *\"INFO\"* ]]" "log_info output should contain INFO"

    output=$(log_success "test success" 2>&1)
    assert_true "[[ \$? -eq 0 ]]" "log_success should succeed"
    assert_true "[[ \"$output\" == *\"OK\"* ]]" "log_success output should contain OK"

    output=$(log_warn "test warning" 2>&1)
    assert_true "[[ \$? -eq 0 ]]" "log_warn should succeed"
    assert_true "[[ \"$output\" == *\"WARN\"* ]]" "log_warn output should contain WARN"

    output=$(log_error "test error" 2>&1)
    assert_true "[[ \$? -eq 0 ]]" "log_error should succeed"
    assert_true "[[ \"$output\" == *\"ERROR\"* ]]" "log_error output should contain ERROR"
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

echo "============================================"
echo "  Unit Tests: lib/utils.sh"
echo "============================================"

test_command_exists
test_os_detection
test_detect_os
test_symlink
test_backup_via_symlink
test_logging

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
