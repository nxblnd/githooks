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
    OPTIND=1
    while getopts "c:f:l:" opt
    do
        case "$opt" in
            c) label_color="$OPTARG" ;;
            f) output_format="$OPTARG" ;;
            l) label_text="$OPTARG" ;;
            *) exit 1;;
        esac
    done
    shift $((OPTIND - 1))

    label_color=${label_color:-$RESET}
    output_format=${output_format:-"%b%s%b: %s\n"}
    message="$*"

    if [ -t 2 ]
    then
        # STDERR exists, we are in terminal, can do fancy output

        # shellcheck disable=SC2059
        printf "$output_format" "$label_color" "$label_text" "$RESET" "$message" >&2
    else
        # STDERR does not exist, probably writing into a file -> no escape codes

        # shellcheck disable=SC2059
        printf "$output_format" "" "$label_text" "" "$message" >&2
    fi
}

output() {
    if [ "$LOG_LEVEL" -lt "$LEVEL_INFO" ]
    then
        return
    fi

    OPTIND=1
    while getopts "l:" opt
    do
        case "$opt" in
            l) output_label="$OPTARG" ;;
            *) exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    coloredMessage -l "${output_label:-OUTPUT}" -c "$GREEN" "$*"
}

debug() {
    if [ "$LOG_LEVEL" -ge "$LEVEL_DEBUG" ]
    then
        coloredMessage -l "DEBUG" -c "$RESET" "$1"
    fi
}

log() {
    if [ "$LOG_LEVEL" -ge "$LEVEL_INFO" ]
    then
        coloredMessage -l "INFO" -c "$CYAN" "$1"
    fi
}

warning() {
    if [ "$LOG_LEVEL" -ge "$LEVEL_WARNING" ]
    then
        coloredMessage -l "WARNING" -c "$YELLOW" "$1"
    fi
}

error() {
    if [ "$LOG_LEVEL" -ge "$LEVEL_ERROR" ]
    then
        coloredMessage -l "ERROR" -c "$RED" "$1"
    fi
}

