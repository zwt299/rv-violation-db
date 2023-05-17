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

function validate() {
    echo "Beginning validation for violation $VIO_ID for specification $PROP (slug = $SLUG)."

        IFS=$'\n'
        violations=$(cat ~/violations-data/violation_$SLUG_ID-$PROP-$VIO_ID$RUN_SUFFIX | grep -w -E "^[0-9]+ Specification .*\.html")
        while read -r violation; do 
            # find all matches for prop and check all of them 
            prop="$(echo $violation | 
            sed "s/^[1-9][0-9]* Specification \(\S*\) .*\.html$/\1/").mop"
            matches_prop="true"
            if [[ $PROPFILE != $prop ]]; then 
                matches_prop="false"
            fi

#            vio_file_name=$(echo $violation |
#            sed "s/^.* has been violated on line \S*(\(\S*\).java:[0-9]*)\..*$/\1/")
            vio_file_suffix=$(echo $violation | 
            sed "s/^.* has been violated on line \(\S*\)\.[^\.]*(.*\.html$/\1/" |
            sed "s/\./\//g" 
            )
            matches_vio_file_suffix="true"
            if ! [[ "$VIO_FILE" = "" || "$VIO_FILE" =~ ^.*$vio_file_suffix\.java$ ]]; then 
                matches_vio_file_suffix="false"
            fi

            line_num=$(echo $violation | 
            sed "s/^.* has been violated on line.*(.*\.java:\(\S*\))\..*\.html$/\1/")
            matches_line_num="true"
            if ! [[ "$LINE_NUM" = "" || "$LINE_NUM" = "$line_num" ]]; then 
                matches_line_num="false"
            fi

#             echo $prop
#             echo $matches_prop
#             echo $vio_file_suffix 
#             echo $VIO_FILE
#             echo $matches_vio_file_suffix
#             echo $LINE_NUM
#             echo $line_num
#             echo $matches_line_num
#
            if [[ $matches_prop = "true" && $matches_vio_file_suffix = "true" && $matches_line_num = "true" ]]; then 
                VALIDATED="true"

                echo "Validation successful."
                echo "Validated: violation ID $VIO_ID, $SLUG, $PROPFILE"
                VALIDATE_LOG_MESSAGE+="Validated: violation ID $VIO_ID, $SLUG, $PROPFILE\n"

                NUM_VALIDATED=$((NUM_VALIDATED + 1))
                VALID_VIO_INFO+="$VIO_ID,$SLUG,$PROPFILE\n"
                return
            fi

            # record violations that match prop but differ in other aspects
            if [[ $matches_prop = "true" ]]; then 
                PROP_MATCHES+="\trun $run: $violation\n"
            fi
    done < <(cat ~/violations-data/violation_$SLUG_ID-$PROP-$VIO_ID$RUN_SUFFIX | grep -w "^[1-9][0-9]* Specification .*\.html")

    echo "Validation failed."
}

function output_validation_summary(){
        summary="VALIDATION_SUMMARY\n"
        summary+="# of reruns: $NUM_RERUNS\n"

        summary+="# of validated violations: $NUM_VALIDATED\n"
        if (( $NUM_VALIDATED > 0 )); then 
                summary+="Violations validated (violation id, repo slug, propfile):\n"
                summary+="$VALID_VIO_INFO"
        fi

        summary+="# of violations not validated: $NUM_NOT_VALIDATED\n"
        if (( $NUM_NOT_VALIDATED > 0 )); then 
                summary+="Violations not validated (violation id, repo slug, propfile):\n"
                summary+="$INVALID_VIO_INFO"
        fi

        echo -e "$summary" > $VALIDATE_SUMMARY_FILE
        echo -e "$VALIDATE_LOG_MESSAGE" > $VALIDATE_LOG_FILE
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

    SLUG_ID=$(echo $SLUG | sed "s/.git//" | sed "s/\//./g")
    PROP=$(echo $PROPFILE | sed "s/.mop//")

    VALIDATED="false"
    PROP_MATCHES=""
    for ((run=1;run<=$NUM_RERUNS;run++)); do
        if [[ -z "$TEST" ]]; then 
            mvn test -Denforcer.skip
        else
                mvn test -Dtest=${TEST} -Denforcer.skip
        fi

        if [[ $NUM_RERUNS = 1 ]]; then 
                RUN_SUFFIX=""
        else
                RUN_SUFFIX="-$run"
        fi

        if [[ -f violation-counts ]]; then 
            mv violation-counts ~/violations-data/violation_$SLUG_ID-$PROP-$VIO_ID$RUN_SUFFIX
        else 
            echo "" > ~/violations-data/violation_$SLUG_ID-$PROP-$VIO_ID$RUN_SUFFIX
        fi

        if [[ "$VALIDATE" = "yes" ]]; then 
                validate
                IFS=","

                if [[ "$RUN_ALL" = "no" && "$VALIDATED" = "true" ]]; then
                        break
                fi
        fi 
    done

    if [[ "$VALIDATED" = "false" ]]; then 
        failed_validation_msg="Violation ID $VIO_ID, $SLUG: "
        if [[ $PROP_MATCHES = "" ]]; then 
            failed_validation_msg+="No violation matching specification $PROPFILE was observed after $NUM_RERUNS runs."
        else 
            failed_validation_msg+="No violations were produced that match both violation filename $VIO_FILE and line number $LINE_NUM after $NUM_RERUNS runs, but violations were observed that violate the specification $PROPFILE:\n\n$PROP_MATCHES"
        fi

        echo -e "$failed_validation_msg\n"
        VALIDATE_LOG_MESSAGE+="$failed_validation_msg\n"

        NUM_NOT_VALIDATED=$((NUM_NOT_VALIDATED + 1))
        INVALID_VIO_INFO+="$VIO_ID,$SLUG,$PROPFILE\n"
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
NUM_RERUNS=1
RUN_ALL="no"

VALIDATE="yes"
VALIDATE_LOG_FILE=~/violations-data/validate_full_log.txt
VALIDATE_LOG_MESSAGE=""

VALIDATE_SUMMARY_FILE=~/violations-data/validate_summary.txt
NUM_VALIDATED=0
VALID_VIO_INFO=""
NUM_NOT_VALIDATED=0
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
    --no-validate)
        shift 
        VALIDATE="no"
        ;;
    --run-all)
        shift 
        RUN_ALL="yes"
        ;;
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
fi

if [[ $GRANULARITY == "violation-id" ]]; then
    VIO_ID=$GRANULARITY_VALUE
    result=$(grep -w -E "$VIO_ID,\S+,\S+,\S+" ~/rv-violation-db/data/repo-data.csv)
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
