#!/usr/bin/env sh

nowUnix() {
    date "+%s"
}

measureExecution() {
    start_time="$(nowUnix)"

    "$@"
    status="$?"

    end_time="$(nowUnix)"
    export duration="$((end_time - start_time))"

    return "$status"
}

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
