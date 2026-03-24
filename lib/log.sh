#!/usr/bin/env sh

set -eu

. "$(dirname "$0")/lib/color.sh"

# shellcheck disable=SC2034  # LEVEL_SILENT exists for possible future needs
LEVEL_SILENT=0
LEVEL_ERROR=1
LEVEL_WARNING=2
LEVEL_INFO=3
LEVEL_DEBUG=4

RESET=$(reset)

printMessage() {
    OPTIND=1
    while getopts "c:l:v:" opt
    do
        case "$opt" in
            c) label_color="$OPTARG" ;;
            l) label_text="$OPTARG" ;;
            v) verbosity_level="$OPTARG" ;;
            *) exit 1;;
        esac
    done
    shift $((OPTIND - 1))

    [ "$LOG_LEVEL" -lt "$verbosity_level" ] && return 0

    label_color=${label_color:-$RESET}
    message="$*"

    printf "%b%-8s%b: %s\n" "$label_color" "$label_text" "$RESET" "$message" >&2
}

DEBUG_COLOR="$RESET"
debug() {
    printMessage -l "DEBUG" -c "$DEBUG_COLOR" -v "$LEVEL_DEBUG" "$@"
}

LOG_COLOR="$(fg cyan)"
log() {
    printMessage -l "INFO" -c "$LOG_COLOR" -v "$LEVEL_INFO" "$@"
}

WARNING_COLOR="$(fg yellow)"
warning() {
    printMessage -l "WARNING" -c "$WARNING_COLOR" -v "$LEVEL_WARNING" "$@"
}

ERROR_COLOR="$(fg red)"
error() {
    printMessage -l "ERROR" -c "$ERROR_COLOR" -v "$LEVEL_ERROR" "$@"
}

printFile() {
    printer_function=$1
    filename=$2

    while IFS= read -r line
    do
        "$printer_function" "$line"
    done < "$filename"
}
