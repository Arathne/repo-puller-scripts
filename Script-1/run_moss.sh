#!/bin/bash

##########################################################################################
# Goal: Zip up the submissions and run moss
#
# Input: 
#       - You will have to manually customize this script, with the moss command you want, sorry

#       - param_1: The Repo name
#
# Output:
#       - Zip file for the submission, with a name of $REPO_DATEINFO, and have the moss script running
#
# Steps:
#       1. Figure out the zip file name and make the zip file
#       2. Run Moss
#
# Dependencies:
#       - Moss script (stanford)
#       - Zip Utility
#
# Author: Gabriel Shelton [gachshel]
# Version: 0.1
##########################################################################################

# Moss Command to be ran later
MOSS_COMMAND=""

##########################################################################################
# Goal: 
#       - Tell the user of an error in their paramaters and exit
##########################################################################################
function paramError {
    echo "There was an error in the parameters, you must enter the parameters in this order:"
    echo "Repo name:        The name of the repository."
    exit 1
}

function main {
    # Make sure that all the needed parameters were passed
    if [ $1 == "" ] 
    then
        paramError
    fi

    local REPO=$1

    # ----- Run Tests (If They Exist) -----
    ./run_tests.sh "$REPO"

    # ----- Run Moss -----
    get_moss_command "$REPO"
    echo "Running Moss Command: ${MOSS_COMMAND}"
    ${MOSS_COMMAND} > ${REPO}/moss.org.txt
    cat ${REPO}/moss.org.txt | tail -n 1 > ${REPO}/moss.txt
    rm ${REPO}/moss.org.txt

    # ----- Archive the Results -----
    ./moss_archive.sh "$REPO"

    # ----- Handle Zipping -----
    # Figure the name of the zip-file
    local ZIP_FILE="${REPO}_$(date +'%Y-%m-%d').zip"
    echo "Zipping submissions into: ${REPO}/$ZIP_FILE"

    # Zip the file
    if [ -e ${REPO}/*.zip ]; then
        rm ${REPO}/*.zip
    fi
    zip -r ${REPO}/${ZIP_FILE} ${REPO} > /dev/null
}

function get_moss_command {
    local repo=$1

    # Get the command from the configuration file, by searching for the assignment
    MOSS_COMMAND=$(cat "moss_csci24000_spring2019.txt" | grep "$repo" | cut -d '=' -f2)
}

# Call main
main "$@"
