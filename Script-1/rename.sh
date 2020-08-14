#!/bin/bash

################################################################################
# Goal: Rename and shuffle files from Dr. Hill's format out of the script to
#       a more usable format.
#
# Input:
#       - param_1: The roster.txt: format:[name\tusername]
#       - param_2: The path to Dr. Hill's roster file [username date_due]
#       - param_3: The Sandbox
#
# Output:
#       - The folders in the sandbox will go from being identified w/ the username
#         and the repo inside to ->
#       - Each repo will be renamed to the first name
#       - Adds a file named no_submissions and lists the names that have no submission
#       - File with roster format:[name\t\tdate_submission]
################################################################################



##########################################################################################
# Goal: 
#       - Tell the user of an error in their paramaters and exit
##########################################################################################
function paramError {
    echo "There was an error in the parameters, you must enter the parameters in this order:"
    echo "Roster path:                  A path to the general roster."
    echo "Dr. Hill-style Roster:        The name of the repository."
    echo "Sandbox:                      The Sandbox"
    exit 1
}

function main {
    # Map paramaters to Constants
    if [ $3 == "" ]; then
        paramError
    fi

    local ROSTER=$1
    local HILL_ROSTER=$2
    local SANDBOX=$3

    # Names of students
    local names=$(cut -f 1 $ROSTER)

    # Make an array of the names
    local index=0
    declare -A name_list
    for name in $names; do
        name_list[$index]=$name
        index=$((index + 1))
    done

    # Usernames of students
    local usernames=$(cut -f 2 $ROSTER)

    # Get the dates submitted for a name as an array
    local index=0
    local due_dates=$(cut -f 2 -d ' ' $HILL_ROSTER)
    for date in $due_dates; do
        date_list[$index]=$date
        index=$((index + 1));
    done

    # Index in the arrays
    local index=0

    # If the no submission file already exists, delete it
    if [ -e "$SANDBOX/no_submissions.txt" ]; then
        rm "$SANDBOX/no_submissions.txt"
    fi

    # Output stage that we are renaming repositories, and making the assistant files.
    echo "Renaming repositories and filling assistant files"

    # Checks that there are no username directories in $SANDBOX, and populates assistant files
    for username in $usernames; do
        # Get the name for the username
        local name=$(cat $ROSTER | grep $username | cut -f 1)
        # Check if there is a repo for the username; repo name is same as sandbox
        if [ -d $SANDBOX/$username/$SANDBOX ]
        then
            # Move the repo out renamed as the name
            mv "$SANDBOX/$username/$SANDBOX/" "$SANDBOX/${name}-${username}"

        else
            # Output username to no submission
            if [ ! -d "${SANDBOX}/$name-$username" ] 
            then
                echo "$name-$username" >> "$SANDBOX/no_submissions.txt"
            fi
        fi

        # Delete the empty repo folder if it exists
        if [ -d $SANDBOX/$username/ ]; then
            rm -r $SANDBOX/$username/
        fi

        # Increment Index to the next position
        index=$((index + 1))
    done

    # Now lets zip it up and run moss
    ./run_moss.sh "${SANDBOX}"

    exit 0
}

main "$@"
