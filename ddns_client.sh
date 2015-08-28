#!/bin/sh

#
# run this script with "show" as an argument to get the ID.  Use the ID as an entry 
#  into the ddns table.
#

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;export PATH

DEV='eth0'
MYNAME=`hostname`
MYID=`ifconfig $DEV | grep HWaddr | awk '{ print $NF}' | sed 's/://g'`

URLPATH=`echo "myname=$MYNAME&myid=$MYID" | sha256sum`

URL="https://example.com/ddns/$URLPATH"

if [ "$1" = "show" ]; then
  echo "
  myname: $MYNAME
  myid:   $MYID
  URL:    $URLPATH
"
else
  curl "$URL"
fi
