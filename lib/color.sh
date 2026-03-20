#!/usr/bin/env sh

# More info:
# https://en.wikipedia.org/wiki/ANSI_escape_code

CSI="\033["

if [ -t 1 ] && [ -z "${NO_COLOR+nocolor}" ]
then
    sgr() { printf "%b%sm" "$CSI" "$1"; }
else
    sgr() { :; }
fi

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
    sgr $((color_base + color_code))
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
    sgr 0
}

bold() {
    sgr 1
}
