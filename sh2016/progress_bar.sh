#!/bin/bash
#origin: https://github.com/pjiranek/progress-bar/blob/master/progress-bar

# Default options.
max=100
width=30
bar_char="#"
new_line=0
hide_cur=0
clear_line=1
title=

# Help function.
usage()
{
    cat << END_HELP
Usage: $(basename $0) [options]

Options:
    -h              Print this help.
    -t title        Set the title.
    -m n            Set the maximal progress value (default 100).
    -w n            Set the width of the progress-bar (default 30).
    -b c            Set the progress-bar character (default #).
    -n              Put the new line at the end of the output.
    -c              Do not clear line at the end of the output.
    -i              Hide the cursor.

The script reads percentage values between 0 and the maximal value set by the
option -m and draws a pretty progress bar :-)

Example:

    for i in \$(seq 0 10); do
        echo \$i
        sleep 1
    done | $(basename $0) -m 10 -w 40 -b "=" -i -t "Example "

END_HELP
    exit 0
}

# Get the options.
while getopts "m:w:b:nit:ch" opt; do
    case "$opt" in
        m) max="${OPTARG}" ;;
        w) width="${OPTARG}" ;;
        b) bar_char="${OPTARG}" ;;
        n) new_line=1 ;;
        i) hide_cur=1 ;;
        t) title="${OPTARG}" ;;
        c) clear_line=0 ;;
        h|*) usage ;;
    esac
done

shift $((OPTIND-1))

if [ $# -ne 0 ]; then
    echo "Unknown arguments: $@" 1>&2
    usage
    exit 1
fi

# The output should be a terminal.
if [ ! -t 1 ]; then
    echo "Output is not a terminal" 1>&2
    exit 1
fi

# Hide the cursor
if [ $hide_cur -eq 1 ]; then
    tput civis
    trap 'tput cnorm; exit 1' SIGINT
fi

# Read the input and print thep progress-bar.
while read value; do
    # Compute the percentage.
    perc=$(( value * 100 / max ))
    # Compute the number of blocks to represent the percentage.
    num=$(( value * width / max ))
    # Create the progress bar string.
    bar=
    if [ $num -gt 0 ]; then
        bar=$(printf "%0.s${bar_char}" $(seq 1 $num))
    fi
    # Print the progress bar.
    line=$(printf "%s [%-${width}s] (%d%%)" "$title" "$bar" "$perc")
    echo -en "${line}\r"
done

# Clear the line if requested.
if [ $clear_line -eq 1 ]; then
    len=$(echo -en "$line" | wc -c)
    printf "%$((len + 1))s\r" " "
fi

# Put the new line if requested.
if [ $new_line -eq 1 ]; then
    echo
fi

# Show the cursor again.
if [ $hide_cur -eq 1 ]; then
    tput cnorm
fi
