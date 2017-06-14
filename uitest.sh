#!/bin/bash

set -e

E_BADSTATE="1"

die() {
    reason=$1
    message=$2

    code=0
    case "$reason" in
	"$E_BADSTATE" )
	    echo "This test is only intended to run against a 'clean' install of passman."
	    echo -n "The problem is: "
	    echo "$message"
	    code=1
	    ;;
    esac
    exit "$code"
}

for item in user group pass
do
    count=0
    for entry in $(passman list "$item")
    do
	if [ -n "$entry" ]
	then
	    count=$((count+1))
	fi
    done
    
    if [ "$item" = pass ] && ! [ "$count" = 0 ]
    then
	die "$E_BADSTATE" "The database contains a password already."
    elif ! [ "$count" -gt 1 ]
    then
	die "$E_BADSTATE" "There is more than one $item in the database."
    fi
done
