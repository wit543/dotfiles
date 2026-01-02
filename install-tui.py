#!/usr/bin/env python3
"""
Dotfiles TUI Installer
Interactive terminal UI for selecting and installing dotfiles components.

Features:
    - Local installation with profile selection
    - Remote deployment via SSH to machines in machines.yaml
    - Windows support via PowerShell
    - Real-time progress and logging

Usage:
    ./install-tui.py
    python3 install-tui.py

Requires: pip install textual pyyaml
"""

import os
import platform
import subprocess
import sys
from pathlib import Path
from typing import Optional

# Check for dependencies
try:
    from textual.app import App, ComposeResult
    from textual.binding import Binding
    from textual.containers import Center, Container, Horizontal, Vertical, Grid
    from textual.screen import Screen
    from textual.widgets import (
        Button,
        Footer,
        Header,
        Label,
        Log,
        ProgressBar,
        RadioButton,
        RadioSet,
        SelectionList,
        Static,
        DataTable,
        Input,
        Rule,
        LoadingIndicator,
    )
    from textual.widgets.selection_list import Selection
except ImportError:
    print("Error: textual not installed")
    print("")
    print("Install with:")
    print("  pip install textual pyyaml")
    print("")
    print("Or use the shell installer:")
    print("  ./install.sh")
    sys.exit(1)

try:
    import yaml
except ImportError:
    yaml = None


# ============================================================================
# CONFIGURATION
# ============================================================================

DOTFILES_DIR = Path(__file__).parent.resolve()

PROFILES = {
    "minimal": {
        "name": "Minimal",
        "description": "Essential shell + git config only",
        "components": ["zsh", "git", "editorconfig"],
    },
    "medium": {
        "name": "Medium",
        "description": "Developer essentials without IDE configs",
        "components": ["zsh", "vim", "tmux", "git", "editorconfig"],
    },
    "full": {
        "name": "Full (Recommended)",
        "description": "Complete setup with all tools",
        "components": ["zsh", "vim", "tmux", "git", "vscode", "claude", "editorconfig"],
    },
}

COMPONENTS = [
    ("zsh", "Shell (Zsh + Zinit + Starship + zoxide + fzf)"),
    ("vim", "Vim/Neovim (vim-plug + plugins)"),
    ("tmux", "Tmux (gpakosz config + TPM)"),
    ("git", "Git (gitconfig + delta + gitignore)"),
    ("vscode", "VSCode (settings + keybindings + extensions)"),
    ("claude", "Claude Code (MCP + settings)"),
    ("editorconfig", "EditorConfig (universal formatting)"),
]

WINDOWS_COMPONENTS = [
    ("debloat", "Remove Bloatware (80+ apps: Cortana, Bing, Candy Crush, etc.)"),
    ("telemetry", "Disable Telemetry (Ads, Copilot, Bing search)"),
    ("system", "System Settings (Hibernate off, Cursor 150% black)"),
    ("chrome", "Chrome (Install + set default)"),
    ("vscode", "VSCode (Install + settings + extensions)"),
]

INSTALL_MODES = [
    ("full", "Full Install", "Install packages + configs"),
    ("config", "Config Only", "No sudo required"),
    ("update", "Update", "Upgrade packages + refresh"),
]


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def get_system_info() -> tuple[str, str]:
    """Get OS name and architecture."""
    system = platform.system()
    arch = platform.machine()

    if system == "Darwin":
        os_name = "macOS"
    elif system == "Linux":
        try:
            with open("/etc/os-release") as f:
                for line in f:
                    if line.startswith("PRETTY_NAME="):
                        os_name = line.split("=")[1].strip().strip('"')
                        break
                else:
                    os_name = "Linux"
        except FileNotFoundError:
            os_name = "Linux"
    elif system == "Windows":
        os_name = "Windows"
    else:
        os_name = system

    return os_name, arch


def load_machines() -> dict:
    """Load machines from machines.yaml."""
    if yaml is None:
        return {}

    machines_file = DOTFILES_DIR / "machines.yaml"
    if not machines_file.exists():
        return {}

    try:
        with open(machines_file) as f:
            data = yaml.safe_load(f)
            return data.get("machines", {}) if data else {}
    except Exception:
        return {}


def run_setup_function(component: str, mode: str, log_callback) -> bool:
    """Source bash libs and call setup_* function."""
    if mode == "config":
        mode_setup = "USE_SUDO=false; UPDATE_MODE=false"
    elif mode == "update":
        mode_setup = "USE_SUDO=true; UPDATE_MODE=true"
    else:
        mode_setup = "USE_SUDO=true; UPDATE_MODE=false"

    script = f'''
        set -e
        source "{DOTFILES_DIR}/lib/utils.sh"
        source "{DOTFILES_DIR}/lib/os.sh"
        source "{DOTFILES_DIR}/lib/packages.sh"
        {mode_setup}
        detect_os
        setup_{component}
    '''

    process = subprocess.Popen(
        ["bash", "-c", script],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        cwd=DOTFILES_DIR,
    )

    for line in process.stdout:
        log_callback(line.rstrip())

    process.wait()
    return process.returncode == 0


def run_remote_command(machine: dict, command: str, log_callback) -> bool:
    """Run command on remote machine via SSH."""
    user = machine.get("user", "")
    host = machine.get("host", "")
    password = machine.get("password")

    if not user or not host:
        log_callback("[red]Error: Invalid machine config[/red]")
        return False

    ssh_target = f"{user}@{host}"

    # Build SSH command
    if password:
        # Use sshpass if password is provided
        ssh_cmd = ["sshpass", "-p", password, "ssh", "-o", "StrictHostKeyChecking=no", ssh_target, command]
    else:
        ssh_cmd = ["ssh", "-o", "StrictHostKeyChecking=no", ssh_target, command]

    try:
        process = subprocess.Popen(
            ssh_cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )

        for line in process.stdout:
            log_callback(line.rstrip())

        process.wait()
        return process.returncode == 0
    except FileNotFoundError:
        if password:
            log_callback("[red]Error: sshpass not installed. Run: brew install sshpass[/red]")
        else:
            log_callback("[red]Error: SSH not available[/red]")
        return False


def run_windows_setup(machine: dict, components: list, log_callback) -> dict:
    """Run Windows setup on remote machine."""
    results = {}
    user = machine.get("user", "")
    host = machine.get("host", "")
    password = machine.get("password")

    ssh_target = f"{user}@{host}"

    def run_ssh(cmd: str) -> bool:
        if password:
            ssh_cmd = ["sshpass", "-p", password, "ssh", "-o", "StrictHostKeyChecking=no", ssh_target, cmd]
        else:
            ssh_cmd = ["ssh", "-o", "StrictHostKeyChecking=no", ssh_target, cmd]

        try:
            process = subprocess.Popen(
                ssh_cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
            )
            for line in process.stdout:
                log_callback(line.rstrip())
            process.wait()
            return process.returncode == 0
        except Exception as e:
            log_callback(f"[red]Error: {e}[/red]")
            return False

    def run_ps(cmd: str) -> bool:
        return run_ssh(f'powershell -Command "{cmd}"')

    # Bloatware apps list (subset for TUI - full list in setup.ps1)
    bloatware_apps = [
        "Clipchamp.Clipchamp", "Microsoft.549981C3F5F10", "Microsoft.BingNews",
        "Microsoft.BingWeather", "Microsoft.BingFinance", "Microsoft.BingSports",
        "Microsoft.MicrosoftSolitaireCollection", "Microsoft.SkypeApp",
        "Microsoft.MixedReality.Portal", "Microsoft.YourPhone", "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo", "Microsoft.Copilot", "Microsoft.WindowsFeedbackHub",
        "Facebook", "Instagram", "TikTok", "Twitter", "LinkedIn",
        "king.com.CandyCrush", "king.com.CandyCrushSaga", "Netflix", "Spotify",
        "Amazon.com.Amazon", "McAfee", "Duolingo"
    ]

    for component in components:
        log_callback(f"\n[bold cyan]{'='*50}[/bold cyan]")
        log_callback(f"[bold]Installing: {component}[/bold]")
        log_callback(f"[bold cyan]{'='*50}[/bold cyan]")

        if component == "debloat":
            log_callback("Removing bloatware apps...")
            removed = 0
            for app in bloatware_apps:
                result = run_ps(f"Get-AppxPackage -Name '*{app}*' -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue")
                if result:
                    removed += 1
            log_callback(f"[green]Removed {removed} bloatware apps[/green]")
            results[component] = True

        elif component == "telemetry":
            log_callback("Disabling telemetry...")
            # Disable telemetry
            run_ps("Set-ItemProperty -Path 'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection' -Name 'AllowTelemetry' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue")
            # Disable advertising ID
            run_ps("New-Item -Path 'HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AdvertisingInfo' -Force -ErrorAction SilentlyContinue | Out-Null; Set-ItemProperty -Path 'HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AdvertisingInfo' -Name 'Enabled' -Value 0 -Type DWord -Force")
            # Disable Copilot
            run_ps("New-Item -Path 'HKCU:\\Software\\Policies\\Microsoft\\Windows\\WindowsCopilot' -Force -ErrorAction SilentlyContinue | Out-Null; Set-ItemProperty -Path 'HKCU:\\Software\\Policies\\Microsoft\\Windows\\WindowsCopilot' -Name 'TurnOffWindowsCopilot' -Value 1 -Type DWord -Force")
            # Disable Bing search
            run_ps("New-Item -Path 'HKCU:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Explorer' -Force -ErrorAction SilentlyContinue | Out-Null; Set-ItemProperty -Path 'HKCU:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Explorer' -Name 'DisableSearchBoxSuggestions' -Value 1 -Type DWord -Force")
            # Disable Start menu suggestions
            run_ps("Set-ItemProperty -Path 'HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager' -Name 'SystemPaneSuggestionsEnabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue")
            run_ps("Set-ItemProperty -Path 'HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager' -Name 'SubscribedContent-338388Enabled' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue")
            log_callback("[green]Telemetry, ads, and Copilot disabled[/green]")
            results[component] = True

        elif component == "system":
            log_callback("Disabling hibernate...")
            run_ps("powercfg -h off")

            log_callback("Setting cursor to black, 150%...")
            run_ps("Set-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Accessibility' -Name 'CursorSize' -Value 3 -Type DWord -Force")
            run_ps("Set-ItemProperty -Path 'HKCU:\\Control Panel\\Cursors' -Name 'CursorBaseSize' -Value 48 -Type DWord -Force")
            run_ps("Set-ItemProperty -Path 'HKCU:\\Control Panel\\Cursors' -Name '(Default)' -Value 'Windows Black'")
            results[component] = True
            log_callback("[green]System settings applied[/green]")

        elif component == "chrome":
            log_callback("Installing Chrome...")
            success = run_ps("winget install Google.Chrome --accept-package-agreements --accept-source-agreements --silent")
            results[component] = success
            if success:
                log_callback("[green]Chrome installed[/green]")
            else:
                log_callback("[yellow]Chrome may already be installed[/yellow]")
                results[component] = True

        elif component == "vscode":
            log_callback("Installing VSCode...")
            success = run_ps("winget install Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements --silent")
            if success:
                log_callback("[green]VSCode installed[/green]")
            else:
                log_callback("[yellow]VSCode may already be installed[/yellow]")

            # Copy VSCode settings
            log_callback("Copying VSCode settings...")
            run_ssh(f"powershell -Command \"New-Item -ItemType Directory -Force -Path '$env:APPDATA\\Code\\User' | Out-Null\"")

            # Copy settings via SCP
            settings_src = DOTFILES_DIR / "config" / "vscode" / "settings.json"
            keybindings_src = DOTFILES_DIR / "config" / "vscode" / "keybindings.json"
            extensions_src = DOTFILES_DIR / "config" / "vscode" / "extensions.txt"

            try:
                subprocess.run(["scp", str(settings_src), f"{ssh_target}:C:/Users/{user}/AppData/Roaming/Code/User/settings.json"], check=False, capture_output=True)
                subprocess.run(["scp", str(keybindings_src), f"{ssh_target}:C:/Users/{user}/AppData/Roaming/Code/User/keybindings.json"], check=False, capture_output=True)
                log_callback("[green]Settings copied[/green]")
            except Exception:
                log_callback("[yellow]Could not copy settings[/yellow]")

            # Install extensions
            log_callback("Installing VSCode extensions...")
            if extensions_src.exists():
                with open(extensions_src) as f:
                    extensions = [
                        line.split('#')[0].strip()
                        for line in f
                        if line.strip() and not line.strip().startswith('#')
                    ]
                for ext in extensions[:10]:  # Install first 10 to save time
                    run_ps(f"& 'C:\\Program Files\\Microsoft VS Code\\bin\\code.cmd' --install-extension {ext} --force 2>$null")
                log_callback(f"[green]Installed {min(10, len(extensions))} extensions[/green]")

            results[component] = True

    return results


# ============================================================================
# SCREENS
# ============================================================================

class WelcomeScreen(Screen):
    """Welcome screen with system info and target selection."""

    BINDINGS = [
        Binding("enter", "continue", "Continue"),
        Binding("q", "quit", "Quit"),
    ]

    def compose(self) -> ComposeResult:
        os_name, arch = get_system_info()
        machines = load_machines()

        yield Header()
        yield Vertical(
            Static(""),
            Center(
                Vertical(
                    Static("╔════════════════════════════════════════════════════╗", classes="banner"),
                    Static("║                                                    ║", classes="banner"),
                    Static("║          DOTFILES TUI INSTALLER v2.0               ║", classes="banner"),
                    Static("║          github.com/wit543/dotfiles                ║", classes="banner"),
                    Static("║                                                    ║", classes="banner"),
                    Static("╚════════════════════════════════════════════════════╝", classes="banner"),
                    Static(""),
                    Static(f"  💻 Local System: {os_name} ({arch})", classes="info"),
                    Static(f"  📁 Dotfiles: {DOTFILES_DIR}", classes="info"),
                    Static(f"  🌐 Remote Machines: {len(machines)} configured", classes="info"),
                    Static(""),
                    Rule(),
                    Static(""),
                    Static("  Select installation target:", classes="section-title"),
                    Static(""),
                    Center(
                        Horizontal(
                            Button("🏠 Local Install", id="local", variant="primary"),
                            Button("🌐 Remote Deploy", id="remote", variant="default"),
                            classes="button-row",
                        )
                    ),
                    id="welcome-content",
                )
            ),
            id="welcome-container",
        )
        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "local":
            self.app.target_mode = "local"
            self.app.push_screen(ProfileScreen())
        elif event.button.id == "remote":
            machines = load_machines()
            if not machines:
                self.notify("No machines configured. Create machines.yaml first.", severity="warning")
                return
            self.app.target_mode = "remote"
            self.app.push_screen(MachineSelectScreen())

    def action_continue(self) -> None:
        self.app.target_mode = "local"
        self.app.push_screen(ProfileScreen())

    def action_quit(self) -> None:
        self.app.exit()


class MachineSelectScreen(Screen):
    """Machine selection screen for remote deployment."""

    BINDINGS = [
        Binding("escape", "back", "Back"),
        Binding("q", "quit", "Quit"),
    ]

    def compose(self) -> ComposeResult:
        machines = load_machines()

        yield Header()
        yield Vertical(
            Static(""),
            Static("  🌐 Select target machine:", classes="section-title"),
            Static(""),
            Vertical(
                *[
                    Button(
                        f"  {name}: {info.get('user')}@{info.get('host')} ({info.get('os', 'unknown')})",
                        id=f"machine-{name}",
                        variant="default",
                        classes="machine-button",
                    )
                    for name, info in machines.items()
                ],
                id="machine-list",
            ),
            Static(""),
            Center(
                Horizontal(
                    Button("Back", id="back"),
                    classes="button-row",
                )
            ),
            id="machine-container",
        )
        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "back":
            self.app.pop_screen()
        elif event.button.id.startswith("machine-"):
            machine_name = event.button.id.replace("machine-", "")
            machines = load_machines()
            self.app.selected_machine = machines.get(machine_name, {})
            self.app.selected_machine["name"] = machine_name

            # Check OS type
            os_type = self.app.selected_machine.get("os", "").lower()
            if os_type == "windows":
                self.app.push_screen(WindowsComponentScreen())
            else:
                self.app.push_screen(RemoteProfileScreen())

    def action_back(self) -> None:
        self.app.pop_screen()

    def action_quit(self) -> None:
        self.app.exit()


class RemoteProfileScreen(Screen):
    """Profile selection for remote Unix/macOS machines."""

    BINDINGS = [
        Binding("escape", "back", "Back"),
        Binding("q", "quit", "Quit"),
    ]

    def compose(self) -> ComposeResult:
        machine = getattr(self.app, "selected_machine", {})
        machine_name = machine.get("name", "Unknown")
        machine_os = machine.get("os", "unknown")

        yield Header()
        yield Vertical(
            Static(""),
            Static(f"  🎯 Target: {machine_name} ({machine_os})", classes="section-title"),
            Static(""),
            Static("  Select installation profile:", classes="section-title"),
            Static(""),
            RadioSet(
                RadioButton("Full (Recommended) - Complete setup", id="full", value=True),
                RadioButton("Medium - Developer essentials", id="medium"),
                RadioButton("Minimal - Shell + git only", id="minimal"),
                id="profile-select",
            ),
            Static(""),
            Center(
                Horizontal(
                    Button("Back", id="back"),
                    Button("Deploy", id="deploy", variant="primary"),
                    classes="button-row",
                )
            ),
            id="remote-profile-container",
        )
        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "back":
            self.app.pop_screen()
        elif event.button.id == "deploy":
            profile_set = self.query_one("#profile-select", RadioSet)
            profile = "full"
            if profile_set.pressed_button:
                profile = profile_set.pressed_button.id

            self.app.selected_components = PROFILES[profile]["components"]
            self.app.install_mode = "full"
            self.app.push_screen(RemoteProgressScreen())

    def action_back(self) -> None:
        self.app.pop_screen()

    def action_quit(self) -> None:
        self.app.exit()


class WindowsComponentScreen(Screen):
    """Component selection for Windows machines."""

    BINDINGS = [
        Binding("escape", "back", "Back"),
        Binding("q", "quit", "Quit"),
    ]

    def compose(self) -> ComposeResult:
        machine = getattr(self.app, "selected_machine", {})
        machine_name = machine.get("name", "Unknown")

        yield Header()
        yield Vertical(
            Static(""),
            Static(f"  🪟 Windows Target: {machine_name}", classes="section-title"),
            Static(""),
            Static("  Select components to install:", classes="section-title"),
            Static(""),
            SelectionList[str](
                *[Selection(desc, id, True) for id, desc in WINDOWS_COMPONENTS],
                id="windows-component-list",
            ),
            Static(""),
            Center(
                Horizontal(
                    Button("Back", id="back"),
                    Button("Deploy", id="deploy", variant="primary"),
                    classes="button-row",
                )
            ),
            id="windows-container",
        )
        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "back":
            self.app.pop_screen()
        elif event.button.id == "deploy":
            selection_list = self.query_one("#windows-component-list", SelectionList)
            self.app.selected_components = list(selection_list.selected)

            if not self.app.selected_components:
                self.notify("Please select at least one component", severity="warning")
                return

            self.app.push_screen(WindowsProgressScreen())

    def action_back(self) -> None:
        self.app.pop_screen()

    def action_quit(self) -> None:
        self.app.exit()


class ProfileScreen(Screen):
    """Profile selection screen for local install."""

    BINDINGS = [
        Binding("escape", "back", "Back"),
        Binding("enter", "continue", "Continue"),
        Binding("q", "quit", "Quit"),
    ]

    def compose(self) -> ComposeResult:
        yield Header()
        yield Vertical(
            Static(""),
            Static("  🏠 Local Installation", classes="section-title"),
            Static(""),
            Static("  Select an installation profile:", classes="section-title"),
            Static(""),
            RadioSet(
                RadioButton("Full (Recommended) - Complete setup with all tools", id="full", value=True),
                RadioButton("Medium - Developer essentials without IDE configs", id="medium"),
                RadioButton("Minimal - Essential shell + git config only", id="minimal"),
                RadioButton("Custom - Choose individual components", id="custom"),
                id="profile-select",
            ),
            Static(""),
            Static("  Installation mode:", classes="section-title"),
            Static(""),
            RadioSet(
                RadioButton("Full Install - Install packages + configs", id="mode-full", value=True),
                RadioButton("Config Only - No sudo required", id="mode-config"),
                RadioButton("Update - Upgrade packages + refresh", id="mode-update"),
                id="mode-select",
            ),
            Static(""),
            Center(
                Horizontal(
                    Button("Back", id="back"),
                    Button("Continue", id="continue", variant="primary"),
                    classes="button-row",
                )
            ),
            id="profile-container",
        )
        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "back":
            self.app.pop_screen()
        elif event.button.id == "continue":
            self._continue()

    def action_back(self) -> None:
        self.app.pop_screen()

    def action_continue(self) -> None:
        self._continue()

    def action_quit(self) -> None:
        self.app.exit()

    def _continue(self) -> None:
        profile_set = self.query_one("#profile-select", RadioSet)
        mode_set = self.query_one("#mode-select", RadioSet)

        profile = "full"
        if profile_set.pressed_button:
            profile = profile_set.pressed_button.id

        mode = "full"
        if mode_set.pressed_button:
            mode_id = mode_set.pressed_button.id
            mode = mode_id.replace("mode-", "")

        self.app.install_mode = mode

        if profile == "custom":
            self.app.push_screen(ComponentScreen())
        else:
            self.app.selected_components = PROFILES[profile]["components"]
            self.app.push_screen(ProgressScreen())


class ComponentScreen(Screen):
    """Component selection screen for custom profile."""

    BINDINGS = [
        Binding("escape", "back", "Back"),
        Binding("a", "select_all", "Select All"),
        Binding("n", "select_none", "Select None"),
        Binding("q", "quit", "Quit"),
    ]

    def compose(self) -> ComposeResult:
        yield Header()
        yield Vertical(
            Static(""),
            Static("  Select components to install:", classes="section-title"),
            Static(""),
            SelectionList[str](
                *[Selection(desc, id, True) for id, desc in COMPONENTS],
                id="component-list",
            ),
            Static(""),
            Center(
                Horizontal(
                    Button("Select All", id="all"),
                    Button("Select None", id="none"),
                    Button("Back", id="back"),
                    Button("Install", id="install", variant="primary"),
                    classes="button-row",
                )
            ),
            id="component-container",
        )
        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "back":
            self.app.pop_screen()
        elif event.button.id == "all":
            self.action_select_all()
        elif event.button.id == "none":
            self.action_select_none()
        elif event.button.id == "install":
            self._install()

    def action_back(self) -> None:
        self.app.pop_screen()

    def action_select_all(self) -> None:
        selection_list = self.query_one("#component-list", SelectionList)
        selection_list.select_all()

    def action_select_none(self) -> None:
        selection_list = self.query_one("#component-list", SelectionList)
        selection_list.deselect_all()

    def action_quit(self) -> None:
        self.app.exit()

    def _install(self) -> None:
        selection_list = self.query_one("#component-list", SelectionList)
        self.app.selected_components = list(selection_list.selected)

        if not self.app.selected_components:
            self.notify("Please select at least one component", severity="warning")
            return

        self.app.push_screen(ProgressScreen())


class ProgressScreen(Screen):
    """Local installation progress screen."""

    BINDINGS = [
        Binding("q", "quit", "Quit", show=False),
    ]

    def compose(self) -> ComposeResult:
        yield Header()
        yield Vertical(
            Static(""),
            Static("  🏠 Installing locally...", id="status", classes="section-title"),
            Static(""),
            ProgressBar(id="progress", total=100),
            Static(""),
            Log(id="log", highlight=True, markup=True),
            id="progress-container",
        )
        yield Footer()

    def on_mount(self) -> None:
        self.run_installation()

    def run_installation(self) -> None:
        self.run_worker(self._install_worker, exclusive=True)

    async def _install_worker(self) -> None:
        log = self.query_one("#log", Log)
        progress = self.query_one("#progress", ProgressBar)
        status = self.query_one("#status", Static)

        components = self.app.selected_components
        mode = self.app.install_mode
        total = len(components)
        results = {}

        log.write_line(f"[bold]Starting local installation ({mode} mode)...[/bold]")
        log.write_line(f"Components: {', '.join(components)}")
        log.write_line("")

        for i, component in enumerate(components):
            status.update(f"  🔧 Installing {component}... ({i+1}/{total})")
            progress.update(progress=(i / total) * 100)

            log.write_line(f"[bold cyan]{'='*60}[/bold cyan]")
            log.write_line(f"[bold]Installing: {component}[/bold]")
            log.write_line(f"[bold cyan]{'='*60}[/bold cyan]")

            success = run_setup_function(
                component,
                mode,
                lambda line: log.write_line(line)
            )

            results[component] = success

            if success:
                log.write_line(f"[bold green]✓ {component} completed successfully[/bold green]")
            else:
                log.write_line(f"[bold red]✗ {component} failed[/bold red]")

            log.write_line("")

        progress.update(progress=100)
        status.update("  ✅ Installation complete!")

        self.app.install_results = results
        self.app.push_screen(CompleteScreen())

    def action_quit(self) -> None:
        self.app.exit()


class RemoteProgressScreen(Screen):
    """Remote Unix/macOS installation progress screen."""

    BINDINGS = [
        Binding("q", "quit", "Quit", show=False),
    ]

    def compose(self) -> ComposeResult:
        machine = getattr(self.app, "selected_machine", {})
        machine_name = machine.get("name", "Unknown")

        yield Header()
        yield Vertical(
            Static(""),
            Static(f"  🌐 Deploying to {machine_name}...", id="status", classes="section-title"),
            Static(""),
            ProgressBar(id="progress", total=100),
            Static(""),
            Log(id="log", highlight=True, markup=True),
            id="progress-container",
        )
        yield Footer()

    def on_mount(self) -> None:
        self.run_worker(self._deploy_worker, exclusive=True)

    async def _deploy_worker(self) -> None:
        log = self.query_one("#log", Log)
        progress = self.query_one("#progress", ProgressBar)
        status = self.query_one("#status", Static)

        machine = self.app.selected_machine
        components = self.app.selected_components
        results = {}

        machine_name = machine.get("name", "Unknown")
        user = machine.get("user")
        host = machine.get("host")

        log.write_line(f"[bold]Deploying to {machine_name} ({user}@{host})...[/bold]")
        log.write_line(f"Components: {', '.join(components)}")
        log.write_line("")

        # First, copy dotfiles to remote
        log.write_line("[bold cyan]Syncing dotfiles to remote...[/bold cyan]")
        status.update(f"  📤 Syncing dotfiles to {machine_name}...")

        rsync_cmd = f"rsync -avz --exclude '.git' {DOTFILES_DIR}/ {user}@{host}:~/dotfiles/"
        process = subprocess.Popen(
            rsync_cmd,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
        for line in process.stdout:
            log.write_line(line.rstrip())
        process.wait()

        if process.returncode != 0:
            log.write_line("[red]Failed to sync dotfiles[/red]")
            self.app.install_results = {"sync": False}
            self.app.push_screen(CompleteScreen())
            return

        log.write_line("[green]Dotfiles synced successfully[/green]")
        log.write_line("")

        # Run install script remotely
        total = len(components)
        for i, component in enumerate(components):
            status.update(f"  🔧 Installing {component}... ({i+1}/{total})")
            progress.update(progress=(i / total) * 100)

            log.write_line(f"[bold cyan]{'='*60}[/bold cyan]")
            log.write_line(f"[bold]Installing: {component}[/bold]")
            log.write_line(f"[bold cyan]{'='*60}[/bold cyan]")

            # Run setup function remotely
            remote_cmd = f'''
                cd ~/dotfiles &&
                source lib/utils.sh &&
                source lib/os.sh &&
                source lib/packages.sh &&
                detect_os &&
                setup_{component}
            '''

            success = run_remote_command(
                machine,
                remote_cmd,
                lambda line: log.write_line(line)
            )

            results[component] = success

            if success:
                log.write_line(f"[bold green]✓ {component} completed[/bold green]")
            else:
                log.write_line(f"[bold red]✗ {component} failed[/bold red]")

            log.write_line("")

        progress.update(progress=100)
        status.update("  ✅ Deployment complete!")

        self.app.install_results = results
        self.app.push_screen(CompleteScreen())

    def action_quit(self) -> None:
        self.app.exit()


class WindowsProgressScreen(Screen):
    """Windows installation progress screen."""

    BINDINGS = [
        Binding("q", "quit", "Quit", show=False),
    ]

    def compose(self) -> ComposeResult:
        machine = getattr(self.app, "selected_machine", {})
        machine_name = machine.get("name", "Unknown")

        yield Header()
        yield Vertical(
            Static(""),
            Static(f"  🪟 Deploying to {machine_name}...", id="status", classes="section-title"),
            Static(""),
            ProgressBar(id="progress", total=100),
            Static(""),
            Log(id="log", highlight=True, markup=True),
            id="progress-container",
        )
        yield Footer()

    def on_mount(self) -> None:
        self.run_worker(self._deploy_worker, exclusive=True)

    async def _deploy_worker(self) -> None:
        log = self.query_one("#log", Log)
        progress = self.query_one("#progress", ProgressBar)
        status = self.query_one("#status", Static)

        machine = self.app.selected_machine
        components = self.app.selected_components

        machine_name = machine.get("name", "Unknown")
        user = machine.get("user")
        host = machine.get("host")

        log.write_line(f"[bold]Deploying Windows setup to {machine_name} ({user}@{host})...[/bold]")
        log.write_line(f"Components: {', '.join(components)}")
        log.write_line("")

        results = run_windows_setup(
            machine,
            components,
            lambda line: log.write_line(line)
        )

        progress.update(progress=100)
        status.update("  ✅ Windows setup complete!")

        self.app.install_results = results
        self.app.push_screen(CompleteScreen())

    def action_quit(self) -> None:
        self.app.exit()


class CompleteScreen(Screen):
    """Installation complete screen."""

    BINDINGS = [
        Binding("enter", "exit", "Exit"),
        Binding("q", "exit", "Exit"),
    ]

    def compose(self) -> ComposeResult:
        results = getattr(self.app, "install_results", {})
        success_count = sum(1 for v in results.values() if v)
        fail_count = sum(1 for v in results.values() if not v)
        target_mode = getattr(self.app, "target_mode", "local")
        machine = getattr(self.app, "selected_machine", {})

        if target_mode == "remote":
            target_info = f"Target: {machine.get('name', 'Unknown')} ({machine.get('os', 'unknown')})"
        else:
            target_info = "Target: Local machine"

        yield Header()
        yield Vertical(
            Static(""),
            Center(
                Vertical(
                    Static("╔════════════════════════════════════════════════════╗", classes="banner"),
                    Static("║                                                    ║", classes="banner"),
                    Static("║            ✅ INSTALLATION COMPLETE                ║", classes="banner"),
                    Static("║                                                    ║", classes="banner"),
                    Static("╚════════════════════════════════════════════════════╝", classes="banner"),
                    Static(""),
                    Static(f"  {target_info}", classes="info"),
                    Static(""),
                    Static(f"  ✓ Successful: {success_count}", classes="success" if success_count else "info"),
                    Static(f"  ✗ Failed: {fail_count}", classes="error" if fail_count else "info"),
                    Static(""),
                    Static("  Components:", classes="section-title"),
                    *[
                        Static(f"    {'[green]✓[/green]' if ok else '[red]✗[/red]'} {comp}", markup=True)
                        for comp, ok in results.items()
                    ],
                    Static(""),
                    Static("  Next steps:", classes="section-title"),
                    Static("    • Restart your shell: exec zsh", classes="info"),
                    Static("    • Or open a new terminal window", classes="info"),
                    Static(""),
                    Center(Button("Exit", id="exit", variant="primary")),
                    id="complete-content",
                )
            ),
            id="complete-container",
        )
        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "exit":
            self.app.exit()

    def action_exit(self) -> None:
        self.app.exit()


# ============================================================================
# MAIN APP
# ============================================================================

class DotfilesInstaller(App):
    """Dotfiles TUI Installer Application v2.0."""

    CSS = """
    Screen {
        background: $surface;
    }

    #welcome-container, #profile-container, #component-container,
    #progress-container, #complete-container, #machine-container,
    #remote-profile-container, #windows-container {
        height: 100%;
        padding: 1;
    }

    .banner {
        text-align: center;
        color: $primary;
    }

    .section-title {
        color: $text;
        text-style: bold;
    }

    .info {
        color: $text-muted;
    }

    .success {
        color: $success;
    }

    .error {
        color: $error;
    }

    .button-row {
        height: auto;
        margin: 1;
    }

    .button-row Button {
        margin: 0 1;
    }

    .machine-button {
        width: 100%;
        margin: 0 2 1 2;
    }

    #profile-select, #mode-select {
        margin: 0 2;
        height: auto;
    }

    #component-list, #windows-component-list {
        height: 12;
        margin: 0 2;
        border: solid $primary;
    }

    #machine-list {
        height: auto;
        margin: 0 2;
    }

    #log {
        height: 1fr;
        margin: 0 2;
        border: solid $primary;
    }

    #progress {
        margin: 0 2;
    }

    #complete-content {
        height: auto;
    }

    Rule {
        margin: 1 4;
    }
    """

    TITLE = "Dotfiles Installer v2.0"

    def __init__(self):
        super().__init__()
        self.selected_components = []
        self.install_mode = "full"
        self.install_results = {}
        self.target_mode = "local"
        self.selected_machine = {}

    def on_mount(self) -> None:
        self.push_screen(WelcomeScreen())


# ============================================================================
# ENTRY POINT
# ============================================================================

if __name__ == "__main__":
    app = DotfilesInstaller()
    app.run()
