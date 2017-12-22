#!/bin/bash

trap '>&2 echo Error on line $LINENO' ERR

if [ $# -ne 3 ]; then
    echo usage: $0 env client email
    exit 1
fi

__DIR__=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

env=$1
client=$2
email=$3

dir=$__DIR__/$env
vars=$dir/clients/vars

cd $dir/clients
touch clients.txt
if grep -q $client clients.txt; then
    echo "$client already added"
    exit 1
fi

sed -e "s#@EMAIL@#$email#" $vars.i >$vars
echo $client $email >>clients.txt

export EASYRSA=$(pwd)
[[ ! -f pki/private/$client.key ]] && easyrsa gen-req $client nopass

cd $dir/ca
export EASYRSA=$(pwd)
[[ ! -f pki/reqs/$client.req ]] && easyrsa import-req $dir/clients/pki/reqs/$client.req $client
[[ ! -f pki/issued/$client.crt ]] && easyrsa sign-req client $client
