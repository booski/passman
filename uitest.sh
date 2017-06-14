#!/bin/bash

echo "There are no working tests at this time."
exit 1

set -e

E_BADSTATE="1"
E_BADRESULT="2"

die() {
    reason=$1
    message=$2

    code=0
    case "$reason" in
	"$E_BADSTATE" )
	    echo "This test is only intended to run against a 'clean' install of passman."
	    code=1
	    ;;
	"$E_BADRESULT" )
	    echo "A command failed to give the expected result."
	    code=2
	    ;;
	* )
	    echo "An invalid error was reported. This should never happen."
	    echo "The invalid error was '$reason'."
	    code=99
    esac
    echo "$message"
    exit "$code"
}

for item in user group pass
do
    count=0
    for entry in $(passman list "$item")
    do
	count=$((count+1))
    done
    
    if [ "$item" = pass ] && ! [ "$count" = 0 ]
    then
	die "$E_BADSTATE" "The database contains a password already."
    elif [ "$count" -gt 1 ]
    then
	die "$E_BADSTATE" "There is more than one $item in the database."
    fi
done

# Put tests here
