#!bin/bash 
function usage() {
    cat <<USAGE
    Usage: $0 vio-id
USAGE
    exit 1
}

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

function setup_repo_and_test() {
# Then Clone the Project that you are trying to work on
    cd ~/javamop-agent-bundle/
    git clone https://github.com/$SLUG
    cd ~/javamop-agent-bundle/$TEST_DIR
    git checkout $SHA
    echo $TEST
    mvn test -Dtest=${TEST} -Denforcer.skip
    cp violation-counts ~/violations-data/violation-${VIO_ID}
    cd ~/rv-violation-db/
}


if [[ $1 == "" ]]; then
    echo "arg1 - violation id"
    usage
fi


mkdir ~/violations-data/

VIO_ID=$1
echo $VIO_ID
REPO_INFO=$(grep -w -E "$VIO_ID,\S+,\S+,\S+" ~/rv-violation-db/data/repo-data.csv)
echo "$REPO_INFO"
VIOLATION_INFO=$(grep -w -E "$VIO_ID,\S+,\S+,\S+" ~/rv-violation-db/data/violation-spec-map.csv)
echo "$VIOLATION_INFO"

# Set comma as delimiter
IFS=','
#Read the split words into an array based on comma delimiter
read -a strarr <<< "$REPO_INFO"
VIO_ID="${strarr[0]}"
SLUG="${strarr[1]}"
SHA="${strarr[2]}"
NOTES_DATA="${strarr[3]}"

echo $SLUG
echo $SHA

read -a strarr <<< "$VIOLATION_INFO"
PROPFILE="${strarr[1]}"
TEST_DIR="${strarr[2]}"
TEST="${strarr[3]}"
echo $PROPFILE
echo $TEST_DIR
echo $TEST

setup_prop    
setup_repo_and_test
exit 0