
function setup_prop() {
    ###HANDLE SPECIFIC AGENTS###
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

function setup_repo_and_test() {
# Then Clone the Project that you are trying to work on
    cd ~/javamop-agent-bundle/
    git clone https://github.com/{$SLUG}
    cd ~/javamop-agent-bundle/$TEST_DIR
    git checkout $SHA
    echo $TEST
    if [ $TEST=="" ]; then 
        mvn test -Denforcer.skip
    else
        mvn test -Dtest=${TEST} -Denforcer.skip
    fi
    
    cp violation-counts ~/violations-data/violation-${VIO_ID}
    cd ~/rv-violation-db/
}

function process() {
    if [$PROPFILE=""]; then
        setup_all_props
    else
        setup_prop
    fi  
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
    echo $PROPFILE
    echo $TEST_DIR
    echo $TEST

    process 
}

GRANULARITY="all"
GRANULARITY_VALUE=-1
NUM_RERUNS=10


while [ "$1" != "" ]; do
    case $1 in
    --repo-slug)
        shift
        GRANULARITY="repo-slug"
        GRANULARITY_VALUE=$1
        ;;
    --violation-id)
        shift
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
    esac
    shift
done

echo $GRANULARITY
echo $GRANULARITY_VALUE
echo $NUM_RERUNS

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

