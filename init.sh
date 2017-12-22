#!/bin/bash

trap '>&2 echo Error on line $LINENO' ERR

if [ $# -ne 1 ]; then
    echo "usage: $0 env"
    exit 1
fi

__DIR__=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
__TMPLS__=$__DIR__/templates

env=$1
dir=$__DIR__/$env

links="openssl-1.0.cnf x509-types"

mkdir -p $dir/ca $dir/servers/secrets $dir/clients/secrets

for entity in ca servers clients; do
    cd $dir/$entity
    if [[ ! -d pki/ ]]; then
        for p in $links; do
            if [[ ! -e $p ]]; then
                ln -s ../../templates/$p
            fi
        done
        cp -r $__TMPLS__/$entity/* .
        export EASYRSA=$(pwd)
        easyrsa init-pki
        if [[ $entity == ca ]]; then
            echo hi
            easyrsa --help
            easyrsa build-ca
        fi
    fi
done
