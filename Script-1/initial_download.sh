#!/bin/bash

##########################################################################################
# Goal: Take the student roster and populate a 
#       roster list, for use of Dr. James Hill's
#       script to pull down the github repos.
#
# Input: 
#       param_1: Path to the roster directory
#
#       param_2: Repository being pulled
#           - The name of the repository that was provided to the students
#
#       param_3: The date and time due
#           - Format: YYYY-MM-DDTHH:MM:SS
#           - Probably: YYYY-MM-DDT:23:59:59
#
# Output:
#       - A built roster with the format of [username due_date]
#         on each line
#       - Folder where the submissions will live
#           - Series of folders that contain pulled student submissions
#           - Inside is a built roster with the format of [firstname_lastname\tdue_date]
#             on each line
#
# Steps:
#       1. Move the paramaters into constant variables, and make a sandbox constant
#          that is the same as the repo name
#       2. Try and make the sandbox directory if it doesn't exist
#           - If the sandbox directory exists delete it, and remake it
#       3. Generate roster for Dr. Hill's script from the general class roster
#       4. Run script [Dr. Hill] w/ paramaters
#       5. Make a record file in the sandbox w/ [lastname_firstname\tdue_date\t?submission_present?]
#
# Dependencies:
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
    echo "Roster path:     A path to the general roster."
    echo "Repo name:       The name of the repository."
    echo "Date due:        The due date and time.  Format: YYYY-MM-DD'T'HH:MM:SS"
    exit 1
}

function main {
    # Make sure that all the needed parameters were passed
    if [ $3 == "" ]
    then
        paramError
    fi

    ROSTER_PATH="$1"
    REPO=$2
    DATE_DUE=$3
    SANDBOX=$REPO

    echo "roster: $ROSTER_PATH/$ROSTER_NAME | repo: $REPO | date due: $DATE_DUE"
    echo "--------------------------------------------------------"

    # If the sandbox directory exists, delete it and make a new directory for the sandbox
    echo "Making sandbox"
    if [ -d $SANDBOX ]
    then
        rm -rf $SANDBOX
    fi
    mkdir $SANDBOX

    # Generate the roster for Dr. Hill's script
    # script_roster that will be generated
    local script_roster="$ROSTER_PATH/roster_${REPO}.txt"
    echo "Generating roster: ROSTER_PATH: $ROSTER_PATH | DATE_DUE: $DATE_DUE | REPO: $REPO"
    ./generate_roster.sh "$ROSTER_PATH" "$DATE_DUE" "$REPO"
    # Create a late template of the roster
    echo -e "username YYYY-MM-DDT23:59:59" >> ${ROSTER_PATH}/roster_${REPO}_late.txt

    # Run Dr. Hill's script to pull all of the repositories
    echo "Running Dr. Hill's grading script w/ roster: $script_roster"
    /usr/local/bin/python3 grader.py --roster "$script_roster" --repo "$REPO" --sandbox "$SANDBOX" download 
    echo "Finished downloading submissions w/ Dr. Hill's script"

    # Run a script that handles the renaming of the folders in $SANDBOX
    ./rename.sh "$ROSTER_PATH/$ROSTER_NAME" "$script_roster" "$SANDBOX"
}

# Call main
main "$@"
