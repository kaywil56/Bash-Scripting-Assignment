#! /bin/bash

# Checks if input is a local file or URI
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

# Checks if the user the user has added a param to the executable
if [ -z $filename ]; then
		read -p "CSV file location: " filename
		processInput $filename
else
        processInput $filename
fi

IFS=";"

while read col1 col2 col3 col4
do
	firstname=${col1:0:1}
	temp=${col1%@*}
	lastname=${temp#*.}
	username=$firstname$lastname
	
	echo $username
	echo DOB $col2
	echo groups $col3
	echo sharedFolder $col4
	
done < $filename
