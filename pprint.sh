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
    local rich_style=""
    local ansi_style=""
    local rich_param=""
    case $1 in
        -i | --info)
            prefix="(Info) "
            rich_style="yellow"
            ansi_style="\e[33m"  # yellow
            shift
            ;;
        -w | --warn)
            prefix="(Warning) "
            rich_style="red"
            ansi_style="\e[31m"  # red
            shift
            ;;
        -e | --err)
            prefix="(Error) "
            rich_style="on red"
            ansi_style="\e[41m"  # red background
            shift
            ;;
        -t | --title)
            rich_param="--rule"
            ansi_style="\e[1m"  # bold
            shift
            ;;
        -p | --panel)
            rich_param="--panel rounded"
            ansi_style="\e[4m"  # underline
            shift
            ;;
        *)
            rich_style="white on black"
            ansi_style="\e[0m"  # reset
            ;;
    esac
    if command -v rich >& /dev/null; then
        local content="${*}"
        if [[ -n $rich_style ]]; then
            content="[${rich_style}]${content}"
        fi
        if [[ -n $prefix ]]; then
            content="[dim]${prefix}[/]${content}"
        fi
        if [[ -n $rich_param ]]; then
            rich --print "${$content}" "$rich_param"
        else
            rich --print "${content}"
        fi
    else
        local content="${*}"
        local ansi_reset="\e[0m"  # reset
        local ansi_dim="\e[2m"  # gray
        if [[ -n $ansi ]]; then
            content="${ansi}${content}${ansi_reset}"
        fi
        if [[ -n $prefix ]]; then
            content="${ansi_dim}${prefix}${ansi_reset}${content}"
        fi
        builtin echo "${content}"
    fi
}
