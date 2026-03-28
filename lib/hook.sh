#!/usr/bin/env sh

. "$(dirname "$0")/lib/log.sh"
. "$(dirname "$0")/lib/time.sh"
. "$(dirname "$0")/lib/util.sh"

HOOK_NAME=$(basename "$0")

checkSkip() {
    if [ -n "$SKIP_ALL_HOOKS" ] || echo "$HOOK_NAME" | grep -Eq "$SKIP_HOOKS"
    then
        log "Skipping $HOOK_NAME hook"
        debug "SKIP_ALL_HOOKS=$SKIP_ALL_HOOKS"
        debug "SKIP_HOOKS=$SKIP_HOOKS"
        exit 0
    fi
}

loadVars() {
    LOG_LEVEL="${LOG_LEVEL:-$(loadConfig "hooks.log_level" "$LEVEL_INFO")}"
    LOG_LEVEL="$(parseLogLevel "$LOG_LEVEL")"
    SKIP_HOOKS="${SKIP_HOOKS:-$(loadConfig "hooks.skip" " ")}"
    SKIP_ALL_HOOKS="${SKIP_ALL_HOOKS:-$(loadConfig "hooks.skip_all" "")}"
}

handleExitCode() {
    script="$1"
    status="$2"
    tmpfile="$3"

    if [ "$status" -eq 0 ]
    then
        if [ "$LOG_LEVEL" -ge "$LEVEL_DEBUG" ]
        then
            debug "$HOOK_NAME/$script output below"
            printFile "debug" "$tmpfile"
        fi
    elif [ "$status" -lt 126 ]
    then
        warning "$HOOK_NAME/$script failed, see log below"
        printFile "warning" "$tmpfile"
        exit "$status"
    elif [ "$status" -eq 126 ]
    then
        error "$HOOK_NAME/$script was not executable. How is this code running?"
        exit "$status"
    elif [ "$status" -eq 127 ]
    then
        error "$HOOK_NAME/$script was not found. How is this code running?"
        exit "$status"
    else
        warning "$HOOK_NAME/$script was interrupted"
    fi
}

runScript() {
    log "Running $HOOK_NAME/$script_basename..."

    duration=$(measureExecution -o "$tmpfile" -e "$tmpfile" "$script")
    status="$?"

    [ "$LOG_LEVEL" -ge "$LOG_INFO" ] && deletePrevLine
    log "Completed $HOOK_NAME/$script_basename in $(fmtTime "$duration")"
    debug "$HOOK_NAME/$script_basename exit code $status"

    return "$status"
}

main() {
    loadVars
    checkSkip
    defineGitConfig
    tmpfile=$(mkTmpFile)
    trap 'cleanup $tmpfile' INT QUIT TERM EXIT

    log "Running $HOOK_NAME hook"

    hooks_path="$(loadConfig "core.hooksPath" "$(dirname "$0")")/$HOOK_NAME.d"
    debug "Hooks path: $hooks_path"

    for script in "$hooks_path"/*
    do
        # Safeguard empty directory expansion into '*' named file.
        [ -e "$script" ] || continue

        script_basename=$(basename "$script")

        if [ ! -x "$script" ]
        then
            debug "Skipping $HOOK_NAME/$script_basename, +x flag not set"
            continue
        fi

        runScript
        handleExitCode "$script_basename" "$?" "$tmpfile"
    done

    debug "Done $HOOK_NAME hook"
}

main
