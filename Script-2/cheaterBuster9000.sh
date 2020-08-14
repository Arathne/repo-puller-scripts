#!/bin/bash
# lots of parameters is a necessary evil. sry
# moss.pl needs to be in the same directory

searchDir=$1
extension=$2
mossExtension=$3
run_past=$4

baseDir="base_files"
pastDir="past_submissions"
outputDir="MOSS"
mossName=$(date +"%H:%M-%h-%d-%Y")
mossPaths=()

# need parameters
if [ -z $searchDir ] || [ -z $extension ] || [ -z $mossExtension ]; then
    echo -e "\ncheaterBuster9000.sh (searchDirectory) (program extension) (moss extension) [check w/ past submissions]\n"
    echo -e "moss extensions: c cc java ml pascal ada lisp scheme haskell fortran ascii vhdl perl matlab python mips prolog spice vb csharp modula2 a8086 javascript plsql verilog\n"
    exit 1
fi

# need moss script
if [ ! -f moss.pl ]; then
    echo -e "\ncould not find moss.pl\n"
    exit 1
fi

# search directory for files with extension
# make a new folder in moss directory
# copy files into new folder
#
function copyFiles # $1-directoryToSearch $-nameToGiveFile  .extension.
{
    local directory=$1
    local name=$2
    i=1
    #find $directory -name "*.$extension"
    find $directory -type f -name "*.$extension" -exec grep -Iq . {} \; -print | while read line
    do
        local parseLine=(`echo $line | tr '/' ' '`)
        local file=${parseLine[-1]}

        echo -e "$i: $line"
        local path="$outputDir/$name"
        mkdir -p $path
        cp $line "$path/$i-$file"
        i=$(( $i+1 ))
    done
}

# get list of subdirectories in folder
# copy them to moss folder by directory
# prevents multiple student from being in same folder
# easier to organize in moss without changing file names
#
function searchDirectory # $1-searchDir .extension.
{
    local directory=$1
    ls -d $directory/* | while read line
    do
        local path=(`echo $line | tr '/' ' '`)
        local name=${path[-1]}
        copyFiles $line "$name"
    done
}

function combineMossPaths
{
    set +m
    shopt -s lastpipe
    ls -d $outputDir/* | while read line
    do
        local path=(`echo $line | tr '/' ' '`)
        local name=${path[-1]}
        if [ -n "$(ls -A MOSS/$name)" ]; then
            mossPaths+=("$name/*.$extension")
        fi
    done
}

rm -rf $outputDir
mkdir $outputDir

searchDirectory $searchDir
searchDirectory $baseDir

if [ ! -z $run_past ]; then
    searchDirectory $pastDir
fi

combineMossPaths

#run moss on target directory
cd MOSS
echo -e "\nrunning files through moss...\n"

#grab moss link and archive url
../moss.pl -d -m 1000 -c $mossName -l $mossExtension ${mossPaths[@]} | while read line
do
    echo "$line"
    if [[ "$line" = http* ]]; then
        ../archive_moss.sh "$line"
        echo "URL: $line"
    fi
done

mv *.zip ../

rm -rf ../MOSS
