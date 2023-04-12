#!/bin/bash

if [[ $1 == "" ]]; then
    echo "arg1 - vio-id"
    exit
fi


source ~/.bashrc && cp /home/mopuser/rv-violation-db/extension/target/mop-extension-1.0-SNAPSHOT.jar ~/apache-maven/lib/ext

VIO_ID=$1

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# bash make_dockerfile.sh ${VIO_ID}
image=violation-${VIO_ID}:latest
docker run -t --rm -v ${SCRIPT_DIR}:/Scratch ${image} /bin/bash -x /Scratch/run_entrypoint.sh ${VIO_ID} &> log.txt