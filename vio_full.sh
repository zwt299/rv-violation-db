#!bin/bash 
. ./vio_common.sh

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

function process_vio_id() {
    VIO_ID=$1
    echo "$VIO_ID"
    REPO_INFO=$(grep -w -E "\S+,\S+,\S+,$VIO_ID" ~/rv-violation-db/data/repo-data.csv)
    echo "$REPO_INFO"
    VIO_INFO=$(grep -w -E "$VIO_ID,\S+,\S+,\S+" ~/rv-violation-db/data/violation-spec-map.csv)
    echo "$VIO_INFO"

    # Set comma as delimiter
    IFS=','
    #Read the split words into an array based on comma delimiter
    read -a strarr <<< "$REPO_INFO"
    REPO="${strarr[0]}"
    SHA="${strarr[1]}"
    echo $REPO
    echo $SHA
    read -a strarr <<< "$VIO_INFO"
    PROPFILE="${strarr[1]}"
    TEST_DIR="${strarr[2]}"
    TEST="${strarr[3]}"
    echo $PROPFILE
    echo $TEST_DIR
    echo $TEST

    process()
}

# if no arguments are provided, return usage function
if [ $# -eq 0 ]; then
    usage # run usage function
    exit 1
fi

mkdir ~/violations-data/

array=()
while [ "$1" != "" ]; do
    case $1 in
    --repo-id)
        shift 
        REPO=$1
        result=$(grep -w -E "\S+,\S+,$REPO,\S+" ~/rv-violation-db/data/repo-data.csv)
        # echo "$result"
        ###LOGIC FOR HANDLING ALL OF THE SAME REPO
        # Set comma as delimiter
        IFS=','
        #Read the split words into an array based on comma delimiter
        while read -a line; do 
            process "${line[3]}"
        done <<< "$result"
        exit 0
        ;;
    --violation-id)
        shift
        VIO_ID=$1
        process $VIO_ID
        exit 0
        ;;
    --prop-file)
        shift
        ###LOGIC FOR HANDLING ALL SPECS OF A GIVEN PROP FILE
        PROP=$1
        result=$(grep -w -E "\S+,$PROP,\S+,\S+" data/violation-spec-map.csv)
        echo "$result"

        process_all "${array[@]}"
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

exit 0