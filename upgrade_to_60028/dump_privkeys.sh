#!/bin/bash

TARBIN=`which tar`
USER=`whoami`
CREATEBACKUP=1
DIR=$PWD
CURLBIN=`which curl`

source ~/.PayDay/PayDay.conf
echo "" > privkeys.log

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

pdd -debug -connect=a.paydaycoin.io -daemon -listen=0 -rpcuser=$USER -rpcpassword=$PASS -enableaccounts -staking=0 -createwalletbackups=100 2>&1

sleep 30

KEYS=`$CURLBIN -s --user $USER:$PASS http://127.0.0.1:7215 --data-binary "{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", \"method\": \"listaccounts\", \"params\": [] }" -H "content-type: text/plain" | grep -o "\"[a-zA-Z0-9[:space:]]*\":[0-9\.]*" | tr -d \"`

var1=1
IFS=$'\n'
for pair in $KEYS
do
key=$(echo $pair | awk -F: '{print $1}')
[ "$key" == "error" ] || [ "$key" == "result" ] || [ "$key" == "id" ] || {

addr=`$CURLBIN -s --user $USER:$PASS http://127.0.0.1:7215 --data-binary "{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", \"method\": \"getaddressesbyaccount\", \"params\": [\"$key\"] }" -H "content-type: text/plain" | grep -o "M[a-zA-Z0-9]*"`
for ad in $addr
do
if [ -n "$ad" ]; then
priv=`$CURLBIN -s --user $USER:$PASS http://127.0.0.1:7215 --data-binary "{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", \"method\": \"dumpprivkey\", \"params\": [\"$ad\"] }" -H "content-type: text/plain" | grep -o "D[a-zA-Z0-9]*"`
privkeys[$var1]="\"$key\":\"$priv\""
echo "\"$key\":\"$priv\"" >> privkeys.log
var1=$(( $var1 + 1 ))
fi
done
}
done
pdd stop
echo "Keys Dumped, PayDay Server Shutdown."
exit 0
