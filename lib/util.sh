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
    else
        # git <2.46.0
        debug "Using 'git config' with flags"
        getGitConfig() { git config --get "$1"; }
    fi
}

cleanup() {
    if [ -n "${tmpfile:-}" ] && [ -e "$tmpfile" ]
    then
        debug "Removing tmpfile"
        rm "$tmpfile"
    fi
}

setupTmpFile() {
    tmpfile=$(mktemp "${TMPDIR:-/tmp}/tmp.githook-XXXXXX")
    trap 'cleanup' INT QUIT TERM EXIT
}
