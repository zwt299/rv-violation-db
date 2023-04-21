
GRANULARITY="all"
GRANULARITY_VALUE=-1
NUM_RERUNS=10
CACHED="yes"

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