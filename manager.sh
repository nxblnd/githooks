#!/usr/bin/env sh

. lib/log.sh
. lib/selector.sh

INSTALL="Install"
ADD="Add"
REMOVE="Remove"
QUIT="Quit"

MODES="
$INSTALL
$ADD
$REMOVE
$QUIT"

addHooks() {
    selected_hooks=$(selector -m <"hooks")

    for hook in $selected_hooks
    do
        [ ! -e "$hook" ] && ln -s "lib/hook.sh" "$hook"
        mkdir -p "$hook.d"
        log "Added $hook hook"
    done
}

removeHooks() {
    selected_hooks=$(selector -m <"hooks")

    for hook in $selected_hooks
    do
        [ -e "$hook" ] && rm "$hook"
        log "Removed $hook hook"

        if [ -n "$(ls -A "$hook.d")" ]
        then
            warning "$hook directory is not empty"
            deleteDir=$(printf "%b" "yes\nno" | selector)
            case $deleteDir in
                yes) : ;;
                no) continue ;;
                *) exit 1 ;;
            esac
        fi
        rm -r "$hook.d"
        log "Removed $hook script directory"
    done
}

main() {
    while true
    do
        case $(printf "%s" "$MODES" | selector) in
            "$INSTALL") exit 1;;
            "$ADD") addHooks ;;
            "$REMOVE") removeHooks ;;
            "$QUIT") exit ;;
            *) exit 1 ;;
        esac
    done
}

main
