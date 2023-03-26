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

# function install_extension() {
#     cd ~/javamop/
#     mvn clean
#     bash scripts/install-javaparser.sh
#     mvn package -Drat.skip -DskipTests

#     cd ~/rv-violation-db/extension/
#     mvn package
#     mvn_dir=$(mvn -version | grep ^Maven | cut -d: -f2 | tr -d ' ')
#     mkdir -p ${mvn_dir}/lib/ext
#     cp target/mop-extension-1.0-SNAPSHOT.jar ${mvn_dir}/lib/ext

#     cd ~/javamop-agent-bundle/
# }

function setup_prop() {
    ###HANDLE SPECIFIC AGENTS###
    mkdir ~/javamop-agent-bundle/props-to-use/
    cp ~/javamop-agent-bundle/props/${PROPFILE} ~/javamop-agent-bundle/props-to-use/
    cp ~/javamop-agent-bundle/props/Object_NoClone.mop ~/javamop-agent-bundle/props-to-use/
    bash make-agent.sh ~/javamop-agent-bundle/props-to-use/ ~/javamop-agent-bundle/agents/ quiet

    ###INSTALL JAVAMOPAGENT.JAR
    mvn install:install-file -Dfile=agents/JavaMOPAgent.jar -DgroupId="javamop-agent" -DartifactId="javamop-agent" -Dversion="1.0" -Dpackaging="jar"
    export RVMLOGGINGLEVEL=UNIQUE
}

function setup_repo_and_test() {
# Then Clone the Project that you are trying to work on
    cd ~/javamop-agent-bundle/
    git clone $REPO
    cd ~/javamop-agent-bundle/$TEST_DIR
    git checkout $SHA
    echo $TEST
    mvn test -Dtest=${TEST} -Denforcer.skip
    cp violation-counts ~/violations-data/violation-${VIO_ID}
    cd ~/rv-violation-db/
}


# if no arguments are provided, return usage function
if [ $# -eq 0 ]; then
    usage # run usage function
    exit 1
fi

mkdir ~/violations-data/
while [ "$1" != "" ]; do
    case $1 in
    --violation-id)
        shift # remove `-t` or `--tag` from `$1`
        VIO_ID=$1
        echo $VIO_ID
        REPO_INFO=$(grep -w -E "\S+,\S+,\S+,$VIO_ID" ~/rv-violation-db/data/repo-data.csv)
        echo "$REPO_INFO"
        VIOLATION_INFO=$(grep -w -E "$VIO_ID,\S+,\S+,\S+" ~/rv-violation-db/data/violation-spec-map.csv)
        echo "$VIOLATION_INFO"

        # Set comma as delimiter
        IFS=','
        #Read the split words into an array based on comma delimiter
        read -a strarr <<< "$REPO_INFO"
        REPO="${strarr[0]}"
        SHA="${strarr[1]}"
        echo $REPO
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
        ;;
    *)
        usage
        exit 1
        ;;
    esac
done