#!/usr/bin/env sh

set -eu

. "$(dirname "$0")/lib/log.sh"

HOOK_NAME=$(basename "$0")

checkSkipVars() {
    if [ -n "$SKIP_ALL_HOOKS" ] || echo "$HOOK_NAME" | grep -Eq "$SKIP_HOOKS"
    then
        log "Skipping $(basename "$0") hook"
        debug "SKIP_ALL_HOOKS=$SKIP_ALL_HOOKS"
        debug "SKIP_HOOKS=$SKIP_HOOKS"
        exit 0
    fi
}

resolveVar() {
    env_var_name="$1"
    git_config_path="$2"
    default_value="$3"

    env_var_value="$(printenv "$env_var_name" || true)"

    if [ -n "$env_var_value" ]
    then
        echo "$env_var_value"
    else
        git config get "$git_config_path" 2>/dev/null || echo "$default_value"
    fi
}

loadVars() {
    LOG_LEVEL="$(resolveVar LOG_LEVEL hooks.log_level "$LEVEL_INFO")"
    SKIP_HOOKS="$(resolveVar SKIP_HOOKS hooks.skip " ")"
    SKIP_ALL_HOOKS="$(resolveVar SKIP_ALL_HOOKS hooks.skip_all "")"
}

main() {
    loadVars
    checkSkipVars

    log "Running $HOOK_NAME hook"
    for script in "$HOOK_NAME.d"/*
    do
        script_basename=$(basename "$script")

        if [ ! -x "$script" ]
        then
            debug "Skipping $HOOK_NAME/$script_basename, +x flag not set"
            continue
        fi

        tmpfile=$(mktemp)

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
        else
            warning "$HOOK_NAME/$script_basename failed, see log below"
            printFile "warning" "$tmpfile"
            exit 1
        fi

        rm "$tmpfile"
    done

    debug "Done $HOOK_NAME hook"
}

main
