#!/usr/bin/env zsh
# ============================================================================
#                         ZSH CONFIGURATION
#                    github.com/wit543/dotfiles
# ============================================================================
# Supports: macOS, Ubuntu, Rocky Linux, Manjaro
# ============================================================================

# ============================================================================
# POWERLEVEL10K INSTANT PROMPT
# ============================================================================
# NOTE: Must stay near top of .zshrc for instant prompt to work
# Disable if you have console output during shell startup
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# OH-MY-ZSH CONFIGURATION
# ============================================================================
# NOTE: Install oh-my-zsh first: https://ohmyz.sh/

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Standard oh-my-zsh plugins
# NOTE: These are bundled with oh-my-zsh, no extra installation needed
plugins=(
    git            # Git aliases and functions (ga, gc, gp, etc.)
    z              # Jump to frecent directories (z <partial-path>)
    fzf            # Fuzzy finder integration
    extract        # Extract any archive with 'x' command
    docker         # Docker autocompletion
    docker-compose # Docker-compose autocompletion
    dotenv         # Auto-load .env files
)

# Load oh-my-zsh
[[ -f $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh

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
# ALIASES - FILE & DIRECTORY
# ============================================================================

alias ls="ls --color=auto"
alias ll="ls -lah"
alias la="ls -A"
alias l="ls -CF"

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
# NOTE: More git aliases defined by oh-my-zsh git plugin

alias gs="git status"
alias gd="git diff"
alias gds="git diff --staged"
alias glog="git log --oneline --graph --decorate -20"

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
# ZSH PLUGINS (External - via source-git)
# ============================================================================
# NOTE: These are cloned to ~/.zsh/ on first use

# Helper function to clone and source plugins
source-git() {
    local repo="$1"
    local target="$HOME/.zsh/${repo:t:r}"
    local plugin="$target/${repo:t:r}.plugin.zsh"

    # Clone if not exists
    [[ ! -d "$target" ]] && git clone --depth=1 "$repo" "$target"

    # Try .plugin.zsh first, then bare name
    [[ ! -f "$plugin" ]] && plugin="$target/${repo:t:r}"

    [[ -f "$plugin" ]] && source "$plugin"
}

# Fuzzy directory jumping (integrates with fzf + z)
source-git https://github.com/supasorn/fzf-z.git

# Interactive cd with fzf
source-git https://github.com/changyuheng/zsh-interactive-cd.git

# Suggestions based on history (gray text)
source-git https://github.com/zsh-users/zsh-autosuggestions.git

# Quick navigation (Ctrl+F to jump)
source-git https://github.com/hchbaw/zce.zsh.git

# Bookmark directories (Ctrl+G to mark, Ctrl+H to jump)
source-git https://github.com/urbainvaes/fzf-marks

# Additional completions
source-git https://github.com/zsh-users/zsh-completions

# History substring search (Up/Down arrows)
source-git https://github.com/zsh-users/zsh-history-substring-search

# Syntax highlighting (MUST be last plugin)
source-git https://github.com/zsh-users/zsh-syntax-highlighting.git

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
export FZFZ_SUBDIR_LIMIT=0

# ============================================================================
# FZF INTEGRATION
# ============================================================================
# NOTE: Provides Ctrl+R (history), Ctrl+T (files), Alt+C (cd)

[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# ============================================================================
# COMPLETIONS
# ============================================================================

autoload -Uz compinit
compinit -C  # -C: skip security check for faster startup

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
# POWERLEVEL10K THEME
# ============================================================================
# NOTE: Run 'p10k configure' to customize prompt

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ============================================================================
# LOCAL CONFIGURATION
# ============================================================================
# NOTE: Put machine-specific config in ~/.zshrc.local (not tracked by git)
# Examples:
#   - Work-specific aliases
#   - API keys and secrets
#   - Machine-specific PATH additions

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ============================================================================
# END OF CONFIGURATION
# ============================================================================
