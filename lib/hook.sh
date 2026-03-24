#!/usr/bin/env sh

set -eu

. "$(dirname "$0")/lib/log.sh"

HOOK_NAME=$(basename "$0")

if git config list >/dev/null 2>&1
then
    # git >=2.46.0
    getGitConfig() {
        git config get "$1"
    }
else
    # git <2.46.0
    getGitConfig() {
        git config --get "$1"
    }
fi

checkSkipVars() {
    if [ -n "$SKIP_ALL_HOOKS" ] || echo "$HOOK_NAME" | grep -Eq "$SKIP_HOOKS"
    then
        log "Skipping $HOOK_NAME hook"
        debug "SKIP_ALL_HOOKS=$SKIP_ALL_HOOKS"
        debug "SKIP_HOOKS=$SKIP_HOOKS"
        exit 0
    fi
}

resolveVar() {
    env_var_name="$1"
    git_config_path="$2"
    default_value="$3"

    printenv "$env_var_name" || getGitConfig "$git_config_path" 2>/dev/null || echo "$default_value"
}

loadVars() {
    LOG_LEVEL="$(resolveVar LOG_LEVEL hooks.log_level "$LEVEL_INFO")"
    SKIP_HOOKS="$(resolveVar SKIP_HOOKS hooks.skip " ")"
    SKIP_ALL_HOOKS="$(resolveVar SKIP_ALL_HOOKS hooks.skip_all "")"
}

cleanup() {
    if [ -e "$tmpfile" ]
    then
        debug "Removing tmpfile"
        rm "$tmpfile"
    fi
}

main() {
    loadVars
    checkSkipVars

    tmpfile=$(mktemp --suffix "_githook")
    trap 'cleanup' INT QUIT TERM EXIT

    log "Running $HOOK_NAME hook"
    for script in "$HOOK_NAME.d"/*
    do
        # Safeguard empty directory expansion into '*' named file.
        [ -e "$script" ] || continue

        script_basename=$(basename "$script")

        if [ ! -x "$script" ]
        then
            debug "Skipping $HOOK_NAME/$script_basename, +x flag not set"
            continue
        fi

        set +e
        log "Running $HOOK_NAME/$script_basename"
        "$script" >"$tmpfile" 2>&1
        status=$?
        debug "$HOOK_NAME/$script_basename exit code $status"
        set -e

        if [ "$status" -eq 0 ]
        then
            if [ "$LOG_LEVEL" -ge "$LEVEL_DEBUG" ]
            then
                debug "$HOOK_NAME/$script_basename output below"
                printFile "debug" "$tmpfile"
            fi
        elif [ "$status" -lt 126 ]
        then
            warning "$HOOK_NAME/$script_basename failed, see log below"
            printFile "warning" "$tmpfile"
            exit 1
        elif [ "$status" -eq 126 ]
        then
            error "$HOOK_NAME/$script_basename was not executable. How is this code running?"
            exit 2
        elif [ "$status" -eq 127 ]
        then
            error "$HOOK_NAME/$script_basename was not found. How is this code running?"
            exit 2
        else
            warning "$HOOK_NAME/$script_basename was interrupted"
        fi
    done

    debug "Done $HOOK_NAME hook"
}

main
