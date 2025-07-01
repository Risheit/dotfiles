# Profiling code. Set ZSH_DEBUGRC=1 when loading
if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zmodload zsh/zprof
fi

# Clear kitty image cache to force Fastfetch to redraw
printf '\033_Ga=d\033\\'

# Display fastfetch 
/opt/homebrew/bin/fastfetch --logo /Users/rishe/.config/fastfetch/logo.png --logo-type kitty --logo-width 45 

# Set up the prompt
autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory

# Custom keybinds
bindkey "^[[1;9C" forward-word    # opt-right
bindkey "^[[1;9D" backward-word   # opt-left
bindkey "^@" autosuggest-accept   # Ctrl-space

# Custom aliases
alias cd-="cd -"
alias cd..="cd .."

alias ls="ls -CF --color=auto"
alias ll='ls -alhF'
alias la='ls -A'
alias l='ls -CF'

alias less='less -R'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias vim='nvim'
alias nvo='nvim .'

alias matlab='/Applications/MATLAB_R2024a.app/bin/matlab -nodesktop'

# Git aliases
alias g='git'
alias gaa='git add .'
alias gb='git b'
alias gc='git commit'
alias gc-='git c-'
alias gst='git status'
alias gps='git push'
alias gpl='git pull'
alias gt='git tree'
alias gf='git f'
alias gfu='git fu'
alias gs='git stash'
alias gsp='git stash pop'
alias gsw='git switch'
alias gsd='git stash drop'
alias gra='git restore .'
alias grs='git restore --staged .'
alias gcm='git cm'

# Allow colours
autoload -U colors && colors
PS1="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[yellow]%}%~ %{$reset_color%}%% "

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
[ -f "/home/risheit/.ghcup/env" ] && source "/home/risheit/.ghcup/env" # ghcup-env

# Setup Brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Source zsh plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#53555e"

[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Source google cloud cli
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

# Setup oh-my-posh Terminal
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/catpuccin_mocha.omp.json)"

export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# https://superuser.com/a/1611283 -- Speed up zsh launch by lazy-loading nvm
alias nvm="unalias nvm; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; nvm $@"

# export path
export PATH="$PATH:/opt/homebrew/opt/openjdk/bin"
export PATH="$PATH:/home/risheit/scripts"
export PATH="$PATH:/home/risheit/.nvm/versions/node/v18.7.0/bin"
export PATH="$PATH:/opt/homebrew/opt/ncurses/bin"
export PATH="$PATH:/opt/homebrew/opt/ncurses/lib"
export PATH="$PATH:/Users/rishe/.ghcup/bin"
export PATH="$PATH:/Users/rishe/.ghcup/ghc/9.8.2/bin"
export PATH="$PATH:/Library/PostgreSQL/17/bin"

# export environment variables
export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"
export JAVA_HOME="/opt/homebrew/opt/openjdk"

# Profile load time
if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zprof
fi
