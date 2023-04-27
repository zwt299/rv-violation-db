#!/bin/bash

function usage() {
    cat <<USAGE
    Usage: $0 name
USAGE
    exit 1
}


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

GRANULARITY="all"
GRANULARITY_VALUE=-1
NUM_RERUNS=10
CACHED="yes"
VALIDATE="no"

while [ "$1" != "" ]; do
    case $1 in
    --repo-slug)
        shift
        GRANULARITY="repo-slug"
        GRANULARITY_VALUE=$1
        ;;
    --violation-id)
        shift
        if ! [[ $1 =~ $re ]] ; then
            echo "Error: violation-id not a number" >&2; exit 1
        fi
        GRANULARITY="violation-id"
        GRANULARITY_VALUE=$1
        ;;
    --prop-file)
        shift
        GRANULARITY="prop-file"
        GRANULARITY_VALUE=$1
        ;;
    --all)
        GRANULARITY="all"
        GRANULARITY_VALUE=-1
        ;;
    --num-reruns)
        shift
        re='^[0-9]+$'
        if ! [[ $1 =~ $re ]] ; then
            echo "Error: num-reruns not a number" >&2; exit 1
        fi
        NUM_RERUNS=$1
        ;;
    --image-name)
        shift
        IMAGE_NAME=$1
        ;;
    --no-cache)
        CACHED="no"
        ;;
    --validate)
        VALIDATE="yes"
        ;;
    --usage)
        usage
        exit 1
        ;;
    esac
    shift
done


if [[ $IMAGE_NAME == "" ]]; then
    IMAGE_NAME=$GRANULARITY-$GRANULARITY_VALUE

    if [ $GRANULARITY == "all" ]; then
        IMAGE_NAME="all-violations"
    fi
fi

echo $GRANULARITY
echo $GRANULARITY_VALUE
echo $NUM_RERUNS
echo $IMAGE_NAME

bash make_dockerfile_full.sh ${GRANULARITY} ${GRANULARITY_VALUE} ${NUM_RERUNS} ${IMAGE_NAME} ${CACHED} ${VALIDATE}

docker run -t -v ${SCRIPT_DIR}:/Scratch ${IMAGE_NAME} /bin/bash -x /Scratch/run_entrypoint_full.sh ${GRANULARITY} ${GRANULARITY_VALUE} ${NUM_RERUNS} ${VALIDATE} &> repro-log.txt
CONTAINER_ID=$(docker ps -a --filter "ancestor=$IMAGE_NAME" -q | head -1)
echo $CONTAINER_ID

docker start $CONTAINER_ID

CONTAINER_ROOT=$(docker exec $CONTAINER_ID pwd)

VIOLATIONS_DATA=$SCRIPT_DIR/violations-data

if ! [[ -d $VIOLATIONS_DATA ]]; then 
    mkdir $VIOLATIONS_DATA
fi

IMAGE_VIOLATIONS=$VIOLATIONS_DATA/$IMAGE_NAME
if ! [[ -d $IMAGE_VIOLATIONS ]]; then 
    mkdir $IMAGE_VIOLATIONS
fi
rm -rf $IMAGE_VIOLATIONS/*

docker cp "$CONTAINER_ID:$CONTAINER_ROOT/$VIOLATIONS_DATA/" "$SCRIPT_DIR/$VIOLATIONS_DATA/$IMAGE_NAME"
docker stop $CONTAINER_ID

exit 0

# while [ "$1" != "" ]; do
#     case $1 in
#     --repo-slug)
#         shift 
#         NAME=repo-$1
#         bash make_dockerfile_full.sh ${NAME}
#         image=$NAME
#         docker run -t --rm -v ${SCRIPT_DIR}:/Scratch ${image} /bin/bash -x /Scratch/run_entrypoint_full.sh &> log.txt
#         exit 0
#         ;;
#     --violation-id)
#         shift
#         NAME=violation-$1
#         bash make_dockerfile_full.sh ${NAME}
#         image=$NAME
#         docker run -t --rm -v ${SCRIPT_DIR}:/Scratch ${image} /bin/bash -x /Scratch/run_entrypoint_full.sh &> log.txt
#         exit 0
#         ;;
#     --prop-file)
#         shift
#         NAME=prop-$1
#         bash make_dockerfile_full.sh ${NAME}
#         image=$NAME
#         docker run -t --rm -v ${SCRIPT_DIR}:/Scratch ${image} /bin/bash -x /Scratch/run_entrypoint_full.sh &> log.txt
#         exit 0
#         ;;
#     --all)
#         shift
#         NAME=all
#         ;;

#     -h | --help)
#         usage # run usage function
#         ;;
#     *)
#         usage
#         exit 1
#         ;;
#     esac
# done

