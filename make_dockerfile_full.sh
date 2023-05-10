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
VALIDATE=$5
CACHED=$6
GIT_CACHE_BUST=$7

echo $CACHED 
echo $VALIDATE
echo $GIT_CACHE_BUST

if [[ $CACHED == "no" ]]; then 
    docker build --no-cache --build-arg GRANULARITY=$GRANULARITY --build-arg GRANULARITY_VALUE=$GRANULARITY_VALUE --build-arg NUM_RERUNS=$NUM_RERUNS --build-arg GIT_CACHE_BUST=$GIT_CACHE_BUST -t ${IMAGE_NAME} -< javamopEnvFull &> build_log.txt
    exit 0
fi

docker build --build-arg GRANULARITY=$GRANULARITY --build-arg GRANULARITY_VALUE=$GRANULARITY_VALUE --build-arg NUM_RERUNS=$NUM_RERUNS --build-arg GIT_CACHE_BUST=$GIT_CACHE_BUST -t ${IMAGE_NAME} -< javamopEnvFull &> build_log.txt
exit 0