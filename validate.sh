#!/bin/bash

ENTRY_CSV=$1

# temp arg for testing
LINE_NUMBER=$2

NAME="validate"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

bash make_dockerfile.sh ${NAME}
image=violation-${NAME}:latest
docker run -t --rm -v ${SCRIPT_DIR}:/Scratch ${image} /bin/bash -x /Scratch/validate_entrypoint.sh ${ENTRY_CSV} ${LINE_NUMBER} &> validate_log.txt



