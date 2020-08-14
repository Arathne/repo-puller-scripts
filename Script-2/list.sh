#$!/bin/bash # ./list.sh  Folder(required)

#need a parameter
root=$1
if [ -z $root ]; then
    echo -e "\nmissing parameter"
    echo -e "./list.sh Folder\n"
    exit 1
fi

#need directory
if [ ! -d $root ]; then
    echo -e "\n$root : could not find directory\n"
    exit 1
fi

#need output folder inside directory
output="./$root/output"
if [ ! -d $output ]; then
    echo -e "\n$output : output folder not found inside directory\n"
    exit 1
fi

failed="$output/missing.txt"
success="$output/success.txt"

#need missing.txt and success.txt
if [ ! -f $failed ] || [ ! -f $success ] ;then
    echo -e "\ncould not find a text file\n"
fi

function displayFile # .$1-textFile.
{
    local file=$1
    local i=1
    cat $file | while read line
    do
        echo "$i: $line"
        i=$(( $i+1 ))
    done
}

echo -e "\n\n\e[31m==========FAILED=========="
displayFile $failed
echo -e "\n\e[32m==========SUCCESS========="
displayFile $success
echo -e "\e[39m"
