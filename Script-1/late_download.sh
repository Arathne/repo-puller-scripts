#!/bin/bash

##########################################################################################
# Goal: Download late submissions from a pre-entered list of usernames and dates
#
# Input: 
#       param_1: Path to the roster directory
#
#       param_2: Repository being pulled
#           - The name of the repository that was provided to the students
#
#
# Output:
#       - Series of folders that contain pulled student submissions
#       - Inside is a built roster with the format of [firstname_lastname\tdue_date]
#         on each line name roster$REPO_late.txt
#
# Steps:
#       1. Move the paramaters into constant variables, and make a sandbox constant
#          that is the same as the repo name
#       2. If the SANDBOX Directory does not exist; exit
#       3. Generate roster for Dr. Hill's script from the general class roster
#       4. Run script [Dr. Hill] w/ paramaters
#       5. Make a record file in the sandbox w/ [firstname_lastname\t\tdue_date]
#
# Dependencies:
#       - Dr. Hill's grader.py script
#
# Author: Gabriel Shelton [gachshel]
# Version: 0.1
##########################################################################################

ROSTER_NAME="roster.txt"

##########################################################################################
# Goal: 
#       - Tell the user of an error in their paramaters and exit
##########################################################################################
function paramError {
    echo "There was an error in the parameters, you must enter the parameters in this order:"
    echo "Roster path:              A path to the general roster."
    echo "Repo name:                The name of the repository."
    exit 1
}

function main {
    # Make sure that all the needed parameters were passed
    if [ $2 == "" ] 
    then
        paramError
    fi

    local ROSTER_PATH=$1
    local REPO=$2
    local LATE_ROSTER="${ROSTER_PATH}/roster_${REPO}_late.txt"
    local SANDBOX=$REPO

    echo "roster: $ROSTER_PATH/$ROSTER_NAME | late_roster: $LATE_ROSTER | repo: $REPO"
    echo "----------------------------------------------------------------------------"

    # If the sandbox directory doesn't exist
    if [ ! -d $SANDBOX ]
    then
        echo "Sandbox does not exist. Must pull initial downloads before late submissions are accepted (./initial_download.sh)"
        exit 1
    fi

    # If the late_submission file exists, delete it
    if [ -e "$SANDBOX/late_submissions.txt" ]; then
        rm "$SANDBOX/late_submissions.txt"
    fi

    # Create map between name and username (2 arrays with parrallel indexes starting at 0)
    local index=0
    local name_list=()
    local username_list=()
    local due_dates=();
    
    # Map names
    for name in $(cut -f 1 "$ROSTER_PATH/$ROSTER_NAME"); do
        name_list[$index]=$name
        index=$((index + 1))
    done
    local index=0

    # Map usernames
    for username in $(cut -f 1 -d ' ' "$LATE_ROSTER"); do
        username_list[$index]="$username"
        index=$((index + 1))
    done
    local index=0

    # Map Due dates
    for date in $(cut -f 2 -d ' ' "$LATE_ROSTER"); do
        date_list[$index]="$date"
        index=$((index + 1))
    done
    local index=0

    echo "Removing existing submissions for the new late submissions"

    # O(n) where n is the number of students in ROSTER_PATH
    # Delete any existing submissions that are being re-turned in
    for username in $(cut -f 1 -d ' ' "$LATE_ROSTER"); do
        # Find name for username and delete the dir if it exists
        local line=$(cat "$ROSTER_PATH/$ROSTER_NAME" | grep "$username")

        # If this is the username that I am looking for
        if [ "$line" != "" ]; then
            echo "line: $line"
            # Check to see if the user has submitted in the SANDBOX before. Delete it.
            if [ -d $SANDBOX/$(echo "$line" | cut -f 1)-${username} ]; then
                rm -rf ${SANDBOX}/$(echo "$line" | cut -f 1)-${username}
            fi
        fi
        echo -e "$(echo "$line" | cut -f 1)\t\t$(cat ${LATE_ROSTER} | grep ${username} | cut -f 2 -d ' ')" >> "$SANDBOX/late_submissions.txt"
        index=$((index + 1))
    done

    # Run Dr. Hill's script to pull all of the repositories
    echo "Running Dr. Hill's grading script w/ roster: $LATE_ROSTER"
    /usr/local/bin/python3 grader.py --roster "$LATE_ROSTER" --repo "$REPO" --sandbox "$SANDBOX" download

    # Run a script that handles the renaming of the folders in $SANDBOX
    ./rename.sh "$ROSTER_PATH/$ROSTER_NAME" "$LATE_ROSTER" "$SANDBOX"

    exit 0
}

# Call main
main "$@"
