# basic commands
function ll(){
    ls -alhF $1;
}
alias lsgp='ls | grep -i'
alias llgp='ll | grep -i'
alias hgp='history | grep -i --color'
alias fd='_fd(){ find -L . -iname "*$1*"; }; _fd'
alias gp='_gp(){ grep -i --color "$1" *; }; _gp'
alias py='python3'
alias bfg='java -jar /usr/local/opt/bfg/bfg.jar'
alias pcat='pygmentize -g'  # for pygments
alias typora='open -a typora'  # for Typora
alias tree='tree -ACF'  # for tree
