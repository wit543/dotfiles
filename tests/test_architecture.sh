#!/usr/bin/env bash
# ============================================================================
#                         UNIT TESTS - ARCHITECTURE SYNC
#                    github.com/wit543/dotfiles
# ============================================================================
# Validates that the codebase matches the architecture documentation
# Run: ./tests/test_architecture.sh
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
BLUE='\033[0;34m'
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
        echo -e "  ${RED}✗${NC} $message (missing: $file)"
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
        echo -e "  ${RED}✗${NC} $message (missing: $dir)"
        ((TESTS_FAILED++))
        return 1
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
        echo -e "  ${RED}✗${NC} $message (pattern: $pattern)"
        ((TESTS_FAILED++))
        return 1
    fi
}

# ============================================================================
# TESTS: Directory Structure (per ARCHITECTURE.md)
# ============================================================================

test_directory_structure() {
    test_start "Directory Structure (ARCHITECTURE.md compliance)"

    # Root level files
    assert_file_exists "$DOTFILES_DIR/bootstrap.sh" "bootstrap.sh exists"
    assert_file_exists "$DOTFILES_DIR/install.sh" "install.sh exists"
    assert_file_exists "$DOTFILES_DIR/install-tui.py" "install-tui.py exists"

    # lib/ directory
    assert_dir_exists "$DOTFILES_DIR/lib" "lib/ directory exists"
    assert_file_exists "$DOTFILES_DIR/lib/utils.sh" "lib/utils.sh exists"
    assert_file_exists "$DOTFILES_DIR/lib/packages.sh" "lib/packages.sh exists"

    # config/ subdirectories
    assert_dir_exists "$DOTFILES_DIR/config/zsh" "config/zsh/ exists"
    assert_dir_exists "$DOTFILES_DIR/config/vim" "config/vim/ exists"
    assert_dir_exists "$DOTFILES_DIR/config/nvim" "config/nvim/ exists"
    assert_dir_exists "$DOTFILES_DIR/config/tmux" "config/tmux/ exists"
    assert_dir_exists "$DOTFILES_DIR/config/git" "config/git/ exists"
    assert_dir_exists "$DOTFILES_DIR/config/vscode" "config/vscode/ exists"
    assert_dir_exists "$DOTFILES_DIR/config/claude" "config/claude/ exists"
    assert_dir_exists "$DOTFILES_DIR/config/windows" "config/windows/ exists"

    # packages/ directory
    assert_dir_exists "$DOTFILES_DIR/packages" "packages/ directory exists"
    assert_file_exists "$DOTFILES_DIR/packages/Brewfile" "packages/Brewfile exists"
    assert_file_exists "$DOTFILES_DIR/packages/apt.txt" "packages/apt.txt exists"
    assert_file_exists "$DOTFILES_DIR/packages/dnf.txt" "packages/dnf.txt exists"
    assert_file_exists "$DOTFILES_DIR/packages/pacman.txt" "packages/pacman.txt exists"

    # docs/ directory
    assert_dir_exists "$DOTFILES_DIR/docs" "docs/ directory exists"
    assert_file_exists "$DOTFILES_DIR/docs/ARCHITECTURE.md" "docs/ARCHITECTURE.md exists"
    assert_file_exists "$DOTFILES_DIR/docs/COMPATIBILITY.md" "docs/COMPATIBILITY.md exists"
}

# ============================================================================
# TESTS: Entry Points (per ARCHITECTURE.md flowchart)
# ============================================================================

test_entry_points() {
    test_start "Entry Points (ARCHITECTURE.md flowchart)"

    # macOS/Linux entry points
    assert_file_exists "$DOTFILES_DIR/bootstrap.sh" "bootstrap.sh entry point"
    assert_file_exists "$DOTFILES_DIR/install-tui.py" "install-tui.py entry point"

    # Windows entry points
    assert_file_exists "$DOTFILES_DIR/config/windows/setup.ps1" "setup.ps1 main script"
    assert_file_exists "$DOTFILES_DIR/config/windows/install.ps1" "install.ps1 one-liner"
    assert_file_exists "$DOTFILES_DIR/config/windows/install.cmd" "install.cmd one-liner"

    # Bootstrap should reference install.sh
    assert_contains "$DOTFILES_DIR/bootstrap.sh" "install.sh" "bootstrap.sh calls install.sh"
}

# ============================================================================
# TESTS: Installation Modes (per ARCHITECTURE.md)
# ============================================================================

test_installation_modes() {
    test_start "Installation Modes (--sudo, --no-sudo, --update)"

    local install_script="$DOTFILES_DIR/install.sh"

    # Check install.sh supports documented modes
    assert_contains "$install_script" "\-\-sudo" "install.sh supports --sudo"
    assert_contains "$install_script" "\-\-no-sudo" "install.sh supports --no-sudo"
    assert_contains "$install_script" "\-\-update" "install.sh supports --update"
}

# ============================================================================
# TESTS: Package Manager Support (per ARCHITECTURE.md)
# ============================================================================

test_package_managers() {
    test_start "Package Manager Support"

    # Check package files exist for each documented OS
    assert_file_exists "$DOTFILES_DIR/packages/Brewfile" "Homebrew (macOS) package file"
    assert_file_exists "$DOTFILES_DIR/packages/apt.txt" "apt (Ubuntu/Debian) package file"
    assert_file_exists "$DOTFILES_DIR/packages/dnf.txt" "dnf (Rocky/RHEL) package file"
    assert_file_exists "$DOTFILES_DIR/packages/pacman.txt" "pacman (Manjaro/Arch) package file"

    # Windows packages are in setup.ps1
    assert_contains "$DOTFILES_DIR/config/windows/setup.ps1" "winget" "Windows uses winget"
}

# ============================================================================
# TESTS: Configuration Files (per ARCHITECTURE.md file mapping)
# ============================================================================

test_config_file_mapping() {
    test_start "Configuration File Mapping"

    # Zsh configs
    assert_file_exists "$DOTFILES_DIR/config/zsh/.zshrc" "config/zsh/.zshrc"
    assert_file_exists "$DOTFILES_DIR/config/zsh/starship.toml" "config/zsh/starship.toml"

    # Vim configs
    assert_file_exists "$DOTFILES_DIR/config/vim/.vimrc" "config/vim/.vimrc"

    # Tmux configs
    assert_file_exists "$DOTFILES_DIR/config/tmux/.tmux.conf" "config/tmux/.tmux.conf"

    # Git configs
    assert_file_exists "$DOTFILES_DIR/config/git/.gitconfig" "config/git/.gitconfig"

    # VSCode configs
    assert_file_exists "$DOTFILES_DIR/config/vscode/settings.json" "config/vscode/settings.json"

    # Claude configs
    assert_file_exists "$DOTFILES_DIR/config/claude/settings.json" "config/claude/settings.json"
    assert_file_exists "$DOTFILES_DIR/config/claude/CLAUDE.md" "config/claude/CLAUDE.md"
}

# ============================================================================
# TESTS: Shell Environment (per ARCHITECTURE.md Zsh initialization)
# ============================================================================

test_shell_environment() {
    test_start "Shell Environment Configuration"

    local zshrc="$DOTFILES_DIR/config/zsh/.zshrc"

    # Zinit plugin manager
    assert_contains "$zshrc" "zinit" "Uses Zinit plugin manager"

    # Starship prompt
    assert_contains "$zshrc" "starship" "Starship prompt initialization"

    # Zoxide
    assert_contains "$zshrc" "zoxide" "Zoxide initialization"

    # FZF
    assert_contains "$zshrc" "fzf" "FZF integration"

    # Modern CLI aliases (per ARCHITECTURE.md)
    assert_contains "$zshrc" "eza" "eza alias (ls replacement)"
    assert_contains "$zshrc" "bat" "bat alias (cat replacement)"
}

# ============================================================================
# TESTS: Claude Code Configuration (per ARCHITECTURE.md permission flow)
# ============================================================================

test_claude_code_config() {
    test_start "Claude Code Configuration"

    local settings="$DOTFILES_DIR/config/claude/settings.json"

    # WebSearch and WebFetch always allowed
    assert_contains "$settings" "WebSearch" "WebSearch permission"
    assert_contains "$settings" "WebFetch" "WebFetch permission"

    # MCP Context7 configuration
    assert_contains "$settings" "mcpServers" "MCP servers configured"
    assert_contains "$settings" "context7" "Context7 MCP server"
    assert_contains "$settings" "mcp__context7" "Context7 auto-allowed"

    # Permissions structure
    assert_contains "$settings" "permissions" "Permissions section"
    assert_contains "$settings" "allow" "Allow list"
}

# ============================================================================
# TESTS: Windows Setup (per ARCHITECTURE.md 14-step process)
# ============================================================================

test_windows_setup() {
    test_start "Windows Setup Script"

    local setup="$DOTFILES_DIR/config/windows/setup.ps1"

    # Check key steps documented in ARCHITECTURE.md
    assert_contains "$setup" "Bloatware" "Step 1: Remove Bloatware"
    assert_contains "$setup" "Telemetry\|telemetry" "Step 2: Disable Telemetry"
    assert_contains "$setup" "CLI\|cli" "Steps 4-5: CLI Tools"
    assert_contains "$setup" "lazygit\|lazydocker" "Step 5: TUI Tools"
    assert_contains "$setup" "Node\|Python\|Go" "Step 6: Dev Tools"
    assert_contains "$setup" "Chrome\|VSCode" "Step 7: Applications"
    assert_contains "$setup" "Nerd.*Font\|NerdFont\|MesloLG" "Step 8: Nerd Font"
    assert_contains "$setup" "gitconfig\|Git.*config" "Step 9: Git Config"
    assert_contains "$setup" "starship" "Step 10: Starship Config"
    assert_contains "$setup" "VSCode\|vscode" "Step 11: VSCode Config"
    assert_contains "$setup" "Claude\|claude" "Step 12: Claude Config"
    assert_contains "$setup" "claude-code\|@anthropic" "Step 13: Claude CLI"
    assert_contains "$setup" "PROFILE\|Profile" "Step 14: PowerShell Profile"
}

# ============================================================================
# TESTS: Documentation Sync
# ============================================================================

test_documentation_sync() {
    test_start "Documentation Sync"

    local arch_doc="$DOTFILES_DIR/docs/ARCHITECTURE.md"
    local readme="$DOTFILES_DIR/README.md"

    # Check ARCHITECTURE.md exists and has key sections
    assert_file_exists "$arch_doc" "ARCHITECTURE.md exists"
    assert_contains "$arch_doc" "mermaid" "Contains Mermaid diagrams"
    assert_contains "$arch_doc" "Entry Points" "Documents entry points"
    assert_contains "$arch_doc" "Package Installation" "Documents package installation"
    assert_contains "$arch_doc" "Configuration Deployment" "Documents config deployment"
    assert_contains "$arch_doc" "Shell Environment" "Documents shell environment"
    assert_contains "$arch_doc" "Claude Code" "Documents Claude Code"
    assert_contains "$arch_doc" "Windows" "Documents Windows setup"

    # Check README mentions all platforms
    assert_contains "$readme" "macOS" "README mentions macOS"
    assert_contains "$readme" "Ubuntu" "README mentions Ubuntu"
    assert_contains "$readme" "Rocky" "README mentions Rocky Linux"
    assert_contains "$readme" "Manjaro" "README mentions Manjaro"
    assert_contains "$readme" "Windows" "README mentions Windows"
}

# ============================================================================
# TESTS: Compatibility Document Sync
# ============================================================================

test_compatibility_sync() {
    test_start "Compatibility Document Sync"

    local compat_doc="$DOTFILES_DIR/docs/COMPATIBILITY.md"

    assert_file_exists "$compat_doc" "COMPATIBILITY.md exists"
    assert_contains "$compat_doc" "Platform Support Matrix" "Has platform matrix"
    assert_contains "$compat_doc" "CLI Tools Compatibility" "Has CLI tools section"
    assert_contains "$compat_doc" "Configuration File Mapping" "Has config mapping"
    assert_contains "$compat_doc" "Claude Code Permissions" "Has Claude permissions"
    assert_contains "$compat_doc" "Version Requirements" "Has version requirements"
}

# ============================================================================
# TESTS: Modern CLI Tools (per ARCHITECTURE.md/README)
# ============================================================================

test_modern_cli_tools() {
    test_start "Modern CLI Tools Documentation"

    local readme="$DOTFILES_DIR/README.md"
    local zshrc="$DOTFILES_DIR/config/zsh/.zshrc"

    # Tools documented in README should be in zshrc
    assert_contains "$zshrc" "eza" "eza configured in zshrc"
    assert_contains "$zshrc" "bat" "bat configured in zshrc"
    assert_contains "$zshrc" "lazygit" "lazygit alias in zshrc"

    # README should document the tools
    assert_contains "$readme" "eza" "eza documented in README"
    assert_contains "$readme" "bat" "bat documented in README"
    assert_contains "$readme" "delta" "delta documented in README"
    assert_contains "$readme" "zoxide" "zoxide documented in README"
    assert_contains "$readme" "lazygit" "lazygit documented in README"
}

# ============================================================================
# TESTS: Install Script Functions (per ARCHITECTURE.md)
# ============================================================================

test_install_functions() {
    test_start "Install Script Functions"

    local install="$DOTFILES_DIR/install.sh"

    # Functions documented in architecture
    assert_contains "$install" "setup_zsh" "setup_zsh function"
    assert_contains "$install" "setup_vim" "setup_vim function"
    assert_contains "$install" "setup_tmux" "setup_tmux function"
    assert_contains "$install" "setup_git" "setup_git function"
    assert_contains "$install" "setup_vscode" "setup_vscode function"
    assert_contains "$install" "setup_claude" "setup_claude function"
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Architecture Sync Tests                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "Validating codebase matches docs/ARCHITECTURE.md"

test_directory_structure
test_entry_points
test_installation_modes
test_package_managers
test_config_file_mapping
test_shell_environment
test_claude_code_config
test_windows_setup
test_documentation_sync
test_compatibility_sync
test_modern_cli_tools
test_install_functions

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              Results                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Tests run:    $TESTS_RUN"
echo -e "${GREEN}Passed:${NC}       $TESTS_PASSED"
echo -e "${RED}Failed:${NC}       $TESTS_FAILED"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ Architecture sync verified - all tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Architecture out of sync - $TESTS_FAILED tests failed${NC}"
    echo -e "${YELLOW}Update docs/ARCHITECTURE.md or fix codebase to match${NC}"
    exit 1
fi
