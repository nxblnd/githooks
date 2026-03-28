#!/usr/bin/env sh

. "$(dirname "$0")/lib/log.sh"
. "$(dirname "$0")/lib/selector.sh"
. "$(dirname "$0")/lib/set.sh"
. "$(dirname "$0")/lib/util.sh"

INSTALL="Install"
ADD="Add"
REMOVE="Remove"
UPDATE="Update"
QUIT="Quit"

mkMenu() {
    hooks_path="$(getGitConfig "core.hooksPath")"

    if [ -n "$hooks_path" ] || [ "$(realpath "./")" != "$hooks_path" ]
    then
        debug "Githooks not installed"
        printf "%b" "$INSTALL\n$QUIT"
        return
    fi

    printf "%b" "$ADD\n$REMOVE\n$UPDATE\n$QUIT"
}

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
            case $(selector -y) in
                yes) : ;;
                no) continue ;;
                *) exit 1 ;;
            esac
        fi
        rm -r "$hook.d"
        log "Removed $hook script directory"
    done
}

loadVars() {
    LOG_LEVEL="${LOG_LEVEL:-$(loadConfig "hooks.log_level" "$LEVEL_INFO")}"
    LOG_LEVEL="$(parseLogLevel "$LOG_LEVEL")"
}

main() {
    loadVars
    chooseSelector
    defineGitConfig

    while true
    do
        case $(mkMenu | selector) in
            "$INSTALL") exit 1;;
            "$ADD") addHooks ;;
            "$REMOVE") removeHooks ;;
            "$UPDATE") exit 1 ;;
            "$QUIT") exit ;;
            *) exit 1 ;;
        esac
    done
}

main
