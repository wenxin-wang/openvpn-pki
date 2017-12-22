undefined() {
    [ z"${!1}" == z ]
}

set_undefined() {
    printf -v "$1" "${!1:-$2}"
}

die() {
    local code=$1
    shift
    >&2 echo $@
    exit $code
}

exit_undefined_usage() {
    if undefined $1; then
        >&2 echo Environment variable $1 is needed
        >&2 echo
        usage
        exit 1
    fi
}

LOG() {
    echo '------' $@
}

_mkcd() {
    mkdir -p $1
    cd $1
}

_rmmkcd() {
    rm -rf $1
    mkdir -p $1
    cd $1
}