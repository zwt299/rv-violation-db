#!bin/bash
function usage() {
    cat <<USAGE
    Usage: $0 --violation-id [id]

    Options:
        --repo-id [id]:            find all violations of a given repo ID [id]
        --violation-id [id]:       find a given violation ID [id]
        --prop-file [prop-file]:   find all violations for a given prop-file

USAGE
    exit 1
}

while [ "$1" != "" ]; do
    case $1 in
    --violation-id)
        shift 
        VIO_ID=$1
        docker build --no-cache -t violation-$VIO_ID:latest --build-arg VIO_ID=$VIO_ID  -< javamopEnv
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
    esac
done