#!/bin/bash

URL=""
FILENAME="moss_home.html"
OUTPUT_FILE="index.html"
ARCHIVE_DIRECTORY="moss_archive_$(date +'%Y-%m-%d_%H:%M')/"

##
# @brief    Compile and print a list of links that need to be downloaded into the $ARCHIVE_DIRECTORY
#
# - Make a list of all of the links (function)
# - Print the links, one per line
#
# @param    1   The Assignment directory
function main {
    # Initialize the constants
    local assignment_directory=$1
    ARCHIVE_DIRECTORY=$assignment_directory/$ARCHIVE_DIRECTORY
    URL="$(cat "$assignment_directory/moss.txt" | tail -n 1)/"
    echo "URL: $URL"
    if [ -d $ARCHIVE_DIRECTORY ]; then
        rm -rf ./$ARCHIVE_DIRECTORY
    fi
    mkdir $ARCHIVE_DIRECTORY
    curl "$URL" > $ARCHIVE_DIRECTORY/$FILENAME

    get_links

    rm "$ARCHIVE_DIRECTORY/$FILENAME" ${ARCHIVE_DIRECTORY}*.org.html
}

##
# @brief    Go through the file and find all the links that need to be downloaded
#
# - Go through the downloaded file until the table header, writing it to the output file
# - Start trimming the for the href address
# - Once I get the address, add it to the download and output the line, editing the href to be local
function get_links {
    local store_links=false
    for line in $(cat $ARCHIVE_DIRECTORY/$FILENAME); do
        local output_line="$line";
        if [ "$store_links" == true ] && [ ! $(echo $line | grep HREF=) == "" ]; then
            # Get label, link, number of slashes in the link, and key
            local label=$(echo $line | cut -d '>' -f 2)
            local link=$(echo $line | cut -d '>' -f 1 | cut -d '=' -f 2 | tr -d '[="=]')
            local number_of_slashes=$(grep -o "/" <<< "$link" | wc -l)
            local key=$(echo ${link} | cut -d '/' -f $((number_of_slashes + 1))-)

            # If the link does not exist in the register, add it
            if [ "$(ls | grep $key)" == "" ]; then
                curl "$link" > $ARCHIVE_DIRECTORY/$key
            fi

            # Download and edit sub-files
            download_sub_files "$link" "$(echo $key | cut -d '.' -f 1)"
            
            # Set the output line
            local output_line=$(echo -e "href=\"./${key}\">${label}")
        else
            if [ "$line" == "Matched" ]; then
                local store_links=true
            fi
        fi
        echo "$output_line" >> $ARCHIVE_DIRECTORY/$OUTPUT_FILE
    done
}

##
# @brief    Download and edit the sub-files for each match
# 
# @param    link to main match
# @param    name of match
function download_sub_files {
    local match=$2
    
    # Download match 0 and 1
    curl "$URL/$match-0.html" > "$ARCHIVE_DIRECTORY/$match-0.html"
    curl "$URL/$match-1.html" > "$ARCHIVE_DIRECTORY/$match-1.html"

    # Download match top
    curl "$URL/$match-top.html" > "$ARCHIVE_DIRECTORY/$match-top.org.html"

    # Print each line seperated by a space in $match-top.html
    for line in $(cat "$ARCHIVE_DIRECTORY/$match-top.org.html"); do
        local output_line=$line

        # If the first part of the line is HREF trim the link down to the local reference
        if [ "$(echo $line | cut -d '=' -f 1)" == "HREF" ]; then
            local link=$(echo "$line" | cut -d '=' -f 2 | tr -d '[="=]')
            local number_of_slashes=$(grep -o "/" <<< "$link" | wc -l)
            local key=$(echo ${link} | cut -d '/' -f $((number_of_slashes + 1))-)

            local output_line="HREF=$key"
        fi

        echo "$output_line" >> "$ARCHIVE_DIRECTORY/$match-top.html"
    done
#echo "http://moss.stanford.edu/results/657830264/match11.html" | cut -d '.' -f 1-3

}

##
# Get Link
# Line: HREF="http://moss.stanford.edu/results/657830264/match11.html">csci24000_fall2018_A4/mahamadoun_toure-matoure/
# 
# label=$(echo $line | cut -f2 -d '>')
# link=$(echo $line | cut -f1 -d '>' | cut -f2 -d '=' | tr -d '[="=]')
# number_of_slashes=$(grep -o "/" <<<"http://moss.stanford.edu/results/657830264/match12.html" | wc -l)
# key=$(echo ${link} | cut -d '/' -f $((number_of_slashes + 1))-)
# 

main "$@"
