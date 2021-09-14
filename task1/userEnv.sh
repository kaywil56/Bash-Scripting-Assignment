#! /bin/bash

clear

# Checks if input is a local file or URI
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
                if [[ $? == 1 ]]; then
                        sudo groupadd $value
 sudo groupadd $value
                        echo The group $value was created.
                fi
        done
}
# Checks if shared folders exist. If not they are created
checkSharedFolders(){
        cd /
        find $shared
                if [[ $? == 1 ]]; then
                        sudo mkdir $shared
                        echo shared folder $shared created
                fi
        cd
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
        echo $count

done < $filename

IFS=';'

echo ========== User Enviroment ==========
echo Users to be created: $count
echo
echo Do you wish to run this command? yes/no:
read -p ">>> " yesorno

if [[ $yesorno == no ]]; then
        exit
fi

while read email DOB groups shared
do
        # Creates a username from the given email
        firstChar=${email:0:1}
        stripEmail=${email%@*}
        lastname=${stripEmail#*.}
        username=$firstChar$lastname

        # Creates a password from a given DOB
        year=$(echo $DOB | cut -d '/' -f 1)
        month=$(echo $DOB | cut -d '/' -f 2)
        password=$month$year
        echo $password
       # Checks if secondary groups exist
        checkGroups $groups
        IFS=";"

        # Checks if shared exist
        checkSharedFolders $shared

        #echo creates user
        sudo useradd -d /home/$username -m -G $groups $username -m
        echo User $username created.

        #Adds password to the user
        sudo echo "$username:$password" | sudo chpasswd
        echo =====================================

done < $filename


                                                          