#! /bin/bash

clear

errorCheck(){
	if [[ $? == 0 ]]; then	
		echo SUCCESS >> $log
	else
		echo FALURE >> $log
	fi
}

# Checks if input is a local file or URI
processInput(){
	if [[ ${filename:0:4} == http ]]; then #Checks if input is a URL
        	wget $filename &> /dev/null
		if [[ $? == 0 ]]; then
			echo file downloaded.
			filename=${filename##*/}
		else
			echo there was an issue downloading this file.
			exit 1
		fi
	else
		find $filename &> /dev/null
		if [[ $? == 1 ]]; then
			echo File does not exist.
			exit 1
		fi
	fi
	if [[ $filename == *".csv" ]]; then #Checks if input is a csv file.
		echo Valid file extension.
	else
		echo Invalid file exstension.
		exit 1
	fi
}
# Checks if secondary groups exist. If not they are created
checkGroups(){
	if [[ ! -z $groups ]]; then
		IFS=","
		for value in $groups #Iterates through all groups shown for each user 
		do
			echo Checking if $value group exist... >> $log
			grep $value /etc/group > /dev/null
			if [[ $? == 1 ]]; then
				echo Adding $value group... >> $log
				groupadd $value
				errorCheck $log
				if [[ -d $shared && $value != *"visitor"* ]]; then
					echo Adding $value ownership to $shared... >> $log
					chown :$value $shared
					errorCheck $log
				fi

			fi
		done
			
	fi
}
# Checks if shared folders exist. If not they are created
checkSharedFolders(){
		echo Checking if $shared folder exists... >> $log
		if [[ ! -d $shared && ! -z $shared ]]; then 
			echo Creating $shared folder... >> $log
		        mkdir $shared
			errorCheck $log
			echo Changing permisions for $shared... >> $log
			chmod 770 $shared
			errorCheck $log	
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

echo ========= User Enviroment =========
echo 
echo Users to be created: $count
echo 
echo Do you wish to run this command? yes/no:
read -p ">>> " yesorno

if [[ $yesorno != yes ]]; then
	exit
fi

count=0

echo Creating log file...
touch log.txt
log=log.txt

while read email DOB groups shared
do
	if [[ $count > 0 ]]; then

		# Creates a username from the given email
		echo Creating Username... >> $log
		firstChar=${email:0:1}
		stripEmail=${email%@*}
		firstname=${email}
		lastname=${stripEmail#*.}
		username=$firstChar$lastname
		errorCheck $log

		# Creates a password from a given DOB
		echo Creating Password... >> $log
		year=$(echo $DOB | cut -d '/' -f 1)
		month=$(echo $DOB | cut -d '/' -f 2)
		password=$month$year
		errorCheck $log
		
		# Checks if shared exist
		checkSharedFolders $shared

		# Calls check groups method
		checkGroups $groups
		IFS=";"

		#Adds a user
		echo Creating user $username... >> $log
		if [[ ! -z $groups ]]; then
			useradd -d /home/$username -m -G $groups $username -m
			errorCheck $log
		else
			useradd -d /home/$username -m  $username -m
		       errorCheck $log	
		fi
		
		# Checks if a user needs to be added to a additional group
		if [[ $groups == *"visitor"* && $shared == *"visitor"* ]]; then
			grep visitorFull /etc/group > /dev/null
			if [[ $? == 1 ]]; then
				groupadd visitorFull #adds exclusive groups for visitors that have access to the visitorShared
				chown :visitorFull $shared
			fi
			usermod -a -G visitorFull $username
		fi

		if [[ -z $groups && ! -z $shared ]]; then
			usermod -a -G visitorFull $username
		fi	
	
		#Adds password to the user
		echo Setting password for $username... >> $log
		echo "$username:$password" | sudo chpasswd
		errorCheck $log
		
		#force acount to change password on login
		echo Forcing password change on log in for $username >> $log
                passwd --expire $username > /dev/null
		errorCheck $log
		
        	#Summary of created user
		echo "+-------------------------------------------+"
		echo "  User $username created"
		echo "+-------------------------------------------+"
		echo "  Email: $email                              "   
		echo "  DOB: $DOB                                  "
		echo "  Home directory: /home/$username            "
		echo "  Shared folders: $shared                    "
		echo "  Password:                                  "
		echo "  Groups: $groups                            "	
		# Checks if a user has acces to a shared folder
		if [[ ! -z $shared ]]; then
			 ln -s $shared /home/$username/shared
		fi

		# Creates an alias if has sudo access
		echo Checking if $username belongs to sudo >> $log
		if [[ $groups == *"sudo"* ]]; then
		echo "  Alias: myls"
			if [[ ! -f /home/$username/.bash_aliases ]]; then
				 touch /home/$username/.bash_aliases #Creates the .bash_aliases file if it doees not exist.
			fi
			echo Creating alias for $username >> $log
			echo "alias myls='ls -lisa'" >> /home/$username/.bash_aliases
			errorCheck $log
		fi
	fi

	((count++))
	
done < $filename

echo To see a full summary visit log.txt

