#!/bin/bash

set -e

trap '>&2 echo Error on line $LINENO' ERR

if [ $# -ne 3 ]; then
    echo usage: $0 dir server email
    exit 1
fi

__DIR__=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

dir=$1
server=$2
email=$3

vars=$dir/servers/vars

cd $dir/servers
sed -e "s#@EMAIL@#$email#" $vars.i >$vars

export EASYRSA=$(pwd)
[[ ! -f pki/private/$server.key ]] && easyrsa gen-req $server nopass

dh=$dir/servers/secrets/$server-dh.pem
ta=$dir/servers/secrets/$server-ta.key
[[ ! -f $dh ]] && openssl dhparam -out $dh 2048
[[ ! -f $ta ]] && openvpn --genkey --secret $ta

cd $dir/ca
export EASYRSA=$(pwd)
[[ ! -f pki/reqs/$server.req ]] && easyrsa import-req $dir/servers/pki/reqs/$server.req $server
[[ ! -f pki/issued/$server.crt ]] && easyrsa sign-req server $server
