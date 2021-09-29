#! /bin/bash

filename=$1

IFS=';'

while read  email DOB groups shared 
do

		cd /

                firstChar=${email:0:1}
                stripEmail=${email%@*}
                lastname=${stripEmail#*.}
                username=$firstChar$lastname
		
		sudo userdel $username

		sudo groupdel
		
		IFS=","
        	for value in $groups
        	do
                        sudo groupdel $value
       		done

		IFS=";"

		sudo rm -r $shared
		sudo rm -r /home/$username
 	
		sudo groupdel privateVisitor
done < $filename
