#!/bin/bash

TARBIN=`which tar`
USER=`whoami`
CREATEBACKUP=1
DIR=$PWD
CURLBIN=`which curl`

source ~/.PayDay/PayDay.conf

USER=$rpcuser
PASS=$rpcpassword

if [ "$CURLBIN" == "" ]; then
        echo "For script working need a curl binary"
        exit 0
fi

if [ "$TARBIN" == "" ]; then
	echo "For script working need a tar binary"
	exit 0
fi

pdd -debug -connect=a.paydaycoin.io:7214 -daemon -listen=0 -enableaccounts -staking=0 -createwalletbackups=100 2>&1

PRIVKEYS=`cat privkeys.log`

for data in $PRIVKEYS
do
#data=${privkeys[$ind]}
key=$(echo $data | awk -F: '{print $2}' | tr -d \")
value=$(echo $data | awk -F: '{print $1}' | tr -d \")
$CURLBIN -s --user $USER:$PASS http://127.0.0.1:7215 --data-binary "{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", \"method\": \"importprivkey\", \"params\": [\"$key\", \"$value\"] }" -H "content-type: text/plain" > /dev/null
done

# $CURLBIN -s --user $USER:$PASS http://127.0.0.1:7215 --data-binary "{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", \"method\": \"stop\", \"params\": [] }" -H "content-type: text/plain" > /dev/null

echo "Wait while PayDay Server downloading blocks and restart, then check balances and Received addresses"

exit 0
