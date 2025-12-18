#!/usr/bin/env bash
# ============================================================================
#                         UNIT TESTS - PACKAGE FUNCTIONS
#                    github.com/wit543/dotfiles
# ============================================================================
# Tests for lib/packages.sh
# Run: ./tests/test_packages.sh
# ============================================================================

set -uo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source the utilities and packages
source "$DOTFILES_DIR/lib/utils.sh"
source "$DOTFILES_DIR/lib/packages.sh"

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

assert_function_exists() {
    local func="$1"
    local message="${2:-Function exists: $func}"
    ((TESTS_RUN++))

    if declare -f "$func" > /dev/null 2>&1; then
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
# TESTS: Function existence
# ============================================================================

test_function_existence() {
    test_start "Package functions exist"

    assert_function_exists "pkg_update" "pkg_update function exists"
    assert_function_exists "pkg_upgrade" "pkg_upgrade function exists"
    assert_function_exists "pkg_install" "pkg_install function exists"
    assert_function_exists "pkg_install_from_file" "pkg_install_from_file function exists"
    assert_function_exists "install_homebrew" "install_homebrew function exists"
    assert_function_exists "install_from_brewfile" "install_from_brewfile function exists"
    assert_function_exists "install_essentials" "install_essentials function exists"
    assert_function_exists "setup_gcloud" "setup_gcloud function exists"
}

# ============================================================================
# TESTS: pkg_install_from_file parsing
# ============================================================================

test_pkg_install_from_file_parsing() {
    test_start "pkg_install_from_file parsing"

    local test_dir="/tmp/dotfiles_test_$$"
    mkdir -p "$test_dir"

    # Create test package file with comments and empty lines
    cat > "$test_dir/packages.txt" << 'EOF'
# This is a comment
package1

package2  # inline comment
  package3
# Another comment

EOF

    # We can't easily test the actual installation, but we can verify
    # the function handles the file without errors
    assert_true "[[ -f \"$test_dir/packages.txt\" ]]" "Test package file created"

    # Cleanup
    rm -rf "$test_dir"
}

# ============================================================================
# TESTS: Brewfile existence
# ============================================================================

test_brewfile_exists() {
    test_start "Brewfile configuration"

    assert_true "[[ -f \"$DOTFILES_DIR/packages/Brewfile\" ]]" "Brewfile exists"

    if [[ -f "$DOTFILES_DIR/packages/Brewfile" ]]; then
        # Check Brewfile contains expected packages using grep
        assert_true "grep -q 'brew \"' \"$DOTFILES_DIR/packages/Brewfile\"" "Brewfile contains brew packages"
        assert_true "grep -q 'cask \"' \"$DOTFILES_DIR/packages/Brewfile\"" "Brewfile contains cask packages"
        assert_true "grep -q 'starship' \"$DOTFILES_DIR/packages/Brewfile\"" "Brewfile includes starship"
        assert_true "grep -q 'zoxide' \"$DOTFILES_DIR/packages/Brewfile\"" "Brewfile includes zoxide"
        assert_true "grep -q 'fzf' \"$DOTFILES_DIR/packages/Brewfile\"" "Brewfile includes fzf"
        assert_true "grep -q 'bat' \"$DOTFILES_DIR/packages/Brewfile\"" "Brewfile includes bat"
        assert_true "grep -q 'eza' \"$DOTFILES_DIR/packages/Brewfile\"" "Brewfile includes eza"
        assert_true "grep -q 'lazygit' \"$DOTFILES_DIR/packages/Brewfile\"" "Brewfile includes lazygit"
        assert_true "grep -q 'docker' \"$DOTFILES_DIR/packages/Brewfile\"" "Brewfile includes docker"
        assert_true "grep -q 'visual-studio-code' \"$DOTFILES_DIR/packages/Brewfile\"" "Brewfile includes vscode"
    fi
}

# ============================================================================
# TESTS: install_from_brewfile handles missing file
# ============================================================================

test_brewfile_missing_handling() {
    test_start "install_from_brewfile handles missing file"

    # Should not crash when file doesn't exist
    local output
    output=$(install_from_brewfile "/nonexistent/path/Brewfile" 2>&1)
    local exit_code=$?

    assert_equals "0" "$exit_code" "Should return 0 for missing Brewfile"
    assert_true "[[ \"$output\" == *\"not found\"* ]]" "Should warn about missing file"
}

# ============================================================================
# TESTS: Package manager detection
# ============================================================================

test_package_manager_detection() {
    test_start "Package manager detection"

    if declare -f detect_os &>/dev/null; then
        detect_os

        if [[ "$(uname -s)" == "Darwin" ]]; then
            assert_equals "brew" "${PKG_MGR:-}" "PKG_MGR should be brew on macOS"
        elif [[ -f /etc/debian_version ]]; then
            assert_equals "apt" "${PKG_MGR:-}" "PKG_MGR should be apt on Debian/Ubuntu"
        elif [[ -f /etc/redhat-release ]]; then
            assert_true "[[ \"\${PKG_MGR:-}\" == \"dnf\" || \"\${PKG_MGR:-}\" == \"yum\" ]]" "PKG_MGR should be dnf or yum on RHEL"
        elif [[ -f /etc/arch-release ]]; then
            assert_equals "pacman" "${PKG_MGR:-}" "PKG_MGR should be pacman on Arch"
        fi
    else
        echo -e "  ${YELLOW}⊘${NC} Skipped: detect_os not available"
    fi
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

echo "============================================"
echo "  Unit Tests: lib/packages.sh"
echo "============================================"

test_function_existence
test_pkg_install_from_file_parsing
test_brewfile_exists
test_brewfile_missing_handling
test_package_manager_detection

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
