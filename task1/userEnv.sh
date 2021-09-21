#! /bin/bash

clear

# Checks if input is a local file or URI
processInput(){
	if [[ ${filename:0:4} == http ]]; then
        	wget $filename
		filename=${filename##*/}
#	else
        #	cp $filename .
	fi
}
# Checks if secondary groups exist. If not they are created
checkGroups(){
	IFS=","
	for value in $groups
	do
		grep $value /etc/group
		if [[ $? == 1 ]]; then
			sudo groupadd $value
			find $shared 2> /dev/null
			if [[ $? == 0 ]]; then
				sudo chown :$value $shared
			fi
		fi 
	done
}
# Checks if shared folders exist. If not they are created
checkSharedFolders(){

	find $shared 2> /dev/null 
		if [[ $? == 1 ]]; then
		 	sudo mkdir $shared	
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

#Counts the amount of users to be created
IFS=$'\n'
count=0
while read user
do
        ((count++))

done < $filename

IFS=';'

count=$(($count-1))

echo ========== User Enviroment ==========
echo 
echo Users to be created: $count
echo 
echo Do you wish to run this command? yes/no:
read -p ">>> " yesorno

if [[ $yesorno != yes ]]; then
	exit
fi

count=0

echo 

while read email DOB groups shared
do
	if [[ $count > 0 ]]; then

		# Creates a username from the given email
		firstChar=${email:0:1}
		stripEmail=${email%@*}
		lastname=${stripEmail#*.}
		username=$firstChar$lastname

		# Creates a password from a given DOB
		year=$(echo $DOB | cut -d '/' -f 1)
		month=$(echo $DOB | cut -d '/' -f 2)
		password=$month$year
	
		# Checks if shared exist
		checkSharedFolders $shared

		#...
		checkGroups $groups
		IFS=";"


		#Adds a user
		sudo useradd -d /home/$username -m -G $groups $username -m
	
		#Adds password to the user
		sudo echo "$username:$password" | sudo chpasswd

        	#Summary of created user
		echo User $username created
		echo -------------------------------------
		echo Home directory: /home/$username
		echo Shared folders: $shared
        	echo Password: $"******"
		echo Groups: $groups	
		echo =====================================
	fi

	((count++))
	
done < $filename

