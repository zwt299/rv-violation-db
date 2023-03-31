#!/bin/bash

if [[ $1 == "" ]]; then
    echo "arg1 - vio-id"
    exit
fi

VIO_ID=$1

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


image=violation-${VIO_ID}:latest
docker run -t --rm -v ${SCRIPT_DIR}:/Scratch ${image} /bin/bash -x /Scratch/run_entrypoint.sh ${VIO_ID} &> log.txt