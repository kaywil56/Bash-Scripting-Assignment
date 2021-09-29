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
	if [[ ! -z $groups ]]; then
		IFS=","
		for value in $groups
		do
			grep $value /etc/group > /dev/null
			if [[ $? == 1 ]]; then
				groupadd $value
				if [[ -d $shared ]]; then
					chown :$value $shared
				fi

			fi
		done
			
	fi
}
# Checks if shared folders exist. If not they are created
checkSharedFolders(){
	
		if [[ ! -d $shared && ! -z $shared ]]; then
		        mkdir $shared
			chmod 770 $shared	
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
		firstname=${email}
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
		if [[ ! -z $groups ]]; then
			useradd -d /home/$username -m -G $groups $username -m
		else
			useradd -d /home/$username -m  $username -m 
		fi
	
		#Adds password to the user
		echo "$username:$password" | sudo chpasswd
		#force acount to change password on login
                passwd --expire $username > /dev/null

        	#Summary of created user
		echo "+-----------------------------------+"
		echo "| User $username created            |"
		echo "+-----------------------------------+"
		echo "| Name: $firstname $lastname        |"
		echo "| Email: $email                     |"   
		echo "| DOB: $DOB                         |"
		echo "| Home directory: /home/$username   |"
		echo "| Shared folders: $shared           |"
        	echo "| Password: $"******"               |"
		echo "| Groups: $groups                   |"	
		echo "+-----------------------------------+"
		# Checks if a user has acces to a shared folder
		if [[ ! -z $shared ]]; then
			 ln -s $shared /home/$username/shared
		fi

		# Creates an alias if has sudo access
		if [[ $groups == *"sudo"* ]]; then

			if [[ ! -f /home/$username/.bash_aliases ]]; then
				 touch /home/$username/.bash_aliases
			fi

			echo "alias myls='ls -lisa'" >> /home/$username/.bash_aliases
		fi
	fi

	((count++))
	
done < $filename

