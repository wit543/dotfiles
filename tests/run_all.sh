#!/usr/bin/env bash
# ============================================================================
#                         TEST RUNNER
#                    github.com/wit543/dotfiles
# ============================================================================
# Runs all test suites
# Usage: ./tests/run_all.sh [--quick]
# ============================================================================

set -uo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
SUITES_RUN=0
SUITES_PASSED=0
SUITES_FAILED=0

# Parse arguments
QUICK_MODE=false
if [[ "${1:-}" == "--quick" ]]; then
    QUICK_MODE=true
fi

# ============================================================================
# FUNCTIONS
# ============================================================================

run_suite() {
    local suite="$1"
    local name="$2"

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Running: $name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    ((SUITES_RUN++))

    if "$SCRIPT_DIR/$suite"; then
        ((SUITES_PASSED++))
        return 0
    else
        ((SUITES_FAILED++))
        return 1
    fi
}

# ============================================================================
# MAIN
# ============================================================================

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║         DOTFILES TEST SUITE                ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}→${NC} Running from: $SCRIPT_DIR"
echo -e "${BLUE}→${NC} Quick mode: $QUICK_MODE"

# Make all test scripts executable
chmod +x "$SCRIPT_DIR"/*.sh

# Run test suites
run_suite "test_utils.sh" "Utility Functions" || true
run_suite "test_packages.sh" "Package Functions" || true
run_suite "test_configs.sh" "Configuration Files" || true

if [[ "$QUICK_MODE" == "false" ]]; then
    run_suite "test_integration.sh" "Integration Tests" || true
else
    echo ""
    echo -e "${YELLOW}⊘${NC} Skipping integration tests (quick mode)"
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║              FINAL SUMMARY                 ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo -e "Test suites run:    $SUITES_RUN"
echo -e "${GREEN}Suites passed:${NC}      $SUITES_PASSED"
echo -e "${RED}Suites failed:${NC}      $SUITES_FAILED"
echo ""

if [[ $SUITES_FAILED -eq 0 ]]; then
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         ✓ ALL TEST SUITES PASSED!          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║         ✗ SOME TEST SUITES FAILED          ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════╝${NC}"
    exit 1
fi
