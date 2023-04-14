#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


while [ "$1" != "" ]; do
    case $1 in
    --repo-id)
        shift 
        NAME=repo-$1
        bash make_dockerfile_full.sh ${NAME}
        image=$NAME
        docker run -t --rm -v ${SCRIPT_DIR}:/Scratch ${image} /bin/bash -x /Scratch/run_entrypoint_full.sh &> log.txt
        exit 0
        ;;
    --violation-id)
        shift
        NAME=violation-$1
        bash make_dockerfile_full.sh ${NAME}
        image=$NAME
        docker run -t --rm -v ${SCRIPT_DIR}:/Scratch ${image} /bin/bash -x /Scratch/run_entrypoint_full.sh &> log.txt
        exit 0
        ;;
    --prop-file)
        shift
        NAME=prop-$1
        bash make_dockerfile_full.sh ${NAME}
        image=$NAME
        docker run -t --rm -v ${SCRIPT_DIR}:/Scratch ${image} /bin/bash -x /Scratch/run_entrypoint_full.sh &> log.txt
        exit 0
        ;;
    -h | --help)
        usage # run usage function
        ;;
    *)
        usage
        exit 1
        ;;
    esac
done

