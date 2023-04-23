#!/bin/bash 

# compile: javac -cp javaparser-core-3.25.3-SNAPSHOT.jar ParseTestMethod.java
# run: java -cp javaparser-core-3.25.3-SNAPSHOT.jar:. ParseTestMethod <test file path> <test line number>

#id, vio id, project, test path, classification
INSPECTIONS=$1
#id, project, project url, SHA
SUBJECTS=$2
#Violation_ID, Project_SLUG, SHA, Notes
REPO_DATA=$3
#Violation_ID, Propfile, TestDirectory, Test, ViolationFile, LineNum, Classification, Notes
VIOLATION_SPEC_MAP=$4

declare -A repo_info_by_proj

function initRepoInfo {
  IFS=","

  while read id proj proj_url SHA 
  do 
    slug=$(echo $proj_url | sed 's/^https:[/][/]github[.]com[/]\(\S*\)$/\1/' )

    repo_not_found=$(yes | git ls-remote git@github.com:$slug 2>&1 | grep -c "ERROR: Repository not found.")
    if [[ $repo_not_found -ne 0 ]]; then 
      echo "WARNING: Repository at $slug not found...Skipping"
      continue
    fi 

    repo_info_by_proj[$proj]="$slug,$SHA"
 
  done < <(cat $SUBJECTS)
}

initRepoInfo

IFS=","

NEXT_VIO_ID=$(tail -n 1 $VIOLATION_SPEC_MAP | cut -d "," -f 1)
(( NEXT_VIO_ID++ ))

echo -e -n "\n" >> $REPO_DATA
echo -e -n "\n" >> $VIOLATION_SPEC_MAP

while read vio_id proj_id proj test_path prop classification
do
  # skip automatically mined specs
  if [[ $prop =~ FSM* ]]; then 
    continue
  fi

  read -a repo_info <<< ${repo_info_by_proj[$proj]}
  slug=${repo_info[0]}
  SHA=${repo_info[1]}

  if [[ ! -v "repo_info_by_proj[$proj]" ]]; then 
    echo "Skipping violation -- $proj does not have a valid github link."
    continue
  fi

  base_test_file=$(basename $test_path)
  linenum=$(echo $base_test_file | sed 's/^.*.java:\([0-9]*\)$/\1/')
  repo_name=$(echo $proj_url | sed 's/^.*[/]\(\S*\).git$/\1/')

  #Violation_ID, Project_SLUG, SHA, Notes
  echo "$NEXT_VIO_ID,$slug,$SHA,N/A" >> $REPO_DATA

  #Violation_ID, Propfile, TestDirectory, Test, ViolationFile, LineNum, Classification, Notes
  echo "$NEXT_VIO_ID,$prop.mop,,,$test_path,$linenum,$classification,N/A" >> $VIOLATION_SPEC_MAP

  (( NEXT_VIO_ID++ ))

done < $INSPECTIONS
