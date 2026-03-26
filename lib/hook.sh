#!/usr/bin/env sh

set -eu

. "$(dirname "$0")/lib/log.sh"
. "$(dirname "$0")/lib/time.sh"

HOOK_NAME=$(basename "$0")

defineGitConfig() {
    debug "$(git --version)"

    # Probably easier to check if git supports new sub command this way
    # than compare version numbers
    if git config list >/dev/null 2>&1
    then
        # git >=2.46.0
        debug "Using 'git config' with subcommands"
        getGitConfig() { git config get "$1"; }
    else
        # git <2.46.0
        debug "Using 'git config' with flags"
        getGitConfig() { git config --get "$1"; }
    fi
}

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
    env_var_value="$1"
    git_config_path="$2"
    default_value="$3"

    if [ -n "$env_var_value" ]
    then
        echo "$env_var_value"
    else
        getGitConfig "$git_config_path" 2>/dev/null || echo "$default_value"
    fi
}

loadVars() {
    LOG_LEVEL="$(resolveVar "${LOG_LEVEL:-}" hooks.log_level "$LEVEL_INFO" | parseLogLevel)"
    SKIP_HOOKS="$(resolveVar "${SKIP_HOOKS:-}" hooks.skip " ")"
    SKIP_ALL_HOOKS="$(resolveVar "${SKIP_ALL_HOOKS:-}" hooks.skip_all "")"
}

cleanup() {
    if [ -n "${tmpfile:-}" ] && [ -e "$tmpfile" ]
    then
        debug "Removing tmpfile"
        rm "$tmpfile"
    fi
}

handleExitCode() (
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
)

main() {
    loadVars
    checkSkipVars
    defineGitConfig

    tmpfile=$(mktemp "${TMPDIR:-/tmp}/tmp.githook-XXXXXX")
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
        log "Running $HOOK_NAME/$script_basename..."
        measureExecution "$script" >"$tmpfile" 2>&1
        status=$?
        deletePrevLine
        log "Completed $HOOK_NAME/$script_basename in $(fmtTime $duration)"
        debug "$HOOK_NAME/$script_basename exit code $status"
        set -e

        handleExitCode "$script_basename" "$status" "$tmpfile"
    done

    debug "Done $HOOK_NAME hook"
}

main
