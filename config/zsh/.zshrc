#!/usr/bin/env zsh
# ============================================================================
#                         ZSH CONFIGURATION
#                    github.com/wit543/dotfiles
# ============================================================================
# Supports: macOS, Ubuntu, Rocky Linux, Manjaro
# Stack: Zinit (plugin manager) + Starship (prompt) + zoxide (cd)
# ============================================================================

# ============================================================================
# ZINIT INITIALIZATION
# ============================================================================
# NOTE: Zinit auto-installs on first shell startup

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Auto-install Zinit if not present
if [[ ! -d "$ZINIT_HOME" ]]; then
    print -P "%F{33}Installing Zinit...%f"
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && \
        print -P "%F{34}Zinit installed successfully%f" || \
        print -P "%F{160}Zinit installation failed%f"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ============================================================================
# ZINIT PLUGINS (Turbo Mode - loads asynchronously after prompt)
# ============================================================================
# NOTE: wait"0" = load immediately after prompt displays (~40ms startup)

# Oh-My-Zsh snippets (load synchronously for critical functionality)
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git

# Async plugins (Turbo mode)
zinit wait lucid for \
    OMZP::fzf \
    OMZP::extract \
    OMZP::docker \
    OMZP::docker-compose \
    OMZP::dotenv

# External plugins with Turbo mode
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        zsh-users/zsh-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    zsh-users/zsh-history-substring-search \
    urbainvaes/fzf-marks \
    hchbaw/zce.zsh \
    changyuheng/zsh-interactive-cd

# ============================================================================
# HISTORY
# ============================================================================
# NOTE: Large history for better recall with fzf (Ctrl+R)

HISTFILE=~/.zsh_history
HISTSIZE=999999999
SAVEHIST=$HISTSIZE

setopt INC_APPEND_HISTORY     # Write immediately, not on shell exit
setopt HIST_IGNORE_DUPS       # Don't record duplicates
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt SHARE_HISTORY          # Share history between sessions

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

export TERM="xterm-256color"
export EDITOR="nvim"
export VISUAL="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ============================================================================
# PATH CONFIGURATION
# ============================================================================
# NOTE: Add custom paths here, they'll be prepended to PATH

typeset -U path  # Remove duplicates from PATH

path=(
    $HOME/.local/bin
    $HOME/bin
    /usr/local/bin
    $path
)

# ============================================================================
# ALIASES - EDITOR
# ============================================================================

alias vim="nvim"
alias vi="nvim"
alias v="nvim"

# ============================================================================
# ALIASES - MODERN CLI TOOLS (with silent fallbacks)
# ============================================================================
# NOTE: Uses modern Rust tools if available, falls back to traditional

# ls -> eza
if command -v eza &>/dev/null; then
    alias ls="eza --color=auto --icons"
    alias ll="eza -lah --icons --git"
    alias la="eza -a --icons"
    alias l="eza -F --icons"
    alias lt="eza --tree --icons"
    alias tree="eza --tree --icons"
else
    alias ls="ls --color=auto"
    alias ll="ls -lah"
    alias la="ls -A"
    alias l="ls -CF"
fi

# cat -> bat
if command -v bat &>/dev/null; then
    alias cat="bat --paging=never --style=plain"
    alias catp="bat"  # with pager and full styling
    alias bathelp='bat --plain --language=help'
    help() { "$@" --help 2>&1 | bathelp; }
else
    alias catp="less"
fi

# du -> dust
if command -v dust &>/dev/null; then
    alias du="dust"
    alias duf="dust -f"  # show files too
fi

# ps -> procs
if command -v procs &>/dev/null; then
    alias psa="procs"
    alias pst="procs --tree"
fi

# find -> fd (keep find available)
if command -v fd &>/dev/null; then
    alias f="fd"
elif command -v fdfind &>/dev/null; then
    # Debian/Ubuntu names it fdfind
    alias fd="fdfind"
    alias f="fdfind"
fi

# sed -> sd (keep sed available)
if command -v sd &>/dev/null; then
    alias replace="sd"
fi

# ============================================================================
# ALIASES - DIRECTORY NAVIGATION
# ============================================================================

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias space="du -hs * | sort -h"   # Show disk usage sorted by size
alias mkdir="mkdir -pv"            # Create parent dirs, verbose

# ============================================================================
# ALIASES - SEARCH (ripgrep)
# ============================================================================

alias rg1="rg --max-depth=1"       # Search current dir only
alias rgf="rg --files | rg"        # Search filenames

# ============================================================================
# ALIASES - TMUX
# ============================================================================

alias tm="tmux"
alias tma="tmux attach"
alias tmn="tmux new -s"            # tmn <session-name>
alias tml="tmux list-sessions"

# ============================================================================
# ALIASES - PYTHON
# ============================================================================

alias pip="pip3"
alias python="python3"
alias py="python3"

# ============================================================================
# ALIASES - GIT SHORTCUTS
# ============================================================================
# NOTE: More git aliases defined by Zinit OMZP::git snippet

alias gs="git status"
alias gd="git diff"
alias gds="git diff --staged"
alias glog="git log --oneline --graph --decorate -20"

# ============================================================================
# ALIASES - TUI PRODUCTIVITY TOOLS
# ============================================================================

alias lg="lazygit"
alias lzd="lazydocker"

# yazi file manager (y to cd to dir on exit)
if command -v yazi &>/dev/null; then
    function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }
fi

# btop system monitor
if command -v btop &>/dev/null; then
    alias top="btop"
fi

# ============================================================================
# ALIASES - PRODUCTIVITY (2025)
# ============================================================================

# tldr - simplified man pages
if command -v tldr &>/dev/null; then
    alias help="tldr"
fi

# thefuck - auto-correct typos
if command -v thefuck &>/dev/null; then
    eval $(thefuck --alias)
    eval $(thefuck --alias fk)  # shorter alias
fi

# ============================================================================
# CUSTOM FUNCTIONS
# ============================================================================

# Mount remote directory via SSHFS
# Usage: fshere user@host:/path
fshere() {
    local cmd="sshfs -o cache=no -o IdentityFile=$HOME/.ssh/id_rsa $@ $PWD"
    echo "Running: $cmd"
    eval $cmd
    cd .. && cd -
}

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find process by name
psg() {
    ps aux | grep -v grep | grep -i "$1"
}

# ============================================================================
# KEY BINDINGS
# ============================================================================

bindkey '^[[Z' autosuggest-accept  # Shift+Tab: accept suggestion
bindkey '^f' zce                   # Ctrl+F: quick jump

# History substring search with arrow keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ============================================================================
# PLUGIN CONFIGURATION
# ============================================================================

# Autosuggestions style
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"  # Gray color
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# FZF options
export FZF_DEFAULT_OPTS="--reverse --height=40%"
export FZF_CTRL_R_OPTS="--reverse"
export FZF_MARKS_JUMP="^h"         # Ctrl+H to jump to mark

# ============================================================================
# FZF INTEGRATION
# ============================================================================
# NOTE: Provides Ctrl+R (history), Ctrl+T (files), Alt+C (cd)

[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# ============================================================================
# COMPLETIONS
# ============================================================================

# Zinit handles compinit via zicompinit in turbo mode
# Additional completion settings:
zstyle ':completion:*' menu select                 # Menu selection
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # Case insensitive

# ============================================================================
# OS DETECTION
# ============================================================================

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
elif [[ -f /etc/os-release ]]; then
    source /etc/os-release
    OS_TYPE="$ID"  # ubuntu, rocky, manjaro, etc.
else
    OS_TYPE="linux"
fi

# ============================================================================
# MACOS CONFIGURATION
# ============================================================================

if [[ "$OS_TYPE" == "macos" ]]; then
    # Homebrew
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"     # Intel Mac
    fi

    # Java (if installed)
    if [[ -x /usr/libexec/java_home ]]; then
        export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null) || true
    fi

    # macOS-specific aliases
    alias showfiles="defaults write com.apple.finder AppleShowAllFiles YES && killall Finder"
    alias hidefiles="defaults write com.apple.finder AppleShowAllFiles NO && killall Finder"
fi

# ============================================================================
# LINUX CONFIGURATION
# ============================================================================

if [[ "$OS_TYPE" != "macos" ]]; then
    # CUDA (if installed)
    [[ -d /usr/local/cuda ]] && export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"

    # Go
    [[ -d ~/go/bin ]] && path+=(~/go/bin)
fi

# ============================================================================
# CONDA (Python Environment Manager)
# ============================================================================
# NOTE: Searches common installation paths automatically

CONDA_PATHS=(
    "/opt/anaconda3"
    "$HOME/anaconda3"
    "$HOME/miniconda3"
    "/opt/miniconda3"
    "/usr/local/anaconda3"
    "/opt/homebrew/anaconda3"
)

for conda_path in "${CONDA_PATHS[@]}"; do
    if [[ -f "$conda_path/bin/conda" ]]; then
        # Initialize conda
        __conda_setup="$("$conda_path/bin/conda" 'shell.zsh' 'hook' 2>/dev/null)"
        if [[ $? -eq 0 ]]; then
            eval "$__conda_setup"
        elif [[ -f "$conda_path/etc/profile.d/conda.sh" ]]; then
            source "$conda_path/etc/profile.d/conda.sh"
        else
            export PATH="$conda_path/bin:$PATH"
        fi
        unset __conda_setup

        # Activate default environment if exists
        # NOTE: Change 'troik' to your preferred default environment
        conda activate troik 2>/dev/null || true

        break
    fi
done

# ============================================================================
# GOOGLE CLOUD SDK
# ============================================================================
# NOTE: Provides 'gcloud' command for Google Cloud Platform

# macOS (Homebrew)
if [[ -d "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" ]]; then
    source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
    source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
# Linux - Home directory
elif [[ -d "$HOME/google-cloud-sdk" ]]; then
    source "$HOME/google-cloud-sdk/path.zsh.inc"
    source "$HOME/google-cloud-sdk/completion.zsh.inc"
# Linux - System-wide
elif [[ -d "/usr/share/google-cloud-sdk" ]]; then
    source "/usr/share/google-cloud-sdk/path.zsh.inc"
    source "/usr/share/google-cloud-sdk/completion.zsh.inc"
fi

# ============================================================================
# ZOXIDE (Directory Jumping)
# ============================================================================
# NOTE: Replaces z/autojump with smarter frecency-based navigation
# Usage: z <partial-path>, zi for interactive selection

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    alias cdi="zi"    # Interactive selection with fzf
fi

# ============================================================================
# STARSHIP PROMPT
# ============================================================================
# NOTE: Cross-shell prompt written in Rust
# Config: ~/.config/starship.toml

eval "$(starship init zsh)"

# ============================================================================
# LOCAL CONFIGURATION
# ============================================================================
# NOTE: Put machine-specific config in ~/.zshrc.local (not tracked by git)
# Examples:
#   - Work-specific aliases
#   - API keys and secrets (CONTEXT7_API_KEY, OPENAI_API_KEY, etc.)
#   - Machine-specific PATH additions
#
# Template for ~/.zshrc.local:
#   # MCP Server API Keys (optional - for higher rate limits)
#   export CONTEXT7_API_KEY="your-api-key-here"
#
#   # Other secrets
#   export OPENAI_API_KEY="sk-..."
#   export ANTHROPIC_API_KEY="sk-ant-..."

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ============================================================================
# END OF CONFIGURATION
# ============================================================================
