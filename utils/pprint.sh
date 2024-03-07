#!/usr/bin/env bash
#
# * Install rich package for full features: `pip install --user rich-cli` or `pipx install rich-cli`
#
# Usage:
# ```sh
# source ./pprint.sh
# pprint -i/--info "Hello"
# pprint -w/--warn "Hello"
# pprint -e/--err "Hello"
# pprint -c/--code "Hello"
# pprint -t/--title "Hello"
# pprint -p/--panel "Hello"
# pprint "Hello"
# pprint -d/--debug "Hello"
# ```
#
function pprint {
    local prefix=""
    local rich_style=""
    local ansi_style=""
    local rich_param=""
    case "$1" in
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
        -c | --code)
            prefix="(Code) "
            rich_style="italic"
            ansi_style="\e[3m"  # italic
            shift
            ;;
        -t | --title)
            rich_param="--rule"
            ansi_style="\e[1m"  # bold
            shift
            ;;
        -p | --panel)
            prefix="| "
            rich_style="underline"
            ansi_style="\e[4m"  # underline
            shift
            ;;
        -d | --debug)
            prefix="(Debug) "
            rich_style="blink"
            ansi_style="\e[5m"  # blink
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
            rich --print "${content}" "$rich_param"
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
