#!bin/bash
function usage() {
    cat <<USAGE
    Usage: $0 [violation-id]
USAGE
    exit 1
}

if [[ $1 == "" ]]; then
    usage
    exit 1
fi

VIO_ID=$1
docker build --no-cache -t violation-${VIO_ID}:latest --build-arg VIO_ID=$VIO_ID  -< javamopEnv
exit 0