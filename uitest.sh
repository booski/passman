#!/bin/bash

echo "This test is outdated and does not work."
exit 1

set -e
PATH=$PATH:.

UNUM=5
GNUM=3
PNUM=5

AFILE=passfile
UFILE=upass

(

    echo "Cleaning up..."
    set +e
    rm -rf pass
    rm -rf group
    rm -rf user
    rm $AFILE
    rm $UFILE
    set -e
    echo "Done."
    
    echo "Bootstrapping..."
    . cryptapi.sh
    bootstrap ua uapass
    echo "Done."
    
)

make-token 2>/dev/null && echo "API functions still available, bailing." && exit 1

# temp file for automation
echo -e "ua\nuapass" > $AFILE

echo "Testing garbage input"
passman manage t || true

echo "Adding users"
for i in $(seq $UNUM)
do
    passman add user u$i "u${i}pass" < $AFILE
done
passman list user

echo "Adding groups"
for i in $(seq $GNUM)
do
    passman add group g$i < $AFILE
done
passman list group

echo "Adding passwords"
for i in $(seq $PNUM)
do
    passman add pass p$i pass${i}val < $AFILE
done
passman list pass

echo "Mapping groups to paswords"
passman manage group g1 +p1 < $AFILE
passman manage group g1 +p2 < $AFILE
passman manage group g1 +p3 < $AFILE

passman manage group g2 +p3 < $AFILE
passman manage group g2 +p4 < $AFILE
passman manage group g2 +p5 < $AFILE

passman manage group g3 +p2 < $AFILE
passman manage group g3 +p3 < $AFILE

for i in $(seq $GNUM)
do
    passman info group g$i
done

for i in $(seq $PNUM)
do
    passman info pass p$i
done

echo "Mapping users to groups"
passman manage user u1 +g1 < $AFILE
passman manage user u1 +g2 < $AFILE

passman manage user u2 +g2 < $AFILE

passman manage user u3 +g1 < $AFILE
passman manage user u3 +g3 < $AFILE

passman manage user u4 +g3 < $AFILE

for i in $(seq $GNUM)
do
    passman info group g$i
done

for i in $(seq $UNUM)
do
    passman info user u$i
done

echo "Promoting u5"
passman promote u5 < $AFILE
passman info user u5

echo "Starting to authenticate as admin.u5"
echo -e "u5\nu5pass" > $AFILE

echo "Demoting ua"
passman demote ua < $AFILE

passman info user ua

echo "Testing u4"
passman info user u4

echo "u4pass" > $UFILE
passman -u u4 get p2 < $UFILE

echo "get pass 4"
passman -u u4 get p4 < $UFILE

echo "Deleting u4"
passman del user u4 < $AFILE

echo "Listing users"
passman list user

echo "Testing password change"
echo -e "u2\nu2pass\ntestpass\ntestpss" > $UFILE
passman passwd < $UFILE || true

echo -e "u2\nu2pass\ntestpass\ntestpass" > $UFILE
passman passwd < $UFILE

echo -e "u2\ntestpass" > $UFILE
passman info user u2

passman get p2 < $UFILE
passman get p3 < $UFILE
