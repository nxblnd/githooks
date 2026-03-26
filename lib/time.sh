#!/usr/bin/env sh

if date "+%s%3N" >/dev/null 2>&1
then
    millisec="true"
    nowUnix() { date "+%s%3N"; }
else
    nowUnix() { date "+%s"; }
fi

measureExecution() (
    while getopts "o:e:" opt
    do
        case "$opt" in
            o) out="$OPTARG" ;;
            e) err="$OPTARG" ;;
            *) exit ;;
        esac
    done
    shift $((OPTIND - 1))

    out=$(realpath "${out:-/dev/stdout}")
    err=$(realpath "${err:-/dev/stderr}")

    start_time="$(nowUnix)"

    if [ "$out" = "$err" ]
    then
        "$@" >"$out" 2>&1
    else
        "$@" >"$out" 2>"$err"
    fi
    status="$?"

    end_time="$(nowUnix)"

    echo "$((end_time - start_time))"
    return "$status"
)

fmtTime() {
    total_time="$1"

    if [ -n "${millisec:-}" ]
    then
        total_seconds="$((total_time / 1000))"
    else
        total_seconds="$total_time"
    fi

    minutes="$((total_seconds / 60))"
    seconds="$((total_seconds % 60))"

    if [ -n "${millisec:-}" ]
    then
        seconds="$seconds.$((total_time % 1000))"
    fi

    if [ "$minutes" -ne 0 ]
    then
        printf "%sm %ss\n" "$minutes" "$seconds"
    else
        printf "%ss\n" "$seconds"
    fi
}
