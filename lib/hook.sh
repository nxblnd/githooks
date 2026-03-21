#!/usr/bin/env sh

set -eu

. "$(dirname "$0")/lib/log.sh"

HOOK_NAME=$(basename "$0")

checkSkipVars() {
    SKIP_ALL_HOOKS="${SKIP_ALL_HOOKS+skip}"
    SKIP_HOOKS=${SKIP_HOOKS:-" "}

    if [ -n "$SKIP_ALL_HOOKS" ] || echo "$HOOK_NAME" | grep -Eq "$SKIP_HOOKS"
    then
        log "Skipping $(basename "$0") hook"
        debug "SKIP_ALL_HOOKS=$SKIP_ALL_HOOKS"
        debug "SKIP_HOOKS=$SKIP_HOOKS"
        exit 0
    fi
}

main() {
    checkSkipVars

    log "Running $HOOK_NAME hook"
    for script in "$HOOK_NAME.d"/*
    do
        script_basename=$(basename "$script")

        if [ ! -x "$script" ]
        then
            debug "  - Skipping $script_basename, +x flag not set"
            continue
        fi

        log "  - $script_basename"

        tmpfile=$(mktemp)

        set +e
        "$script" >"$tmpfile" 2>&1
        status=$?
        debug "    Exit code $status"
        set -e

        if [ "$status" -eq 0 ]
        then
            if [ "$LOG_LEVEL" -ge "$LEVEL_DEBUG" ]
            then
                debug "    Script output below"
                cat "$tmpfile"
            fi
        else
            warning "    Script failed, see log below"
            cat "$tmpfile"
            exit 1
        fi

        rm "$tmpfile"
    done

    debug "Done $HOOK_NAME hook"
}

main
