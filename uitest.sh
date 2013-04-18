#!/bin/bash

set -e
PATH=$PATH:.

(

    echo "Cleaning up..."
    rm -rf pass
    rm -rf group
    rm -rf user
    rm passfile
    echo "Done."
    
    echo "Bootstrapping..."
    mkdir user
    mkdir group
    mkdir pass
    
    . cryptapi.sh
    
    token=$(make-token) || exit $?
    encrypt user/admin adminpass $token || exit $?
    admintoken=$(validate-user admin adminpass) || exit $?
    [ $token = $admintoken ] || exit $?
    echo "Done."
	
)

make-token 2>/dev/null && echo "API functions still available, bailing." && exit 1

# temp file for automation
echo adminpass > passfile

echo "Adding user"
passman add user u1 < passfile
passman list user

echo "Adding group"
passman add group g1 < passfile
passman list group

echo "Adding password"
passman add pass p1 pass1 < passfile
passman list pass

echo "Mapping relations"
passman manage group g1 +p1 < passfile
passman manage user u1 +g1 < passfile
passman info user u1
passman info group g1
passman info pass p1

echo "Promoting u1"
passman promote u1 < passfile