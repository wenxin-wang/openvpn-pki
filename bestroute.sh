#!/bin/bash

trap 'ERROR on $LINENO' ERR

__DIR__=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
. $__DIR__/common.sh

__INSTANCE__=$__DIR__/instance

mkdir -p $__INSTANCE__

package_json=$__INSTANCE__/package.json

if [ ! -f $package_json ]; then
    cd $__INSTANCE__
    npm init
    npm install bestroutetb
    cd - >/dev/null
fi

bestroutetb=$__INSTANCE__/node_modules/.bin/bestroutetb

$bestroutetb --default-gateway=false -f -p openvpn -o $__INSTANCE__/bestroute.ovpn
