#! /bin/bash

# Checks if input is a local file or URI

clear

processInput(){
	if [[ ${filename:0:4} == http ]]; then
		echo URI
        wget $filename
		filename=${filename##*/}
	else
        echo Not URI
        cp $filename .
	fi
}
# Checks if secondary groups exist. If not they are created
checkGroups(){
	IFS=","
	for value in $groups
	do
		grep $value /etc/group
		if [[ $? == 0 ]]; then
			echo $value exists
		else
			echo $value does not exist
			sudo groupadd $value
		fi
	done
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

echo ========== User Enviroment ==========

while read email DOB groups shared
do
	# Creates a username from the given email
	echo Creating username.
	firstChar=${email:0:1}
	stripEmail=${email%@*}
	lastname=${stripEmail#*.}
	username=$firstChar$lastname
	echo username $username created.
	
	# Creates a password from a given DOB
	echo Creating password...
	year=$(echo $DOB | cut -d '/' -f 1)
	month=$(echo $DOB | cut -d '/' -f 2)
	password=$month$year
	echo password $password created.
	
	# Checks if secondary groups exist
	
	checkGroups $groups
	IFS=";"

	#echo User $username created
	sudo useradd -d /home/$username -m -G $groups $username -m
	
	
	# echo groups $groups
	# echo sharedFolder $shared
	
	echo =====================================
	
done < $filename
