#!/bin/bash 

function setup_prop() {
    # if [[ -z $PROPFILE ]]; then 
    #     return
    # fi
    ###HANDLE SPECIFIC AGENTS###
    rm -rf ~/javamop-agent-bundle/props-to-use/
    mkdir ~/javamop-agent-bundle/props-to-use/
    cp ~/javamop-agent-bundle/props/${PROPFILE} ~/javamop-agent-bundle/props-to-use/
    cp ~/javamop-agent-bundle/props/Object_NoClone.mop ~/javamop-agent-bundle/props-to-use/
    bash ~/javamop-agent-bundle/make-agent.sh ~/javamop-agent-bundle/props-to-use/ ~/javamop-agent-bundle/agents/ quiet

    cd ~/javamop-agent-bundle/
    ###INSTALL JAVAMOPAGENT.JAR
    mvn install:install-file -Dfile=agents/JavaMOPAgent.jar -DgroupId="javamop-agent" -DartifactId="javamop-agent" -Dversion="1.0" -Dpackaging="jar"
    export RVMLOGGINGLEVEL=UNIQUE
    cd ~/
}

function setup_all_props() {
    bash ~/javamop-agent-bundle/make-agent.sh ~/javamop-agent-bundle/props ~/javamop-agent-bundle/agents/ quiet

    cd ~/javamop-agent-bundle/
    ###INSTALL JAVAMOPAGENT.JAR
    mvn install:install-file -Dfile=agents/JavaMOPAgent.jar -DgroupId="javamop-agent" -DartifactId="javamop-agent" -Dversion="1.0" -Dpackaging="jar"
    export RVMLOGGINGLEVEL=UNIQUE
    cd ~/
}

function validate() {
    for ((run=1;run<=$NUM_RERUNS;run++)); do
        # find all matches for prop and check all of them 
        vio_file="TODO"
        line_num="TODO"

        matches_vio_file=true
        if [[ ! -z $VIO_FILE && $VIO_FILE != vio_file ]]; then 
            matches_vio_file=false
        fi

        matches_line_num=true 
        if [[ ! -z $LINE_NUM && $LINE_NUM != line_num ]]; then 
            matches_line_num=false
        fi

        if [[ $matches_vio_file && $matches_line_num ]]; then 
            (( NUM_VALIDATED++ ))
            return
        fi
    done


}

function setup_repo_and_test() {
# Then Clone the Project that you are trying to work on
    cd ~/javamop-agent-bundle/
    git clone https://github.com/$SLUG
    echo $TEST

    repo_name=$(echo $SLUG | sed "s/^\S*[/]\(\S*\)[.]git$/\1/")
    cd ~/javamop-agent-bundle/$repo_name

    if [[ ! -z "$TEST_DIR" ]]; then 
        cd $TEST_DIR
    fi
    git checkout $SHA

    echo $TEST
    SLUG_ID=$(echo $SLUG | sed -e "s///'.'/g")
    PROP=$(echo $PROPFILE | sed "s/.mop//")
    for ((run=1;run<=$NUM_RERUNS;run++)); do
        if [[ -z "$TEST" ]]; then 
            mvn test -Denforcer.skip
        else
        mvn test -Dtest=${TEST} -Denforcer.skip
        fi

        mv violation-counts ~/violations-data/violation_$SLUG_ID-$PROP-$VIO_ID-$run
    done

    if [[ $VALIDATE="yes" ]]; then 
        validate $slug_id $prop
    fi 
    
    cd ~/rv-violation-db/
}

function process() {
    setup_prop
    setup_repo_and_test
}


function process_vio_id() {
    VIO_ID=$1
    echo "$VIO_ID"
    REPO_INFO=$(grep -w -E "$VIO_ID,\S+,\S+,\S+" ~/rv-violation-db/data/repo-data.csv)
    echo "$REPO_INFO"
    VIO_INFO=$(grep -w -E "$VIO_ID,\S+,\S+,\S+" ~/rv-violation-db/data/violation-spec-map.csv)
    echo "$VIO_INFO"

    # Set comma as delimiter
    IFS=','
    #Read the split words into an array based on comma delimiter
    read -a strarr <<< "$REPO_INFO"
    SLUG="${strarr[1]}"
    SHA="${strarr[2]}"
    echo $SLUG
    echo $SHA
    
    read -a strarr <<< "$VIO_INFO"
    PROPFILE="${strarr[1]}"
    TEST_DIR="${strarr[2]}"
    TEST="${strarr[3]}"
    VIO_FILE="${strarr[4]}"
    LINE_NUM="${strarr[5]}"
    echo $PROPFILE
    echo $TEST_DIR
    echo $TEST
    echo $VIO_FILE
    echo $LINE_NUM

    # if [[ -z $PROPFILE ]]; then 
    #     setup_all_props
    # fi
    process 
}

GRANULARITY="all"
GRANULARITY_VALUE=-1
NUM_RERUNS=10
VALIDATE="no"
NUM_VALIDATED=0

while [ "$1" != "" ]; do
    case $1 in
    --repo-slug)
        shift
        GRANULARITY="repo-slug"
        GRANULARITY_VALUE=$1
        ;;
    --violation-id)
        shift
        re='^[0-9]+$'
        if ! [[ $1 =~ $re ]] ; then
            echo "Error: violation-id not a number" >&2; exit 1
        fi
        GRANULARITY="violation-id"
        GRANULARITY_VALUE=$1
        ;;
    --prop-file)
        shift
        GRANULARITY="prop-file"
        GRANULARITY_VALUE=$1
        ;;
    --all)
        GRANULARITY="all"
        GRANULARITY_VALUE=-1
        ;;
    --num-reruns)
        shift
        re='^[0-9]+$'
        if ! [[ $1 =~ $re ]] ; then
            echo "Error: num-reruns not a number" >&2; exit 1
        fi
        NUM_RERUNS=$1
        ;;
    --validate)
        shift 
        VALIDATE="yes"
    esac
    shift
done

echo $GRANULARITY
echo $GRANULARITY_VALUE
echo $NUM_RERUNS
echo $VALIDATE

if [[ $GRANULARITY == "repo-slug" ]]; then
    REPO_SLUG=$GRANULARITY_VALUE
    result=$(grep -w -E "\S+,$REPO_SLUG,\S+,\S+" ~/rv-violation-db/data/repo-data.csv)
    
    IFS=','
    #Read the split words into an array based on comma delimiter
    while read -a line; do 
        process_vio_id "${line[0]}"
    done <<< "$result"
    exit 0
fi

if [[ $GRANULARITY == "violation-id" ]]; then
    VIO_ID=$GRANULARITY_VALUE
    result=$(grep -w -E "$VIO_ID,\S+,\S+,\S+" ~/rv-violation-db/data/repo-data.csv)
    echo $result
    IFS=','
    #Read the split words into an array based on comma delimiter
    while read -a line; do 
        process_vio_id "${line[0]}"
    done <<< "$result"
fi

if [[ $GRANULARITY == "prop-file" ]]; then
    PROP_FILE=$GRANULARITY_VALUE
    result=$(grep -w -E "\S+,$PROP_FILE,\S+,\S+" ~/rv-violation-db/data/violation-spec-map.csv)
    IFS=','
    #Read the split words into an array based on comma delimiter
    while read -a line; do 
        process_vio_id "${line[0]}"
    done <<< "$result"
fi

if [[ $GRANULARITY == "all" ]]; then
    result=$(grep -w -E "^[0-9]+,\S+,\S+,\S+" ~/rv-violation-db/data/repo-data.csv)
    IFS=','
    while read -a line; do 
        process_vio_id "${line[0]}"
    done <<< "$result"
fi

