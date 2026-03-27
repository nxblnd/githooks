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
    done
}

removeHooks() {
    selected_hooks=$(selector -m <"hooks")

    for hook in $selected_hooks
    do
        [ -e "$hook" ] && rm "$hook"
        [ -z "$(ls -A "$hook.d")" ] && rm -r "$hook.d" # remove hook dir only if it was empty
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
