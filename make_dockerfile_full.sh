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

GRANULARITY=$1
GRANULARITY_VALUE=$2
NUM_RERUNS=$3
IMAGE_NAME=$4
CACHED=$5
VALIDATE=$6

echo $CACHED 
echo $VALIDATE

if [[ $CACHED == "no" ]]; then 
    docker build --no-cache --build-arg GRANULARITY=$GRANULARITY --build-arg GRANULARITY_VALUE=$GRANULARITY_VALUE --build-arg NUM_RERUNS=$NUM_RERUNS --build-arg VALIDATE=$VALIDATE -t ${IMAGE_NAME} -< javamopEnvFull 
    exit 0
fi

docker build --build-arg GRANULARITY=$GRANULARITY --build-arg GRANULARITY_VALUE=$GRANULARITY_VALUE --build-arg NUM_RERUNS=$NUM_RERUNS --build-arg VALIDATE=$VALIDATE -t ${IMAGE_NAME} -< javamopEnvFull 
exit 0