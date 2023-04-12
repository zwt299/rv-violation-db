#!/bin/bash

SCRIPT_USERNAME="mopuser"
TOOL_REPO="rv-violation-db"

# This script is the entry point script that is run inside of the Docker image
# for running the experiment for a single project

if [[ $1 == "" ]]; then
    echo "arg1 - violation id"
    exit
fi

VIO_ID=$1

script_to_run="/home/$SCRIPT_USERNAME/$TOOL_REPO/vio.sh ${VIO_ID}"

bash $script_to_run