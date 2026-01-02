#!/usr/bin/env bash
# ============================================================================
#                         MACOS DEFAULTS
#                    github.com/wit543/dotfiles
# ============================================================================
# Sets macOS system preferences via defaults command
#
# Usage:
#   ./defaults.sh           # Apply all settings
#   ./defaults.sh --help    # Show help
#
# NOTE: Some settings require logout/restart to take effect
# ============================================================================

set -euo pipefail

# ============================================================================
# HELPERS
# ============================================================================

log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $*"
}

log_success() {
    echo -e "\033[0;32m[OK]\033[0m $*"
}

# ============================================================================
# APPEARANCE
# ============================================================================

setup_appearance() {
    log_info "Setting up appearance..."

    # Always use dark mode
    defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

    # Disable automatic switching between light/dark
    defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool false

    log_success "Appearance configured (dark mode)"
}

# ============================================================================
# POWER & SLEEP
# ============================================================================

setup_power() {
    log_info "Setting up power management..."

    # Disable display sleep
    sudo pmset -a displaysleep 0

    # Disable computer sleep
    sudo pmset -a sleep 0

    # Disable disk sleep
    sudo pmset -a disksleep 0

    # Never sleep (via systemsetup)
    sudo systemsetup -setcomputersleep Never 2>/dev/null || true

    log_success "Power management configured (never sleep)"
}

# ============================================================================
# SECURITY & LOGIN
# ============================================================================

setup_security() {
    log_info "Setting up security & login..."

    # Disable auto-logout
    sudo defaults write /Library/Preferences/.GlobalPreferences com.apple.autologout.AutoLogOutDelay 0

    # Disable screensaver
    defaults write com.apple.screensaver idleTime 0

    # Require password immediately after sleep/screensaver (security)
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    log_success "Security & login configured"
}

# ============================================================================
# FINDER
# ============================================================================

setup_finder() {
    log_info "Setting up Finder..."

    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true

    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # Disable warning when changing file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Use list view by default
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Show the ~/Library folder
    chflags nohidden ~/Library 2>/dev/null || true

    log_success "Finder configured"
}

# ============================================================================
# DOCK
# ============================================================================

setup_dock() {
    log_info "Setting up Dock..."

    # Set dock icon size
    defaults write com.apple.dock tilesize -int 48

    # Auto-hide dock
    defaults write com.apple.dock autohide -bool true

    # Remove auto-hide delay
    defaults write com.apple.dock autohide-delay -float 0

    # Speed up auto-hide animation
    defaults write com.apple.dock autohide-time-modifier -float 0.3

    # Don't show recent applications
    defaults write com.apple.dock show-recents -bool false

    # Minimize windows into application icon
    defaults write com.apple.dock minimize-to-application -bool true

    log_success "Dock configured"
}

# ============================================================================
# KEYBOARD & INPUT
# ============================================================================

setup_keyboard() {
    log_info "Setting up keyboard..."

    # Fast key repeat
    defaults write NSGlobalDomain KeyRepeat -int 2

    # Short delay until repeat
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    # Disable auto-capitalization
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

    # Disable smart quotes
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

    # Disable smart dashes
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    # Disable period substitution (double-space for period)
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

    log_success "Keyboard configured"
}

# ============================================================================
# TRACKPAD
# ============================================================================

setup_trackpad() {
    log_info "Setting up trackpad..."

    # Enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Enable three-finger drag
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

    log_success "Trackpad configured"
}

# ============================================================================
# SCREENSHOTS
# ============================================================================

setup_screenshots() {
    log_info "Setting up screenshots..."

    # Save screenshots to ~/Pictures/Screenshots
    mkdir -p "$HOME/Pictures/Screenshots"
    defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

    # Save as PNG
    defaults write com.apple.screencapture type -string "png"

    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true

    log_success "Screenshots configured"
}

# ============================================================================
# DEFAULT BROWSER
# ============================================================================

setup_browser() {
    log_info "Setting up default browser..."

    # Set Google Chrome as default browser
    # Note: This sets the handler for http/https URLs and HTML files
    if [[ -d "/Applications/Google Chrome.app" ]]; then
        # Set Chrome as default for HTTP/HTTPS
        defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
            '{LSHandlerContentType="public.html";LSHandlerRoleAll="com.google.chrome";}' \
            '{LSHandlerURLScheme="http";LSHandlerRoleAll="com.google.chrome";}' \
            '{LSHandlerURLScheme="https";LSHandlerRoleAll="com.google.chrome";}'

        # Rebuild Launch Services database
        /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
            -kill -r -domain local -domain system -domain user 2>/dev/null || true

        log_success "Default browser set to Google Chrome"
    else
        log_info "Google Chrome not installed, skipping browser setup"
    fi
}

# ============================================================================
# MISC
# ============================================================================

setup_misc() {
    log_info "Setting up misc preferences..."

    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Save to disk (not iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Disable "Are you sure you want to open this application?"
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    log_success "Misc preferences configured"
}

# ============================================================================
# RESTART AFFECTED APPS
# ============================================================================

restart_apps() {
    log_info "Restarting affected applications..."

    for app in "Finder" "Dock" "SystemUIServer"; do
        killall "$app" 2>/dev/null || true
    done

    log_success "Applications restarted"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    echo ""
    echo "============================================"
    echo "  macOS Defaults Configuration"
    echo "============================================"
    echo ""

    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        echo "Usage: $0"
        echo ""
        echo "Applies macOS system preferences via defaults command."
        echo "Some settings require logout/restart to take effect."
        exit 0
    fi

    setup_appearance
    setup_power
    setup_security
    setup_browser
    setup_finder
    setup_dock
    setup_keyboard
    setup_trackpad
    setup_screenshots
    setup_misc
    restart_apps

    echo ""
    echo "============================================"
    log_success "macOS defaults configured!"
    echo "============================================"
    echo ""
    log_info "Some changes require logout/restart to take effect."
    echo ""
}

main "$@"
