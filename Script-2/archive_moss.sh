#!/bin/bash
# give it a link and a path to place the files in
#
# example: archive_moss.sh http://moss.stanford.edu/results/241565529/
#

URL=$1
path=$2
folderName=$3

# need url parameter
#
if [ -z URL ]; then
    echo -e "\narchive_moss.sh (url) [path] [folderName]\n"
    exit 1
fi

# initialize folder name
#
if [ -z $folderName ]; then
    folderName=$(date +"moss_archive_%H:%M-%h-%d-%Y")
fi

# initialize path
#
if [ -z $path ]; then
    path='.'
fi
path="$path/$folderName"

# parse file to get links
# if a valid http link -- download link
#
function downloadSubLinks # $1-fileToSearch  .path.
{
    local searchFile=$1
    cat $searchFile | while read line
    do
        local label=$( echo $line | cut -d '>' -f 2 )
        local link=$( echo $label | cut -d '>' -f 1 | cut -d '=' -f 2 | tr -d '[="=]' )
        if [[ "$link" = http* ]]; then
            echo $link
            wget $link -P $path
        fi
    done
}

rm -rf $path
mkdir $path

wget $URL -O "$path/index.html"
if [ $? -ne 0 ]; then
    echo -e "\nlink did not work --Terminating\n"
    exit 1
fi

downloadSubLinks "$path/index.html"

zip -r $folderName.zip  "$path"

echo -e "moss files are in $path"
