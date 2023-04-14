#!bin/bash
function usage() {
    cat <<USAGE
    Usage: $0 name
USAGE
    exit 1
}

if [[ $1 == "" ]]; then
    usage
    exit 1
fi

NAME=$1
docker build --no-cache -t ${NAME} -< javamopEnv # may need to add --no-cache if you dont want to cache image
exit 0