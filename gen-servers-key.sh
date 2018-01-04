#!/bin/bash

set -e

trap '>&2 echo Error on line $LINENO' ERR

if [ $# -ne 1 ]; then
    echo usage: $0 dir
    exit 1
fi

__DIR__=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

dir=$1
servers_txt=$dir/servers.txt

if [ ! -f $servers_txt ]; then
    echo "$servers_txt not found"
    exit 1
fi

gen_server_key() {
    echo $server
    vars=$dir/servers/vars

    cd $dir/servers
    sed -e "s#@EMAIL@#$email#" $vars.i >$vars

    export EASYRSA=$(pwd)
    local priv_key=$dir/servers/pki/private/$server.key
    [[ ! -f $priv_key ]] && easyrsa gen-req $server nopass || echo "$priv_key exists"

    dh=$dir/servers/secrets/$server-dh.pem
    ta=$dir/servers/secrets/$server-ta.key

    [[ ! -f $dh ]] && openssl dhparam -out $dh 2048 || echo "$dh exists"
    [[ ! -f $ta ]] && openvpn --genkey --secret $ta || echo "$ta exists"

    cd $dir/ca
    export EASYRSA=$(pwd)
    local srv_req=$dir/ca/pki/reqs/$server.req
    [[ ! -f $srv_req ]] && easyrsa import-req $dir/servers/pki/reqs/$server.req $server || echo "$srv_req exists"
    local srv_crt=$dir/ca/pki/issued/$server.crt
    [[ ! -f $srv_crt ]] && easyrsa sign-req server $server || echo "$srv_crt exists"
}

while read -u 3 -r line; do
    read -r server email address port <<<$line
    gen_server_key
done 3< <(grep -v '^\s*#' $servers_txt)
