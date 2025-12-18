#!/usr/bin/env bash
# ============================================================================
#                         OS DETECTION
#                    github.com/wit543/dotfiles
# ============================================================================
# Detects the operating system and sets appropriate variables
# Exports: OS_TYPE, OS_NAME, OS_VERSION, PKG_MGR
# ============================================================================

# ============================================================================
# MAIN DETECTION FUNCTION
# ============================================================================
# NOTE: Call this function to populate OS variables
# Sets: OS_TYPE (macos|debian|rhel|arch|unknown)
#       OS_NAME (e.g., "macOS", "Ubuntu", "Rocky Linux")
#       OS_VERSION (e.g., "14.0", "22.04")
#       PKG_MGR (brew|apt|dnf|yum|pacman|unknown)

detect_os() {
    OS_TYPE="unknown"
    OS_NAME="unknown"
    OS_VERSION="unknown"
    PKG_MGR="unknown"

    # -------------------------
    # macOS Detection
    # -------------------------
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
        OS_NAME="macOS"
        OS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
        PKG_MGR="brew"

    # -------------------------
    # Linux Detection (via os-release)
    # -------------------------
    elif [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        OS_NAME="$NAME"
        OS_VERSION="${VERSION_ID:-unknown}"

        case "$ID" in
            # Debian-based: Ubuntu, Debian, Linux Mint, Pop!_OS, etc.
            ubuntu|debian)
                OS_TYPE="debian"
                PKG_MGR="apt"
                ;;
            # RHEL-based: Rocky, AlmaLinux, CentOS, Fedora, etc.
            rocky|rhel|centos|fedora|almalinux)
                OS_TYPE="rhel"
                PKG_MGR="dnf"
                ;;
            # Arch-based: Arch, Manjaro, EndeavourOS, etc.
            manjaro|arch|endeavouros)
                OS_TYPE="arch"
                PKG_MGR="pacman"
                ;;
            # Fallback: detect by available package manager
            *)
                if command -v apt-get &>/dev/null; then
                    OS_TYPE="debian"
                    PKG_MGR="apt"
                elif command -v dnf &>/dev/null; then
                    OS_TYPE="rhel"
                    PKG_MGR="dnf"
                elif command -v yum &>/dev/null; then
                    OS_TYPE="rhel"
                    PKG_MGR="yum"
                elif command -v pacman &>/dev/null; then
                    OS_TYPE="arch"
                    PKG_MGR="pacman"
                fi
                ;;
        esac

    # -------------------------
    # Legacy Linux Detection
    # -------------------------
    elif [[ -f /etc/debian_version ]]; then
        OS_TYPE="debian"
        OS_NAME="Debian"
        OS_VERSION=$(cat /etc/debian_version)
        PKG_MGR="apt"
    elif [[ -f /etc/redhat-release ]]; then
        OS_TYPE="rhel"
        OS_NAME="RHEL"
        PKG_MGR="dnf"
    fi

    export OS_TYPE OS_NAME OS_VERSION PKG_MGR
}

# ============================================================================
# DEBUG / INFO
# ============================================================================
# NOTE: Useful for debugging OS detection issues

# Print detected OS information
print_os_info() {
    echo "OS Type: $OS_TYPE"
    echo "OS Name: $OS_NAME"
    echo "OS Version: $OS_VERSION"
    echo "Package Manager: $PKG_MGR"
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================
# NOTE: Convenience functions for conditional logic
# Usage: if is_macos; then ... fi

# Check if running on macOS
is_macos() {
    [[ "$OS_TYPE" == "macos" ]]
}

# Check if running on any Linux distribution
is_linux() {
    [[ "$OS_TYPE" != "macos" && "$OS_TYPE" != "unknown" ]]
}

# Check if running on Debian-based system (Ubuntu, Debian, etc.)
is_debian() {
    [[ "$OS_TYPE" == "debian" ]]
}

# Check if running on RHEL-based system (Rocky, CentOS, Fedora, etc.)
is_rhel() {
    [[ "$OS_TYPE" == "rhel" ]]
}

# Check if running on Arch-based system (Arch, Manjaro, etc.)
is_arch() {
    [[ "$OS_TYPE" == "arch" ]]
}

# ============================================================================
# END OF OS DETECTION
# ============================================================================
