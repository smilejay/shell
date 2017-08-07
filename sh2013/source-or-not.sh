#!/bin/bash
#if [ "$_" != "$0" ]; then
#	echo "the script is being sourced."
#else
#	echo "the script is running as a subshell."
#fi

echo '$_ = '"$_"
echo '$0 = '"$0"

echo '$BASH_SOURCE = '"$BASH_SOURCE"

echo "-------------------"
# this is better
if [ "${BASH_SOURCE[0]}" != "$0" ]; then
	echo "the script is being sourced."
else
	echo "the script is running as a subshell."
fi

