#!/bin/bash

set -e

trap '>&2 echo Error on line $LINENO' ERR

if [ $# -ne 1 ]; then
    echo usage: $0 dir
    exit 1
fi

__DIR__=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

dir=$1
clients_txt=$dir/clients.txt

if [ ! -f $clients_txt ]; then
    echo "$clients_txt not found"
    exit 1
fi

gen_client_key() {
    echo $client
    vars=$dir/clients/vars

    cd $dir/clients
    sed -e "s#@EMAIL@#$email#" $vars.i >$vars
    pwd

    export EASYRSA=$(pwd)
    priv_key=$dir/clients/pki/private/$client.key
    [[ ! -f $priv_key ]] && easyrsa gen-req $client nopass || echo "$priv_key exists"

    cd $dir/ca
    export EASYRSA=$(pwd)
    clt_req=$dir/ca/pki/reqs/$client.req
    [[ ! -f $clt_req ]] && easyrsa import-req $dir/clients/pki/reqs/$client.req $client || echo "$clt_req exists"
    clt_crt=$dir/ca/pki/issued/$client.crt
    [[ ! -f $clt_crt ]] && easyrsa sign-req client $client || echo "$clt_crt exists"
}

while read -u 3 -r line; do
    read -r client email servers <<<$line
    gen_client_key
done 3< <(grep -v '^\s*#' $clients_txt)
