#!/usr/bin/env sh

set -eu

. "$(dirname "$0")/lib/escape.sh"

# shellcheck disable=SC2034  # LEVEL_SILENT exists for possible future needs
LEVEL_SILENT=0
LEVEL_ERROR=10
LEVEL_WARNING=20
LEVEL_INFO=30
LEVEL_DEBUG=40

LOG_LEVEL=${LOG_LEVEL:-$LEVEL_INFO}

RESET=$(reset)
ERROR_COLOR="$(fg red)"
WARNING_COLOR="$(fg yellow)"
LOG_COLOR="$(fg cyan)"
DEBUG_COLOR="$RESET"

parseLogLevel() {
    IFS= read -r target_level

    if echo "$target_level" | grep -Eq '^[0-9]+$'
    then
        echo "$target_level"
        return
    fi

    target_level=$(echo "$target_level" | tr '[:upper:]' '[:lower:]')

    case "$target_level" in
        silent) echo "$LEVEL_SILENT" ;;
        error) echo "$LEVEL_ERROR" ;;
        warning) echo "$LEVEL_WARNING" ;;
        info) echo "$LEVEL_INFO" ;;
        debug) echo "$LEVEL_DEBUG" ;;
        *)  echo "$LEVEL_INFO"
            LOG_LEVEL="$LEVEL_INFO"
            printMessage -c "$WARNING_COLOR" -l "WARNING" "Can't parse LOG_LEVEL (not a positive integer, not valid string)"
            printMessage -c "$WARNING_COLOR" -l "WARNING" "Will use INFO level"
            ;;
    esac
}

printMessage() (
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

    label_color=${label_color:-$RESET}
    label_text=${label_text:-"Message"}
    verbosity_level=${verbosity_level:-$LEVEL_INFO}
    message="$*"

    [ "$LOG_LEVEL" -lt "$verbosity_level" ] && return 0

    printf "%b%-8s%b: %s\n" "$label_color" "$label_text" "$RESET" "$message" >&2
)

debug() {
    printMessage -l "DEBUG" -c "$DEBUG_COLOR" -v "$LEVEL_DEBUG" "$@"
}

log() {
    printMessage -l "INFO" -c "$LOG_COLOR" -v "$LEVEL_INFO" "$@"
}

warning() {
    printMessage -l "WARNING" -c "$WARNING_COLOR" -v "$LEVEL_WARNING" "$@"
}

error() {
    printMessage -l "ERROR" -c "$ERROR_COLOR" -v "$LEVEL_ERROR" "$@"
}

printFile() {
    printer_function=$1
    filename=$2

    while IFS= read -r line || [ -n "$line" ]
    do
        "$printer_function" "$line"
    done < "$filename"
}
