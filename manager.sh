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
    setGitConfig "core.hooksPath" "$HOOKS_PATH"
    debug "Set git core.hooksPath to '$HOOKS_PATH'"
}

addHooks() {
    selected_hooks=$(selector -m <"$LOCATION/hooks")

    for hook in $selected_hooks
    do
        [ ! -e "$HOOKS_PATH/$hook" ] && ln -s "$LOCATION/lib/hook.sh" "$HOOKS_PATH/$hook"
        mkdir -p "$HOOKS_PATH/$hook.d"
        log "Added $hook hook"
    done
}

removeHooks() {
    selected_hooks=$(selector -m <"$LOCATION/hooks")

    for hook in $selected_hooks
    do
        [ -e "$HOOKS_PATH/$hook" ] && rm "$HOOKS_PATH/$hook"
        log "Removed $hook hook"

        if [ -n "$(ls -A "$HOOKS_PATH/$hook.d")" ]
        then
            warning "$hook directory is not empty"
            case $(selector -y) in
                yes) : ;;
                no) continue ;;
                *) exit 1 ;;
            esac
        fi
        rm -r "$HOOKS_PATH/$hook.d"
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
    HOOKS_PATH="$GIT_ROOT/$PREFIX"

    LOG_LEVEL="${LOG_LEVEL:-$(loadConfig "hooks.log_level" "$LEVEL_INFO")}"
    LOG_LEVEL="$(parseLogLevel "$LOG_LEVEL")"

    debug "Hooks path: '$HOOKS_PATH'"
}

getGitRoot() {
    if git rev-parse --is-inside-work-tree 2>/dev/null
    then
        GIT_ROOT="$(git rev-parse --show-toplevel)"
    else
        git_error_message="Can't work outside git work tree!"
        if error 2>/dev/null
        then
            error "$git_error_message"
        else
            echo "$git_error_message"
        fi

        exit 1
    fi
}

bootstrap() {
    install
    exec "$GIT_ROOT/$PREFIX/manager.sh"
}

main() {
    getGitRoot
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
