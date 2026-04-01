#!/usr/bin/env sh

TMP="${TMPDIR:-/tmp}"
TMP_PREFIX="tmp.githook"

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
    for file in "$TMP/$TMP_PREFIX-"*
    do
        debug "Removing file $file"
        rm -f "$file"
    done
}

mkTmpFile() {
    mktemp "${TMP}/$TMP_PREFIX-XXXXXX"
}

loadConfig() {
    getGitConfig "$1" 2>/dev/null || echo "$2"
}
