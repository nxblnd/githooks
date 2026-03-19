#!/usr/bin/env sh

set -eu

BLACK="\033[0;30m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"

RESET="\033[0m"

LEVEL_SILENT=0
LEVEL_ERROR=1
LEVEL_WARNING=2
LEVEL_INFO=3
LEVEL_DEBUG=4

LOG_LEVEL="${LOG_LEVEL:-$LEVEL_INFO}"

coloredMessage() {
    label="$1"
    color="$2"
    message="$3"

    if [ -t 2 ]
    then
        # STDERR exists, we are in terminal, can do fancy output
        printf '%b%s:%b %s\n' "$color" "$label" "$RESET" "$message" >&2
    else
        # STDERR does not exist, probably writing into a file -> no escape codes
        printf '%s: %s\n' "$label" "$message" >&2
    fi
}

debug() {
    if [ "$LOG_LEVEL" -gt "$LEVEL_INFO" ]
    then
        coloredMessage "DEBUG" "$RESET" "$1"
    fi
}

log() {
    if [ "$LOG_LEVEL" -gt "$LEVEL_WARNING" ]
    then
        coloredMessage "INFO" "$CYAN" "$1"
    fi
}

warning() {
    if [ "$LOG_LEVEL" -gt "$LEVEL_ERROR" ]
    then
        coloredMessage "WARNING" "$YELLOW" "$1"
    fi
}

error() {
    if [ "$LOG_LEVEL" -gt "$LEVEL_SILENT" ]
    then
        coloredMessage "ERROR" "$RED" "$1"
    fi
}

