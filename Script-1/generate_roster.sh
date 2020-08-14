#!/bin/bash

##########################################################################################
# Goal: Take the general class roster and generate a roster
#       that is more friendly to Dr. Hill's download script
#
# Input: 
#       param_1: Path to roster directory
#
#       param_2: Date due
#
#       param_3: Repo name
#
# Output:
#       - Dr. Hill style roster [username YYYY-MM-DDTHH:MM:SS]
# 
# Steps:
#       1. Create a list of usernames with cut from the general class roster.
#       2. Loop through the usernames and add the [username date_due] each iteration
#          to a file with the name roster_[repo_name].txt.
##########################################################################################

ROSTER_NAME="roster.txt"

function generateRoster {
    # Get parameters
    local roster_path=$1
    local due_date=$2
    local repo=$3

    # Setup filename
    local filename="$roster_path/roster_${repo}.txt"
    
    # If the file exists remove it and create a new one
    if [ -e $filename ]
    then
        echo "rm $filename"
        rm $filename
    fi
    touch $filename

    # Get username list
    local usernames=$(cat "$roster_path/$ROSTER_NAME" | cut -f 2)

    # Populate the roster file
    for user in $usernames
    do
        echo -e "$user $due_date" >> $filename
    done
}

generateRoster "$@"
