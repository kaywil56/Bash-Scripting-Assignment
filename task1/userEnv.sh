#! /bin/bash

processInput(){
	
	if [[ ${filename:0:4} == http ]]; then
		echo URI
	else 
		echo Not URI
	fi
}

filename=$1

if [ -z $filename ]; then
	read -p "CSV file location: " filename
	processInput $filename
else
	processInput $filename
fi



# IFS=";"

# while read col1 col2 col3 col4
# do
        # echo $col1
# done < $filename
