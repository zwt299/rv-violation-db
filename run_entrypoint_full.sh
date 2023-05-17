#!/bin/bash

SCRIPT_USERNAME="mopuser"
TOOL_REPO="rv-violation-db"
GRANULARITY=$1
GRANULARITY_VALUE=$2
NUM_RERUNS=$3
VALIDATE=$4

VALIDATION_FLAG=""
if [[ "$VALIDATE" = "yes" ]]; then 
    VALIDATION_FLAG="--validate"
fi

mkdir ~/violations-data/
function execute_script() {
    source ~/.bashrc && cp /home/mopuser/rv-violation-db/extension/target/mop-extension-1.0-SNAPSHOT.jar ~/apache-maven/lib/ext
    cp -r /home/mopuser/rv-violation-db/custom-specifications/* /home/mopuser/javamop-agent-bundle/props/
    bash $script_to_run
}

if [[ $GRANULARITY == "repo-slug" ]]; then
    script_to_run="/home/$SCRIPT_USERNAME/$TOOL_REPO/vio_full.sh --repo-slug $GRANULARITY_VALUE --num-reruns $NUM_RERUNS $VALIDATION_FLAG"
    execute_script
    exit 0
fi

if [[ $GRANULARITY == "violation-id" ]]; then
    script_to_run="/home/$SCRIPT_USERNAME/$TOOL_REPO/vio_full.sh --violation-id $GRANULARITY_VALUE --num-reruns $NUM_RERUNS $VALIDATION_FLAG"
    execute_script
    exit 0
fi

if [[ $GRANULARITY == "prop-file" ]]; then
    script_to_run="/home/$SCRIPT_USERNAME/$TOOL_REPO/vio_full.sh --prop-file $GRANULARITY_VALUE --num-reruns $NUM_RERUNS $VALIDATION_FLAG"
    execute_script
    exit 0
fi

if [[ $GRANULARITY == "all" ]]; then
    script_to_run="/home/$SCRIPT_USERNAME/$TOOL_REPO/vio_full.sh --all --num-reruns $NUM_RERUNS $VALIDATION_FLAG"
    execute_script
    exit 0
fi