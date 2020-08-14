#!/bin/bash
#example: ./file  student.txt  github_repository

url="git@github.iu.edu:"
input=$1

### do not change anything below unless you know what you are doing

#need student.txt parameter
if [ -z $input ]; then
    echo -e "\nmissing student.txt parameter\n"
    exit 1
fi

#need student.txt file
if [ ! -f $input ]; then
    echo -e "\nstudent.txt not found!\n"
    exit 1
fi

#need repo parameter
repo=$2
if [ -z $repo ]; then
    echo -e "\nneed repository parameter\n"
fi

root="./$repo"
output="$root/output"
failed="$output/missing.txt"
success="$output/success.txt"

function pullRepo # .url.repo.success.failed.
{
    local firstName=$1
    local lastName=$2
    local userName=$3
    local format="$lastName-$firstName"

    echo " "
    if git clone "$url$userName/$repo.git" "$root/$format"; then
        appendFile "$success" "$userName, $firstName $lastName"
        echo -e "\n\e[32m**SUCCESSFULLY** pulled repo for \e[36m$userName\e[39m"
    else
        appendFile "$failed" "$userName, $firstName $lastName"
        echo -e "\n\e[31m**FAILED** to pull repo for \e[36m$userName\e[39m"
    fi
}

function makeFileStructure # .root.output.failed.success.
{
    echo -e "\ndeleting previous data... $root"
    rm -rf $root
    echo -e "\ncreating root directory..."
    mkdir "$root"
    echo -e "\ncreating output directory..."
    mkdir "$output"
    touch "$failed" "$success"
}

function appendFile # .$1-file .$2-text.
{
    local file=$1
    local text=$2
    echo "$text" >> $file
}

function pullStudents # .input
{
    local i=1
    cat $input | while read line
    do
        local data=(`echo $line | tr ',' ' '`)
        local firstName=${data[0]}
        local lastName=${data[1]}
        local userName=${data[2]}

        echo -e "\n\e[33m### $i: $line ###\e[39m"
        pullRepo $firstName $lastName $userName

        i=$(( $i+1 ))
    done
}

makeFileStructure
pullStudents

#zipping contents and moving them to output folder
echo -e "\ncreating $folderName.zip that will be stored in $output\n"
zip -r $repo.zip  "$root/"
mv $repo.zip "$output/"
