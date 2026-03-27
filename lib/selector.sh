#!/usr/bin/env sh

if command -v gum >/dev/null
then
    debug "Using charmbracelet/gum as selector"

    selector() {
        OPTIND=1
        while getopts "m" opt
        do
            case "$opt" in
                m) multiselect="--no-limit" ;;
                *) exit 1 ;;
            esac
        done
        shift $((OPTIND - 1))

        gum choose $multiselect
    }
elif command -v fzf >/dev/null
then
    debug "Using junegunn/fzf as selector"

    selector() {
        OPTIND=1
        while getopts "m" opt
        do
            case "$opt" in
                m) multiselect="--multi" ;;
                *) exit 1 ;;
            esac
        done
        shift $((OPTIND - 1))

        fzf $multiselect
    }
else
    debug "Using shell scripting as selector"
    error "Not implemented yet"
    exit 1
fi
