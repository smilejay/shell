#!/bin/bash

# contains(string, substring)
#
# Returns 0 if the specified string contains the specified substring,
# otherwise returns 1.
contains() {
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}

contains "abcd" "e" || echo "abcd does not contain e"
contains "abcd" "ab" && echo "abcd contains ab"
contains "abcd" "bc" && echo "abcd contains bc"
contains "abcd" "cd" && echo "abcd contains cd"
contains "abcd" "abcd" && echo "abcd contains abcd"
contains "" "" && echo "empty string contains empty string"
contains "a" "" && echo "a contains empty string"
contains "" "a" || echo "empty string does not contain a"
contains "abcd efgh" "cd ef" && echo "abcd efgh contains cd ef"
contains "abcd efgh" " " && echo "abcd efgh contains a space"
