#!/usr/bin/env sh

set -eu

. "$(dirname "$0")/lib/color.sh"

LEVEL_SILENT=0
LEVEL_ERROR=1
LEVEL_WARNING=2
LEVEL_INFO=3
LEVEL_DEBUG=4

LOG_LEVEL="${LOG_LEVEL:-$LEVEL_INFO}"

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

    printf "%b%-8s%b: %s\n" "$label_color" "$label_text" "$(reset)" "$message" >&2
}

debug() {
    printMessage -l "DEBUG" -c "$(reset)" -v "$LEVEL_DEBUG" "$1"
}

log() {
    printMessage -l "INFO" -c "$(fg cyan)" -v "$LEVEL_INFO" "$1"
}

warning() {
    printMessage -l "WARNING" -c "$(fg yellow)" -v "$LEVEL_WARNING" "$1"
}

error() {
    printMessage -l "ERROR" -c "$(fg red)" -v "$LEVEL_ERROR" "$1"
}

printFile() {
    printer_function=$1
    filename=$2

    while IFS= read -r line
    do
        "$printer_function" "$line"
    done < "$filename"
}
