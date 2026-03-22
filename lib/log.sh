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

debug() {
    [ "$LOG_LEVEL" -lt "$LEVEL_DEBUG" ] && return 0
    coloredMessage -l "DEBUG" -c "$(reset)" "$1"
}

log() {
    [ "$LOG_LEVEL" -lt "$LEVEL_INFO" ] && return 0
    coloredMessage -l "INFO" -c "$(fg cyan)" "$1"
}

warning() {
    [ "$LOG_LEVEL" -lt "$LEVEL_WARNING" ] && return 0
    coloredMessage -l "WARNING" -c "$(fg yellow)" "$1"
}

error() {
    [ "$LOG_LEVEL" -lt "$LEVEL_ERROR" ] && return 0
    coloredMessage -l "ERROR" -c "$(fg red)" "$1"
}

printFile() {
    printer_function=$1
    filename=$2

    while IFS= read -r line
    do
        "$printer_function" "$line"
    done < "$filename"
}
