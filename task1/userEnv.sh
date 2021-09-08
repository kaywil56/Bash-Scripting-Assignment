#! /bin/bash

processInput(){

    if [[ ${filename:0:4} == http ]]; then
            echo URI
            wget $filename
    else
            echo Not URI
            cp $filename .
    fi
}

filename=$1

if [ -z $filename ]; then
		read -p "CSV file location: " filename
		processInput $filename
else
        processInput $filename
fi

IFS=";"

while read col1 col2 col3 col4
do
	echo email $col1
	echo DOB $col2
	echo groups $col3
	echo sharedFolder $col4
	
done < $filename
