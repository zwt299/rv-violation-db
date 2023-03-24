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
    mkdir props-to-use/
    cp props/${PROPFILE} props-to-use/
    bash make-agent.sh props-to-use/ agents/ quiet

    ###INSTALL JAVAMOPAGENT.JAR
    mvn install:install-file -Dfile=agents/JavaMOPAgent.jar -DgroupId="javamop-agent" -DartifactId="javamop-agent" -Dversion="1.0" -Dpackaging="jar"
    export RVMLOGGINGLEVEL=UNIQUE
}

function setup_repo_and_test() {
# Then Clone the Project that you are trying to work on
    git clone $REPO
    cd $TEST_DIR
    git checkout $SHA
    mvn test -Dtest=$TEST -Denforcer.skip
    cp violation-counts ~/violations-data/violation-${VIO_ID}

    cd ~/javamop-agent-bundle/
}


# if no arguments are provided, return usage function
if [ $# -eq 0 ]; then
    usage # run usage function
    exit 1
fi


while [ "$1" != "" ]; do
    case $1 in
    --violation-id)
        shift # remove `-t` or `--tag` from `$1`
        VIO_ID=$1
        REPO_INFO=$(grep -w -E "\S+,\S+,\S+,$VIO_ID" data/repo-data.csv)
        echo "$REPO_INFO"
        VIOLATION_INFO=$(grep -w -E "$VIO_ID,\S+,\S+,\S+" data/violation-spec-map.csv)
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