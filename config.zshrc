# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    colored-man-pages  # man page colorized
    colorize  # ccat = colorized cat, using pygmentize
    z  # auto jump to history changed dir
    # _Completions___________
    git  # git suggestion
    httpie  # HTTPie completion
    docker  # docker completion
    npm  # npm completion
    pip  # pip completion
    python  # python completion
    redis-cli  # redis-cli completion
    coffee  # CoffeeScript completion
    supervisor  # Supervisor completion
    # _3rd party's___________
    zsh-nvm  # 3rd party plugins. add wraps of nvm command.
    zsh-autosuggestions  # 3rd party plugins. gray suggestions in tail
    zsh-syntax-highlighting  # 3rd party plugins. highlights shell commands
)
case $(uname -a) in  # this problem only on Windows Subsystem Linux
    *Microsoft*)
        unsetopt BG_NICE  # for "z", to avoid _z_precmd:1: nice(5) failed: operation not permitted
        export LS_COLORS="${LS_COLORS}ow=34;36:"  # change windows directory bg color.
        ;;
    *Darwin*)
        eval $(/opt/homebrew/bin/brew shellenv)
        ;;
esac

export NVM_LAZY_LOAD=true  # lazy load for zsh-nvm
export PATH="$(python3 -m site --user-base)/bin:$PATH"  # Python User Site-Package Binaries

source $ZSH/oh-my-zsh.sh

proxy() {
    local proxy_addr="socks://127.0.0.1:1088"
    if [ -z "$ALL_PROXY" ] && [ -z "$HTTPS_PROXY" ] && [ -z "$HTTP_PROXY" ]
    then
        export ALL_PROXY=$proxy_addr
        export HTTPS_PROXY=$proxy_addr
        export HTTP_PROXY=$proxy_addr
        echo "[Proxy] ALL_PROXY, HTTPS_PROXY and HTTP_PROXY set to $proxy_addr"
    else
        unset ALL_PROXY
        unset HTTPS_PROXY
        unset HTTP_PROXY
        echo "ALL_PROXY, HTTPS_PROXY and HTTP_PROXY have been unset"
    fi
}

# if p10k config is already done, uncomment the following line.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
