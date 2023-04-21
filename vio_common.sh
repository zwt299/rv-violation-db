#!bin/bash 

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
    git clone https://github.com/$SLUG
    cd ~/javamop-agent-bundle/$TEST_DIR
    git checkout $SHA
    echo $TEST
    if [$TEST==""]; then 
        mvn test -Denforcer.skip
    else
        mvn test -Dtest=${TEST} -Denforcer.skip
    fi
    
    cp violation-counts ~/violations-data/violation-${VIO_ID}
    cd ~/rv-violation-db/
}

function process() {
    # REPO=$1 
    # SHA=$2 
    # PROPFILE=$3 
    # TEST_DIR=$4
    # TEST=$5
    # TEST_LINE_NUM=$6

    if [$PROPFILE=""]; then
        setup_all_props
    else
        setup_prop
    fi  
    setup_repo_and_test
}