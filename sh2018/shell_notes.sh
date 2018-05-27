#!/bin/bash

# check a variable is set or not
# ${var+x} is a parameter expansion which evaluates to nothing if var is unset,
# and substitutes the string x otherwise.
if [ -z ${var+x} ]; then
    echo "var is unset"
else
    echo "var is set to '$var'"
fi


# check a variable is set and the file exists
var='shell_notes.sh'
if [ ! -z "$var" ] && [ -e "$var" ]; then
    echo "var='$var' file exists."
fi


