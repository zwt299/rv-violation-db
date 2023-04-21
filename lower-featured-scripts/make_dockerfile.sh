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

if [[ $2 == "no-cache" ]]; then
    docker build --no-cache --build-arg VIO_ID=$VIO_ID -t violation-${VIO_ID}:latest -< javamopEnv &> build_log
fi

docker build --build-arg VIO_ID=$VIO_ID -t violation-${VIO_ID}:latest -< javamopEnv > docker_build_log.txt &> build_log
exit 0