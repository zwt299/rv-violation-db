#!/bin/bash
echo "Removing Directory Of Existing Repos"
rm -rf ./repos
echo "Creating New Directory Of Repos"
mkdir ./repos
exec < violation-data.csv
cd repos/
read header
while read line
do
    # Set comma as delimiter
    IFS=','
    #Read the split words into an array based on comma delimiter
    read -a strarr <<< "$line"

    #Print the splitted words
    
    REPO_NAME=$(echo "${strarr[0]}" | grep -o -P '(?<=/).*(?=.git)' | sed 's|.*/||')

    echo "Project Repo: ${strarr[0]}"
    echo "Repo SHA: ${strarr[1]}"

    FOLDER_NAME="${REPO_NAME}"-"${strarr[1]}"

    if [ -d "${FOLDER_NAME}" ] 
    then
        echo "Repo with this SHA was already cloned -- avoiding recloning" 
    else 
        # Makes a directory with the In the format REPO_NAME-REPO_SHA
        mkdir ./"${FOLDER_NAME}"
        cd "${FOLDER_NAME}"/
        git clone ${strarr[0]}
        cd "${REPO_NAME}"/
        git checkout ${strarr[1]}
        rm -f pom.xml

        echo "Copying POM file with JavaMop Extension"
        echo /rv-violation-db/project-poms/"${FOLDER_NAME}"/pom.xml
        cp ~/rv-violation-db/project-poms/"${FOLDER_NAME}"/pom.xml ~/rv-violation-db/repos/"${FOLDER_NAME}"/"${REPO_NAME}"/
    fi
    
    cd ~/rv-violation-db
done 