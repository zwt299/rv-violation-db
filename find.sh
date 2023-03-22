#!bin/bash

function usage() {
    cat <<USAGE
    Usage: $0 [-repo repo] [--skip-verification]

    Options:
        --repo:            information about argument

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
    --repo)
        shift # remove `-t` or `--tag` from `$1`
        REPO=$1
        result=$(grep -w -E "\S+,\S+,$REPO,\S+" data/repo-data.csv)
        echo "$result"

        exit 0
        ;;
    --violations)
        shift
        VIOLATIONS=$1
        result=$(grep -w -E "\S+,\S+,$REPO,\S+" data/repo-data.csv)

        ;;
    -h | --help)
        usage # run usage function
        ;;
    *)
        usage
        exit 1
        ;;
    esac
    shift # remove the current value for `$1` and use the next
done

