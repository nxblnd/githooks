#!/usr/bin/env sh

. lib/log.sh
. lib/selector.sh

installHooks() {
    selected_hooks=$(selector -m <"hooks")

    for hook in $selected_hooks
    do
        [ ! -e "$hook" ] && ln -s "lib/hook.sh" "$hook"
        mkdir -p "$hook.d"
    done
}

main() {
    installHooks
}

main
