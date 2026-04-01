#!/usr/bin/env sh

GUM="gum"
FZF="fzf"
DIY="shell"

SELECTOR="$DIY"

. "$(dirname "$0")/lib/log.sh"

chooseSelector() {
    haveGum="$(command -v "$GUM")"
    haveFzf="$(command -v "$FZF")"

    if [ "$haveGum" ] && [ "${1:-$GUM}" = "$GUM" ]
    then
        debug "Using charmbracelet/gum as selector"
        SELECTOR="selectorGum"
    elif [ "$haveFzf" ] && [ "${1:-$FZF}" = "$FZF" ]
    then
        debug "Using junegunn/fzf as selector"
        SELECTOR="selectorFzf"
    else
        debug "Using shell scripting as selector"
        SELECTOR="selectorShell"
    fi
}

selector() {
    "$SELECTOR" "$@"
}

selectorGum() {
    OPTIND=1
    while getopts "h:my" opt
    do
        case "$opt" in
            h) header="$OPTARG" ;;
            m) multiselect="1" ;;
            y) yesno="1" ;;
            *) exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    if [ -n "${yesno:-}" ]
    then
        printf "%b" "yes\nno" | gum choose
        return
    fi

    gum choose \
        ${multiselect:+--no-limit} \
        ${header:+--header "$header"}
}

selectorFzf() {
    OPTIND=1
    while getopts "h:my" opt
    do
        case "$opt" in
            h) header="$OPTARG" ;;
            m) multiselect="1" ;;
            y) yesno="1" ;;
            *) exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    if [ -n "${yesno:-}" ]
    then
        printf "%b" "yes\nno" | fzf
        return
    fi

    fzf \
        ${multiselect:+--multi} \
        ${header:+--header "$header"}
}

selectorShell() {
    error "Not implemented yet"
    error "Please install gum, fzf or do everything manually in the meantime"
    exit 1
}
