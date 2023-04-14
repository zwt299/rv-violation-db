#!/bin/bash

SCRIPT_USERNAME="mopuser"
TOOL_REPO="rv-violation-db"

function usage() {
    cat <<USAGE
    Usage: $0 --repo-id [id] | --violation-id [id] | --prop-file [prop-file]

    Options:
        --repo-id [id]:            find all violations of a given repo ID [id]
        --violation-id [id]:       find a given violation ID [id]
        --prop-file [prop-file]:   find all violations for a given prop-file
USAGE
    exit 1
}

function execute_script() {
    source ~/.bashrc && cp /home/mopuser/rv-violation-db/extension/target/mop-extension-1.0-SNAPSHOT.jar ~/apache-maven/lib/ext

    bash $script_to_run
}


#Handle each different case of input

while [ "$1" != "" ]; do
    case $1 in
    --repo-id)
        shift # remove `-t` or `--tag` from `$1`
        REPO=$1
        script_to_run="/home/$SCRIPT_USERNAME/$TOOL_REPO/vio_full.sh --repo-id $REPO_ID"
        execute_script
        exit 0
        ;;
    --violation-id)
        shift
        VIO_ID=$1
        script_to_run="/home/$SCRIPT_USERNAME/$TOOL_REPO/vio_full.sh --violation-id $VIO_ID"
        execute_script
        exit 0
        ;;
    --prop-file)
        shift
        ###LOGIC FOR HANDLING ALL SPECS OF A GIVEN PROP FILE
        PROP=$1
        script_to_run="/home/$SCRIPT_USERNAME/$TOOL_REPO/vio_full.sh --prop-file $PROP"
        execute_script
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

