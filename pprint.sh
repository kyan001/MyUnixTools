#!/usr/bin/env bash
function pprint {
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
        *)
            prefix=""
            style="white on black"
            ;;
    esac
    if command -v rich >& /dev/null; then
        rich --print "[dim]${prefix}[/][${style}]${*}"
    else
        echo ""
        echo "  ${prefix}${*}"
        echo ""
    fi
}
