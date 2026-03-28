#!/usr/bin/env sh

chooseSelector() {
    if command -v gum >/dev/null
    then
        debug "Using charmbracelet/gum as selector"

        selector() {
            OPTIND=1
            while getopts "my" opt
            do
                case "$opt" in
                    m) multiselect="--no-limit" ;;
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

            gum choose $multiselect
        }
    elif command -v fzf >/dev/null
    then
        debug "Using junegunn/fzf as selector"

        selector() {
            OPTIND=1
            while getopts "my" opt
            do
                case "$opt" in
                    m) multiselect="--multi" ;;
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

            fzf $multiselect
        }
    else
        debug "Using shell scripting as selector"
        error "Not implemented yet"
        exit 1
    fi
}
