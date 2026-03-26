#!/usr/bin/env sh

# More info:
# https://en.wikipedia.org/wiki/ANSI_escape_code

CSI="\033["

if [ -t 2 ] && [ -z "${NO_COLOR:-}" ]
then
    mkCtrlSeq() { printf "%b%s" "$CSI" "$@"; }
else
    mkCtrlSeq() { :; }
fi

commandCode() {
    case "$1" in
        up) echo "A" ;;
        down) echo "B" ;;
        forward) echo "C" ;;
        back) echo "D" ;;
        next-line) echo "E" ;;
        prev-line) echo "F" ;;
        erase-display) echo "J" ;;
        erase-line) echo "K" ;;
        sgr) echo "m" ;;
        *) return 1 ;;
    esac
}

escape() {
    mkCtrlSeq "$2$(commandCode "$1")"
}

palette() {
    case "$1" in
        black) echo 0 ;;
        red) echo 1 ;;
        green) echo 2 ;;
        yellow) echo 3 ;;
        blue) echo 4 ;;
        magenta) echo 5 ;;
        cyan) echo 6 ;;
        white) echo 7 ;;
        *) return 1 ;;
    esac
}

color_mixer() {
    color_base="$1"
    color_code=$(palette "$2") || return 1
    escape "sgr" "$((color_base + color_code))"
}

fg() {
    color_mixer 30 "$1"
}

bg() {
    color_mixer 40 "$1"
}

fgBright() {
    color_mixer 90 "$1"
}

bgBright() {
    color_mixer 100 "$1"
}

reset() {
    escape "sgr" 0
}

bold() {
    escape "sgr" 1
}
