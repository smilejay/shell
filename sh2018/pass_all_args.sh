#!/bin/bash
# show the difference of $@ and $*
# test via: sh test.sh 1 '2 3' 4

# $@ behaves like $* except that when quoted the arguments are broken up
# properly if there are spaces in them.

# When they are not quoted, $* and $@ are the same.
# You shouldn't use either of these, because they can break unexpectedly as soon
# as you have arguments containing spaces or wildcards.
# "$*" expands to a single word "$1c$2c...". Usually c is a space, but it's
# actually the first character of IFS, so it can be anything you choose.
# "$@" expands to separate words: "$1" "$2" ...
# This is almost always what you want.


# test $@
echo '-------------testing $@ ------------'
for var in "$@"
do
    echo "$var"
done


# test $*
echo '-------------testing $* ------------'
for var in $*
do
    echo "$var"
done
