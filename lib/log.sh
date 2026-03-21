#!/usr/bin/env sh

set -eu

. "$(dirname "$0")/lib/color.sh"

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
            l) label_text="$OPTARG" ;;
            *) exit 1;;
        esac
    done
    shift $((OPTIND - 1))

    label_color=${label_color:-$RESET}
    message="$*"

    printf "%b%-8s%b: %s\n" "$label_color" "$label_text" "$(reset)" "$message" >&2
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

    coloredMessage -l "${output_label:-OUTPUT}" -c "$(fg green)" "$*"
}

debug() {
    if [ "$LOG_LEVEL" -ge "$LEVEL_DEBUG" ]
    then
        coloredMessage -l "DEBUG" -c "$(reset)" "$1"
    fi
}

log() {
    if [ "$LOG_LEVEL" -ge "$LEVEL_INFO" ]
    then
        coloredMessage -l "INFO" -c "$(fg cyan)" "$1"
    fi
}

warning() {
    if [ "$LOG_LEVEL" -ge "$LEVEL_WARNING" ]
    then
        coloredMessage -l "WARNING" -c "$(fg yellow)" "$1"
    fi
}

error() {
    if [ "$LOG_LEVEL" -ge "$LEVEL_ERROR" ]
    then
        coloredMessage -l "ERROR" -c "$(fg red)" "$1"
    fi
}

