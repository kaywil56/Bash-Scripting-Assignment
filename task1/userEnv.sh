#! /bin/bash

processInput(){
	if [ -z $filename ]; then
		echo no param entered
	else
		if [[ ${filename:0:4} == http ]]; then
			echo URI
		else 
			echo Not URI
		fi
	fi
}

filename=$1

processInput $filename

# IFS=";"

# while read col1 col2 col3 col4
# do
        # echo $col1
# done < $filename
