#!/bin/sh

#
# This is a Micky Mouse script to set up a DNS entry on Digital Ocean
#

DOMAIN=$1
NODE=$2
IP=$3

DOURL="https://api.digitalocean.com/v2/domains/$DOMAIN/records"
TOKEN='1234123412341231234123123412312341231234123123412312341234123412'

ARECORD="$NODE.$DOMAIN."

# Get list
RESULTS=`curl -X GET "$DOURL" -H "Authorization: Bearer $TOKEN"`

# Change json results into readable format
RESULTS2=`echo $RESULTS | sed 's/},{/\n/g' `

# Loop through each entry
for i in `echo $RESULTS2`; do 
  MYREC=`echo $i | grep \"$NODE\"`                  ### Matched node name
  if [ -n "$MYREC" ]; then
    MYREC2=`echo $MYREC | sed 's/,/\n/g' `
    for x in `echo $MYREC2`; do
echo "Processing: $x
"
      ID=`echo $x| grep 'id' `
      if [ -n "$ID" ] ; then
        MYID=`echo $ID|cut -d':' -f2 | sed 's/["|,]//g'`  ### ID
        echo "
RECORD ID:$MYID
        "
      fi
      DATA=`echo $x| grep 'data' `                  ### Get data field
      if [ -n "$DATA" ] ; then
        MYIP=`echo $DATA|cut -d':' -f2 | sed 's/["|,]//g'`  ### IP
        echo "
DNS IP:$MYIP NEW IP:$IP
        "
      fi
    done
  fi
done


### If there's an IP listed
if [ -n "$MYIP" ] ; then
  if [ "$MYIP" != "$IP" ] ; then

    echo "
Got a new IP: $IP
Need to change record $MYID

    "

    echo "
curl -X DELETE -H 'Content-Type: application/json' -H \"Authorization: Bearer $TOKEN\" \"$DOURL/$MYID\"
    "

    curl -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "$DOURL/$MYID"

    echo " 
Deleted Record
"

  elif [ "$MYIP" == "$IP" ] ; then

    echo "
Same IP.  Nothing to do.
    "
    exit

  fi

fi

#
# No IP exists. So, add it
#

DATA="{\"type\":\"A\",\"name\":\"$ARECORD\",\"data\":\"$IP\"}"

echo "
  curl -X POST -H 'Content-Type: application/json' -H \"Authorization: Bearer $TOKEN\" -d \"$DATA\" \"$DOURL\"
  "

curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$DATA" "$DOURL"

echo " 
Added New Record
"

exit;



