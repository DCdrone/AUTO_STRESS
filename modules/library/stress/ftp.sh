#!/bin/sh
REMOTEHOST=$1
USERNAME=$2
PASSWORD=$3
ftp -i -n $REMOTEHOST << EOF
user $USERNAME $PASSWORD
put "|dd if=/dev/zero bs=64k" /dev/null
bye 
EOF
