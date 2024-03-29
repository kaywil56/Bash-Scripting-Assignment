#! /bin/bash

clear

filename=$1

# Checks if directory exists.
processInput(){
	if [[ -d $filename ]]; then
		echo "Directory exists."
	else
		echo "Directory does not exist. Exiting..."
		exit 1
	fi	
}
# Processes user input for SCP.
processLocation(){
	read -p ">>> IP address/URL: " location
	echo "Checking if $location is valid..."
	ping -c 4 $location &> /dev/null #Tests if ip is valid
	if [[ $? != 0 ]]; then
		echo "Invalid address. Exiting..."
		rm $filename &> /dev/null
		echo "Removing $filename"
		exit 1
	fi
	read -p ">>> PORT: " port
	read -p ">>> Target directory: " tDirectory
	read -p ">>> Target username: " username
}

if [ -z $filename ]; then #checks if user adds a paramater when running the script
	read -p ">>> Directory location: " filename
	processInput $filename
else
	processInput $filename
fi

echo Do you wish to continue? yes/no
read -p  ">>> " input
echo

if [[ $input != yes ]]; then
	echo "Exiting..."
	exit 1
fi

tar -czvf $filename.tar.gz $filename &> /dev/null
echo "Compressed tarball archive created"

filename=$filename.tar.gz
echo
echo "+--------------+"
echo "| SCP settings |"
echo "+--------------+"
echo
processLocation

echo Sending $filename to $username@$location

scp -P $port $filename $username@$location:$tDirectory

if [[ $? == 0 ]]; then # tests if the transfer was a success. 
	echo The file tranfer was a SUCCESS.
else
	echo The file transfer was a FAILURE.
fi


