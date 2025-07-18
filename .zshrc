#### Profiling code. 
# Set ZSH_DEBUGRC when loading.
if [[ -v ZSH_DEBUGRC ]]; then
    zmodload zsh/zprof
fi
####



## Configuration
() {
    ## Configuration variables
    
    local OH_MY_POSH_THEME="$HOME/.config/oh-my-posh/themes/catpuccin_mocha.omp.json"
    local ZSH_PLUGINS_DIR="$HOME/.zsh_plugins"
    local SCRIPTS_DIR="$HOME/scripts"
    local CUSTOM_BREW_DIR=

    # Check if on MacOS or Linux (Abort on windows) 
    if [[ $OSTYPE == darwin* ]]; then
        local ZSH_ON_MACOS=1
    elif [[ $OSTYPE == linux* ]]; then
        local ZSH_ON_LINUX=1
    else
        echo "This configuration is not supported inside the environment: ${OSTYPE-unknown}"
        return
    fi

    ## Helper functions 
    
    # Export PATH only if file exists
    function export_path {
        [[ -e "$1" ]] && export PATH="$PATH:$1"
    }

    # Install a program if it cannot be found in PATH using linux package managers.
    function autoinstall {
        local default="${2:-$1}"

        if ! command -v "$1" >/dev/null; then
            echo "Could not find the program: $1. Installing..."
            if [[ -v ZSH_ON_MACOS ]]; then
                brew install "${2:-$default}"
            elif [[ -v ZSH_ON_LINUX ]] && command -v apt >/dev/null; then
                sudo apt update && sudo apt install -y "${2:-$default}"
            elif [[ -v ZSH_ON_LINUX ]] && command -v pacman >/dev/null; then
                sudo pacman -Sy --noconfirm "${3:-$default}"
            elif [[ -v ZSH_ON_LINUX ]] && command -v dnf >/dev/null; then
                sudo dnf install -y "${4:-$default}"
            else
                echo "No recognizable package manager. Unable to install."
            fi
        fi

        # Return success of install
        command -v "$1" >/dev/null
    }

    # Set up the prompt
    autoload -Uz promptinit
    promptinit
    prompt adam1

    setopt histignorealldups sharehistory

    ## Ensure git exists

    if ! command -v git >/dev/null; then
        echo "Could not find the program: git. Please install manually."
        echo "Aborting configuration..."
        return 1 
    fi

    ## Set up homebrew if this is MacOS
    
    if ! [[ -v ZSH_ON_MACOS && -x "${CUSTOM_BREW_DIR:-/opt/homebrew}/bin/brew" ]]; then
        echo "Could not find the program: homebrew. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    eval "$(${CUSTOM_BREW_DIR:-/opt/homebrew}/bin/brew shellenv)"
    local BREW_PREFIX=$(brew --prefix)

    ## Modify PATH

    export_path $SCRIPTS_DIR
    export_path "$HOME/.ghcup/bin"
    export_path "$HOME/.ghcup/ghc/9.8.2/bin"

    if [[ -v ZSH_ON_MACOS ]]; then
        export_path "$BREW_PREFIX/opt/openjdk/bin" 
        export_path "$BREW_PREFIX/opt/ncurses/bin" 
        export_path "$BREW_PREFIX/opt/ncurses/lib" 
        export_path "/Library/PostgreSQL/17/bin"
    fi

    if [[ -v ZSH_ON_LINUX ]]; then 
        mkdir -p "$HOME/bin"
        PATH="$HOME/bin:$PATH"
    fi

    ## Custom keybinds

    bindkey "^[[1;9C" forward-word    # opt-right
    bindkey "^[[1;9D" backward-word   # opt-left
    bindkey "^@" autosuggest-accept   # Ctrl-space

    ## Aliases

    if [[ -v ZSH_ON_MACOS && -x "/Applications/MATLAB_R2024a.app/bin/matlab" ]]; then 
        alias matlab="/Applications/MATLAB_R2024a.app/bin/matlab -nodesktop"
    fi

    alias cd-='cd -'
    alias cd..='cd ..'

    alias ls='ls -CF --color=auto'
    alias ll='ls -alhF'
    alias la='ls -A'
    alias l='ls -CF'

    alias less='less -iRx4'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    alias vim='nvim'
    alias nvo='nvim .'

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

    ## Completion and history

    # Allow colours
    autoload -U colors && colors
    PS1="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[yellow]%}%~ %{$reset_color%}%% "

    # Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
    HISTSIZE=1000
    SAVEHIST=1000
    HISTFILE=~/.zsh_history

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

    ## Plugins and external programs
    
    autoinstall nvim neovim || unalias vim

    # Set up tiling window manager on MacOS
    if [[ -v ZSH_ON_MACOS ]] && ! command -v aerospace >/dev/null; then
        brew install aerospace --cask nikitabobko/tap/aerospace
        if ! command -v borders >/dev/null; then
            brew tap FelixKratz/formulae
            brew install borders
        fi
        echo "Installed aerospace as a tiling window manager. This will start up automatically next time you log in."
    fi

    # Setup oh-my-posh Terminal
    if ! command -v oh-my-posh >/dev/null; then
        echo "Could not find the program: oh-my-posh. Installing..."
        if [[ -v ZSH_ON_MACOS ]]; then
            brew install jandedobbeleer/oh-my-posh/oh-my-posh
        elif [[ -v ZSH_ON_LINUX ]]; then
            curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/bin"
        fi
    fi
    eval "$(oh-my-posh init zsh --config ${OH_MY_POSH_THEME})"

    # Install delta for git diffs
    autoinstall delta git-delta

    # Source and autoinstall zsh auto-suggestions
    if [[ -v ZSH_ON_MACOS && ! -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
        echo "Could not find the plugin: auto-suggestions. Installing..."
        brew install zsh-autosuggestions
    elif [[ -v ZSH_ON_LINUX && ! -f "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
        echo "Could not find the plugin: auto-suggestions. Installing..."
        mkdir -p "$ZSH_PLUGINS_DIR"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
    fi

    [[ -v ZSH_ON_MACOS ]] && source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -v ZSH_ON_LINUX ]] && source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#53555e"

    # Source and autoinstall autojump
    if [[ -v ZSH_ON_MACOS && ! -f "$BREW_PREFIX/etc/profile.d/autojump.sh" ]]; then
        echo "Could not find the plugin: autojump. Installing..."
        brew install autojump
    elif [[ -v ZSH_ON_LINUX && ! -f "$ZSH_PLUGINS_DIR/autojump/etc/profile.d/autojump.sh" ]]; then
        echo "Could not find the plugin: autojump. Installing..."
        mkdir -p "$ZSH_PLUGINS_DIR"
        git clone https://github.com/wting/autojump.git "$ZSH_PLUGINS_DIR/autojump"
        "$ZSH_PLUGINS_DIR/autojump/install.py" --destdir "$ZSH_PLUGINS_DIR/autojump"
    fi
    [[ -v ZSH_ON_MACOS ]] && source "$BREW_PREFIX/etc/profile.d/autojump.sh"
    [[ -v ZSH_ON_LINUX ]] && source "$ZSH_PLUGINS_DIR/autojump/etc/profile.d/autojump.sh"
    [[ -v ZSH_ON_LINUX ]] && export MANPATH="$MANPATH:$ZSH_PLUGINS_DIR/autojump/share/man/man1"

    # Source GHCup
    [[ -e "$HOME/.ghcup/env" ]] && source "$HOME/.ghcup/env" 

    # Source google cloud cli
    [[ -v ZSH_ON_MACOS && -e "$BREW_PREFIX/share/google-cloud-sdk/path.zsh.inc" ]] && source "$BREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"
    [[ -v ZSH_ON_MACOS && -e "$BREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc" ]] && source "$BREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"

    # Load NVM
    export NVM_DIR="$HOME/.nvm"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
    # Speed up zsh launch by lazy-loading nvm -- https://superuser.com/a/1611283
    alias nvm="unalias nvm; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; nvm $@"

    # Export environment variables
    if [[ -v ZSH_ON_MACOS ]]; then
        [[ -d "$BREW_PREFIX/opt/dotnet/libexec" ]] && export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"
        [[ -d "$BREW_PREFIX/opt/openjdk" ]] && export JAVA_HOME="/opt/homebrew/opt/openjdk"
    elif [[ -v ZSH_ON_LINUX ]]; then
        # Export .NET
        if [[ -d "/usr/share/dotnet" ]]; then
            export DOTNET_ROOT="/usr/share/dotnet"
        elif [[ -d "$HOME/dotnet" ]]; then
            export DOTNET_ROOT="$HOME/dotnet"
        fi

        # Export Java
        if [[ -d "/usr/lib/jvm/default-java" ]]; then
            export JAVA_HOME="/usr/lib/jvm/default-java"
        elif [[ -d "/usr/lib/jvm/java-21-openjdk-amd64" ]]; then
            export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
        elif [[ -d "$HOME/.sdkman/candidates/java/current" ]]; then
            export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
        fi
    fi

    # Use modern completion system
    autoload -Uz compinit
    compinit

    # Display and autoinstall fastfetch 
    autoinstall fastfetch
    command -v fastfetch >/dev/null && fastfetch --logo /Users/rishe/.config/fastfetch/logo.png --logo-type kitty --logo-width 45 

    # Source and autoinstall zsh-syntax-highlighting. 
    # Must be sourced at the end of configuration.
    if [[ -v ZSH_ON_MACOS && ! -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
        echo "Could not find the plugin: zsh-syntax-highlighting. Installing..."
        brew install autojump
    elif [[ -v ZSH_ON_LINUX && ! -f "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
        echo "Could not find the plugin: zsh-syntax-highlighting. Installing..."
        mkdir -p "$ZSH_PLUGINS_DIR"
        git clone "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
    fi
    [[ -v ZSH_ON_MACOS ]] && source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    [[ -v ZSH_ON_LINUX ]] && source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
}

## Custom Functions

# Profile the amount of time it takes zsh to start up.
function zsh-profile {
   time ZSH_DEBUGRC=1 zsh -i -c exit 
}

#### Profile load time
if [[ -v ZSH_DEBUGRC ]]; then
    zprof
fi
####

