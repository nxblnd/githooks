#!/usr/bin/env sh

nowUnix() {
    date "+%s"
}
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
    total_seconds="$1"

    minutes="$((total_seconds / 60))"
    seconds="$((total_seconds % 60))"

    if [ "$minutes" -ne 0 ]
    then
        printf "%dm %ds\n" "$minutes" "$seconds"
    else
        printf "%ds\n" "$seconds"
    fi
}
