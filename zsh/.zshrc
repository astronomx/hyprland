# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by newuser for 5.9
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================
# History Configuration
# ============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Report cwd to tmux/kitty (needed for split-window -c "#{pane_current_path}")
if [[ -n "$TMUX" ]]; then
  __tmux_report_cwd() {
    printf '\e]7;file://%s%s\e\\' "$HOST" "$PWD"
  }
  precmd_functions+=(__tmux_report_cwd)
  chpwd_functions+=(__tmux_report_cwd)
  __tmux_report_cwd
fi

# ============================================================================
# Completion
# ============================================================================
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Purple directories in completion
zstyle ':completion:*' list-colors 'di=35:ln=36:so=32:pi=33:ex=31:bd=34:cd=34:su=0:sg=0:tw=0:ow=0'

# ============================================================================
# Functions
# ============================================================================
# Override mkdir to automatically cd into created directory
mkdir() {
    command mkdir -p "$@" && cd "$_"
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick note taking
note() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $*" >> ~/notes.txt
    local id=$(wc -l < ~/notes.txt)
    echo "Note added with ID: $id"
}

# Show all notes with ID numbers
notes() {
    if [ ! -f ~/notes.txt ] || [ ! -s ~/notes.txt ]; then
        echo "No notes found."
        return
    fi
    cat -n ~/notes.txt | sed 's/^\s*//' | column -t -s '|'
}

# Delete note by ID
delnote() {
    if [ -z "$1" ]; then
        echo "Usage: delnote <id>"
        return 1
    fi
    
    if [ ! -f ~/notes.txt ]; then
        echo "No notes file found."
        return 1
    fi
    
    local id=$1
    local total=$(wc -l < ~/notes.txt)
    
    if [ "$id" -ge 1 ] && [ "$id" -le "$total" ]; then
        sed -i "${id}d" ~/notes.txt
        echo "Note $id deleted."
    else
        echo "Note with ID $id not found."
    fi
}

# ============================================================================
# Plugins
# ============================================================================
# Load plugins first before setting keybindings

# Syntax highlighting: sudo pacman -S zsh-syntax-highlighting
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Auto-suggestions: sudo pacman -S zsh-autosuggestions
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# History substring search: sudo pacman -S zsh-history-substring-search
if [ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

# ============================================================================
# Key Bindings
# ============================================================================
# History search with arrow keys (built-in, no plugin needed)
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# bun completions
[ -s "/home/unknownuser/.bun/_bun" ] && source "/home/unknownuser/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
alias gnome-control-center='XDG_CURRENT_DESKTOP=GNOME gnome-control-center'
