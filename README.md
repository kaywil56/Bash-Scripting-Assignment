# Bash-Scripting-Assignment
**Name:** Kaylem Williams Sutherland </br>
**Student ID number:** 1000050830 </br>
**Date of last changes:** N/A </br>
## Task 1: User Enviroment
### Purpose
This script automates adding a large amount of users by reading in a CSV file and processing the data.
* Creates users
* Sets default password
* Add users to secondary groups
* Creates shared folders
* Custom aliases
* Soft links
### Pre-requisites
* A copy of this repo
* A CSV file to give the script
### How to run
Move to the scripts directory
```
   cd Bash-Scripting-Assignment/task1/
  ```
 To run the script either pass your CSV file or leave it empty.
 ```
   sudo ./userEnv.sh yourfile.csv
```
or
```
   sudo ./userEnv.sh 
```

You will be introduced to this window, to continue enter **yes** </br>
</br>
![image](https://user-images.githubusercontent.com/71423497/136113722-5e1a15b8-8dbd-4075-b4f9-f4cafa4066f2.png)
</br>
The script will create the users. A summary of each user will be printed to the screen. To see a more in depth summary enter
```
cat log.txt
```


## Task 2: Directory Backup
### Purpose
This script compresses a given directory and uploads it to a remote server.
### Pre-requisites
* A copy of this repo
* A directory to give the script
### How to run
Move to the scripts directory
```
   cd Bash-Scripting-Assignment/task2/
  ```
  To run the script either pass your CSV file or leave it empty.
 ```
   sudo ./backup.sh yourdirectory
```
or
```
   sudo ./backup.sh 
```
You will be introduced to this window, to continue enter **yes** </br>
![image](https://user-images.githubusercontent.com/71423497/136116023-4fc59401-9ace-4e49-9f93-2e3305c7d05c.png)
</br>
You will be prompted the the following...
* IP:
* PORT:
* Target directory:
* Target username:

