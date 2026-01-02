#!/usr/bin/env bash
# ============================================================================
# INSTALLATION PROFILES
# ============================================================================
# Defines component sets for different machine types:
#   - minimal:     Basic shell setup for servers
#   - deploy:      Deployment machines (minimal + containers)
#   - development: Full dev environment
#   - full:        Everything including AI tools
# ============================================================================

# Profile definitions (space-separated component lists)
# Components: zsh vim tmux git vscode claude editorconfig docker

declare -A PROFILES

PROFILES[minimal]="zsh git editorconfig"
PROFILES[deploy]="zsh git editorconfig docker"
PROFILES[development]="zsh vim tmux git editorconfig docker vscode"
PROFILES[full]="zsh vim tmux git editorconfig docker vscode claude"

# Profile descriptions
declare -A PROFILE_DESC

PROFILE_DESC[minimal]="Basic shell setup (zsh, git, editorconfig) - ideal for servers"
PROFILE_DESC[deploy]="Deployment machine (minimal + docker) - for CI/CD and containers"
PROFILE_DESC[development]="Development environment (editors, tools, IDE) - for coding"
PROFILE_DESC[full]="Complete setup (all tools + AI assistant) - full workstation"

# Component descriptions
declare -A COMPONENT_DESC

COMPONENT_DESC[zsh]="Shell (Zsh + Zinit + Starship + zoxide + fzf)"
COMPONENT_DESC[vim]="Vim/Neovim (vim-plug + plugins)"
COMPONENT_DESC[tmux]="Tmux (gpakosz config + TPM)"
COMPONENT_DESC[git]="Git (gitconfig + delta + gitignore)"
COMPONENT_DESC[vscode]="VSCode (settings + keybindings + extensions)"
COMPONENT_DESC[claude]="Claude Code (MCP + settings)"
COMPONENT_DESC[editorconfig]="EditorConfig (universal formatting)"
COMPONENT_DESC[docker]="Docker tools (lazydocker)"

# ============================================================================
# FUNCTIONS
# ============================================================================

# List available profiles
list_profiles() {
    echo "Available profiles:"
    echo ""
    for profile in minimal deploy development full; do
        echo "  $profile"
        echo "    ${PROFILE_DESC[$profile]}"
        echo "    Components: ${PROFILES[$profile]}"
        echo ""
    done
}

# Get components for a profile
get_profile_components() {
    local profile="$1"
    echo "${PROFILES[$profile]}"
}

# Check if component is in profile
profile_has_component() {
    local profile="$1"
    local component="$2"
    local components="${PROFILES[$profile]}"
    [[ " $components " == *" $component "* ]]
}

# Validate profile name
validate_profile() {
    local profile="$1"
    [[ -n "${PROFILES[$profile]}" ]]
}

# Interactive profile selection
select_profile() {
    echo ""
    echo "Select installation profile:"
    echo ""
    echo "  1) minimal     - ${PROFILE_DESC[minimal]}"
    echo "  2) deploy      - ${PROFILE_DESC[deploy]}"
    echo "  3) development - ${PROFILE_DESC[development]}"
    echo "  4) full        - ${PROFILE_DESC[full]}"
    echo "  5) custom      - Select individual components"
    echo ""
    read -p "Enter choice [1-5]: " choice

    case $choice in
        1) echo "minimal" ;;
        2) echo "deploy" ;;
        3) echo "development" ;;
        4) echo "full" ;;
        5) echo "custom" ;;
        *) echo "full" ;;  # Default
    esac
}

# Interactive component selection (for custom profile)
select_components() {
    local selected=""
    echo ""
    echo "Select components to install:"
    echo ""

    for component in zsh vim tmux git vscode claude editorconfig docker; do
        read -p "  Install $component (${COMPONENT_DESC[$component]})? [Y/n]: " answer
        case $answer in
            [Nn]*) ;;
            *) selected="$selected $component" ;;
        esac
    done

    echo "$selected"
}
