#!bin/bash

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


# if no arguments are provided, return usage function
if [ $# -eq 0 ]; then
    usage # run usage function
    exit 1
fi


while [ "$1" != "" ]; do
    case $1 in
    --repo-id)
        shift # remove `-t` or `--tag` from `$1`
        REPO=$1
        result=$(grep -w -E "\S+,\S+,$REPO,\S+" data/repo-data.csv)
        echo "$result"

        exit 0
        ;;
    --violation-id)
        shift
        VIOLATION_ID=$1
        result=$(grep -w -E "\S+,\S+,\S+,$VIOLATION_ID" data/repo-data.csv)

        echo "$result"
        exit 0
        ;;
    --prop-file)
        shift
        #Logic for all specs of a certain type here

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

