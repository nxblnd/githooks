#!/usr/bin/env sh

defineGitConfig() {
    debug "$(git --version)"

    # Probably easier to check if git supports new sub command this way
    # than compare version numbers
    if git config list >/dev/null 2>&1
    then
        # git >=2.46.0
        debug "Using 'git config' with subcommands"
        getGitConfig() { git config get "$1"; }
        setGitConfig() { git config set "$@"; }
    else
        # git <2.46.0
        debug "Using 'git config' with flags"
        getGitConfig() { git config --get "$1"; }
        setGitConfig() { git config --set "$@"; }
    fi
}

cleanup() {
    debug "Removing file(s) $*"
    rm -f "$@"
}

mkTmpFile() {
    mktemp "${TMPDIR:-/tmp}/tmp.githook-XXXXXX"
}

loadConfig() {
    getGitConfig "$1" 2>/dev/null || echo "$2"
}
