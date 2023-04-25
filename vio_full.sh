#!/bin/bash 

function setup_prop() {
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

# function setup_all_props() {
#     bash ~/javamop-agent-bundle/make-agent.sh ~/javamop-agent-bundle/props ~/javamop-agent-bundle/agents/ quiet

#     cd ~/javamop-agent-bundle/
#     ###INSTALL JAVAMOPAGENT.JAR
#     mvn install:install-file -Dfile=agents/JavaMOPAgent.jar -DgroupId="javamop-agent" -DartifactId="javamop-agent" -Dversion="1.0" -Dpackaging="jar"
#     export RVMLOGGINGLEVEL=UNIQUE
#     cd ~/
# }

function validate() {
    PROP_MATCHES=""

    echo "Beginning validation for violation $VIO_ID for specification $PROP (slug = $SLUG)."

    for ((run=1;run<=$NUM_RERUNS;run++)); do
        violations=$(cat ~/violations-data/violation_$SLUG_ID-$PROP-$VIO_ID-$run | grep -w -E "^[1-9]+ Specification .*\.html")
        
        while read violation; do 
            # find all matches for prop and check all of them 
            prop="$(echo $violation | 
            sed "s/^[1-9][0-9]* Specification \(\S*\) .*\.html$/\1/").mop"
            matches_prop="true"
            if [[ $PROPFILE != $prop ]]; then 
                matches_prop="false"
            fi

            vio_file_suffix=$(echo $violation | 
            sed "s/^.* has been violated on line \(\S*\)\.\S*(.*\.html$/\1/" | 
            sed "s/\./\//g")
            matches_vio_file_suffix="true"
            if ! [[ "$VIO_FILE" = "" || "$VIO_FILE" =~ ^.*$vio_file_suffix$ ]]; then 
                matches_vio_file_suffix="false"
            fi

            line_num=$(echo $violation | 
            sed "s/^.* has been violated on line.*(.*\.java:\(\S*\))\..*\.html$/\1/")
            matches_line_num="true"
            if ! [[ "$LINE_NUM" = "" || "$LINE_NUM" = "$line_num" ]]; then 
                matches_line_num="false"
            fi

            #echo $prop
            #echo $matches_prop
            #echo $vio_file_suffix 
            #echo $VIO_FILE
            #echo $matches_vio_file_suffix 
            #echo $LINE_NUM
            #echo $line_num
            #echo $matches_line_num

            if [[ $matches_prop = "true" && $matches_vio_file_suffix = "true" && $matches_line_num = "true" ]]; then 
                echo -e "Validation successful.\n"
                echo -e "Validated: violation ID $VIO_ID, $SLUG, $PROPFILE\n" >> $VALIDATE_LOG_FILE
                (( NUM_VALIDATED++ ))
                return
            fi

            # record violations that match prop but differ in other aspects
            if [[ $matches_prop = "true" ]]; then 
                PROP_MATCHES+="\trun $run: $violation\n"
            fi
        done <<< $violations
    done
    
    failed_validation_msg="Violation ID $VIO_ID, $SLUG: "
    if [[ $PROP_MATCHES = "" ]]; then 
        failed_validation_msg+="No violation matching specification $PROPFILE was observed after $NUM_RERUNS runs."
    else 
        failed_validation_msg+="No violations were produced that match both violation filename and line number after $NUM_RERUNS runs, but violations were observed that violate the specification $PROPFILE:\n\n$PROP_MATCHES"
    fi

    echo -e "$failed_validation_msg\n"
    echo $failed_validation_msg >> $VALIDATE_LOG_FILE
    INVALID_VIO_INFO+="$VIO_ID,$SLUG,$PROPFILE\n"
}

function output_validation_summary(){
        summary="VALIDATION_SUMMARY\n"
        summary+="# of reruns: $NUM_RERUNS\n"
        summary+="# of validated violations: $NUM_VALIDATED\n"

        num_invalid_vios=$(( $(echo $INVALID_VIO_INFO | wc -l) - 1))
        echo $INVALID_VIO_INFO
        echo $num_invalid_vios
        summary+="# of violations not validated: $num_invalid_vios\n"
        if (( $num_invalid_vios > 0 )); then 
                summary+="Violations not validated (violation id, repo slug, propfile)"
                summary+="$INVALID_VIO_INFO"
        fi

        echo -e $summary > $VALIDATE_SUMMARY_FILE
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
    SLUG_ID=$(echo $SLUG | sed "s/.git//" | sed "s/\//./g")
    SLUG_ID=$(echo $SLUG  | sed "s/\//./g")
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
        validate
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

    process 
}

GRANULARITY="all"
GRANULARITY_VALUE=-1
NUM_RERUNS=10

VALIDATE="no"
VALIDATE_LOG_FILE=~/violations-data/validate_full_log.txt
VALIDATE_SUMMARY_FILE=~/violations-data/validate_summary.txt
NUM_VALIDATED=0
INVALID_VIO_INFO=""

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

if [[ "$VALIDATE" = "yes" ]]; then 
        output_validation_summary
fi