#!/usr/bin/env sh

LOCATION="$(dirname "$0")"

if [ -d "$LOCATION/lib" ]
then
    . "$LOCATION/lib/log.sh"
    . "$LOCATION/lib/selector.sh"
    . "$LOCATION/lib/util.sh"
else
    BOOTSTRAP=1
fi

INSTALL="Install"
SETUP="Setup"
ADD="Add"
REMOVE="Remove"
UPDATE="Update"
QUIT="Quit"

GITHOOKS_URL="${GITHOOKS_URL:-https://github.com/nxblnd/githooks}"
BRANCH="${BRANCH:-main}"

mkMenu() {
    hooks_path="$(getGitConfig "core.hooksPath")"

    if [ -z "$hooks_path" ]
    then
        debug "Githooks are not set up"
        printf "%b" "$SETUP\n$QUIT"
        return
    fi

    printf "%b" "$ADD\n$REMOVE\n$UPDATE\n$QUIT"
}

install() {
    message="chore: added git hooks"
    git subtree \
        --prefix "$PREFIX" \
        --squash \
        -m "$message" \
        add "$GITHOOKS_URL" "$BRANCH"
}

setupHooks() {
    install_path="$(realpath "$(dirname "$0")")"
    setGitConfig "core.hooksPath" "$install_path"
    debug "Set git core.hooksPath to '$install_path'"
}

addHooks() {
    selected_hooks=$(selector -m <"$LOCATION/hooks")

    for hook in $selected_hooks
    do
        [ ! -e "$hook" ] && ln -s "$LOCATION/lib/hook.sh" "$hook"
        mkdir -p "$hook.d"
        log "Added $hook hook"
    done
}

removeHooks() {
    selected_hooks=$(selector -m <"$LOCATION/hooks")

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

update() {
    message="chore: updated git hooks"
    git subtree \
        --prefix "$PREFIX" \
        --squash \
        -m "$message" \
        pull "$GITHOOKS_URL" "$BRANCH"
}

loadVars() {
    OPTIND=1
    while getopts "p:" opt
    do
        case "$opt" in
            p) PREFIX="$OPTARG" ;;
            *) error "Wrong option $opt" && exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    PREFIX="${PREFIX:-.githooks}"

    LOG_LEVEL="${LOG_LEVEL:-$(loadConfig "hooks.log_level" "$LEVEL_INFO")}"
    LOG_LEVEL="$(parseLogLevel "$LOG_LEVEL")"
}

bootstrap() {
    if git rev-parse --is-inside-work-tree >/dev/null
    then
        install
        exec "$(git rev-parse --show-toplevel)/$PREFIX/manager.sh"
    else
        exit 1
    fi
}

main() {
    [ -n "${BOOTSTRAP:-}" ] && bootstrap && exit

    loadVars "$@"
    chooseSelector
    defineGitConfig

    while true
    do
        case $(mkMenu | selector) in
            "$INSTALL") exit 1 ;;
            "$SETUP") setupHooks && addHooks ;;
            "$ADD") addHooks ;;
            "$REMOVE") removeHooks ;;
            "$UPDATE") update ;;
            "$QUIT") exit ;;
            *) exit 1 ;;
        esac
    done
}

main "$@"
