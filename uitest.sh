#!/bin/bash

set -e
export PATH=$PATH:.

(

    echo "Cleaning up..."
    rm -rf pass
    rm -rf group
    rm -rf user
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

echo "Adding user"
echo adminpass > passfile
passman add user u1 < passfile
passman list user

echo "Adding group"
passman add group g1 < passfile
passman list group

echo "Adding password"
passman add pass p1 pass1 < passfile
passman list pass