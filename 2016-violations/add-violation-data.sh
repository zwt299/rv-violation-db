#!/bin/bash 

# compile: javac -cp javaparser-core-3.25.3-SNAPSHOT.jar ParseTestMethod.java
# run: java -cp javaparser-core-3.25.3-SNAPSHOT.jar:. ParseTestMethod <test file path> <test line number>

#id, vio id, project, test path, classification
INSPECTIONS=$1
#id, project, project url, SHA
SUBJECTS=$2
#project, project url, SHA, prop, test directory, test file, classification, notes
OUT=$3

declare -A repo_info_by_proj

function initRepoInfo {
  IFS=","

  while read id proj proj_url SHA 
  do 
    if [[ ! -v "repo_info_by_proj[$proj]" ]]
    then
      repo_info_by_proj[$proj]="$proj_url,$SHA"
    fi
  done < <(cat $SUBJECTS)
}

function getTestName {
  
}

initRepoInfo

# TODO:
# clone each repo 
# to get name of specific test:
  # run java file with path to test file and line number 
  # (will need to be extracted from inspections)

IFS=","

HEADER="project,project url,SHA,prop,test directory,test file,test line number,classification,notes"
echo $HEADER > $OUT

while read vio_id proj_id proj test_path prop classification
do
  # ignore violations that are not classified as Falsealarm or Truebug
  if [ classification == "HardToInspect" ] 
  then 
    continue
  fi

  read -a repo_info <<< ${repo_info_by_proj[$proj]}
  proj_url=${repo_info[0]}
  SHA=${repo_info[1]}

  test_dir=$(dirname $test_path)
  base_test_file=$(basename $test_path)
  test_filename=$(echo $base_test_file | sed 's/.java:[0-9]*//')
  test_linenumber=$(echo $base_test_file | sed 's/^.*.java:\([0-9]*\)$/\1/')

  echo "$proj,$proj_url,$SHA,$prop.mop,$test_dir,$test_filename,$test_linenumber,$classification,N/A" >> $OUT
  
  # echo "$shft_vio_id,$prop,$test_dir,$test_file,$classification,N/A" > $OUT
done < $INSPECTIONS
