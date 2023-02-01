#!/usr/bin/env bash
function pprint {
    local prefix=""
    local style=""
    local param=""
    case $1 in
        -i | --info)
            prefix="(Info) "
            style="yellow"
            shift
            ;;
        -w | --warn)
            prefix="(Warning) "
            style="red"
            shift
            ;;
        -e | --err)
            prefix="(Error) "
            style="on red"
            shift
            ;;
        -t | --title)
            param="--rule"
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
        builtin echo ""
        builtin echo "  ${prefix}${*}"
        builtin echo ""
    fi
}
