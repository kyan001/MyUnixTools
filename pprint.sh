#!/usr/bin/env bash
#
# * Install rich package for full features: `pip install --user rich-cli`
# Usage:
# ```sh
# source ./pprint.sh
# pprint -i/--info "Hello, World!"
# pprint -w/--warn "Hello, World!"
# pprint -e/--err "Hello, World!"
# pprint -t/--title "Hello, World!"
# pprint -p/--panel "Hello, World!"
# pprint "Hello, World!"
# ```
#
function pprint {
    local prefix=""
    local style=""
    local param=""
    case $1 in
        -i | --info)
            prefix="(Info) "
            style="yellow"
            ansi="\e[33m"
            shift
            ;;
        -w | --warn)
            prefix="(Warning) "
            style="red"
            ansi="\e[31m"
            shift
            ;;
        -e | --err)
            prefix="(Error) "
            style="on red"
            ansi="\e[41m"
            shift
            ;;
        -t | --title)
            param="--rule"
            ansi="\e[1m"
            shift
            ;;
        -p | --panel)
            param="--panel rounded"
            shift
            ;;
        *)
            style="white on black"
            ;;
    esac
    if command -v rich >& /dev/null; then
        local content="${*}"
        if [[ -n $style ]]; then
            content="[${style}]$content"
        fi
        if [[ -n $prefix ]]; then
            content="[dim]${prefix}[/]$content"
        fi
        if [[ -n $param ]]; then
            rich --print "$content" $param
        else
            rich --print "$content"
        fi
    else
        local content="${*}"
        local ansi_reset="\e[0m"
        local ansi_dim="\e[2m"
        if [[ -n $ansi ]]; then
            content="${ansi}$content${ansi_reset}"
        fi
        if [[ -n $prefix ]]; then
            content="${ansi_dim}${prefix}${ansi_reset}$content"
        fi
        if [[ -n $param ]]; then
            builtin echo "$content" $param
        else
            builtin echo "$content"
        fi
    fi
}
