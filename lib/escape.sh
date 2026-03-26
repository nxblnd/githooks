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

escape() {
    case "$1" in
        up) command_code="A" ;;
        down) command_code="B" ;;
        forward) command_code="C" ;;
        back) command_code="D" ;;
        next-line) command_code="E" ;;
        prev-line) command_code="F" ;;
        erase-display) command_code="J" ;;
        erase-line) command_code="K" ;;
        sgr) command_code="m" ;;
        *) return 1 ;;
    esac

    mkCtrlSeq "$2$command_code"
}

color_mixer() {
    case "$2" in
        black) color_code=0 ;;
        red) color_code=1 ;;
        green) color_code=2 ;;
        yellow) color_code=3 ;;
        blue) color_code=4 ;;
        magenta) color_code=5 ;;
        cyan) color_code=6 ;;
        white) color_code=7 ;;
        *) return 1 ;;
    esac

    color_base="$1"
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
