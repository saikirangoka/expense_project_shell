#!/bin/bash

 USERIDS=$(id -u)

 R="\e[31m"
 G="\e[32m"
 Y="\e[33m"
 N="\e[0m"

 LOGS_FOLDER="/var/logs/expense-logs"
 mkdir -p "$LOGS_FOLDER"
 LOG_FILE=$(echo $0 | cut -d "." -f1 )
 TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
 LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

 VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R Fail $N"
        exit 1
    else
        echo -e "$2 is $G Success $N"
    fi
 }

 CHECK_ROOT(){
    if [ $USERIDS -ne 0 ]
    then
        echo "You need root access to use this script"
        exit 1
    fi
 }

 echo "Script satrted running at $TIMESTAMP" &>>$LOG_FILE_NAME

 CHECK_ROOT

 dnf install nginx -y &>>$LOG_FILE_NAME
 VALIDATE $? "installing nginx"

 systemctl enable nginx &>>$LOG_FILE_NAME
 VALIDATE $? "enabling nginx"

 systemctl start nginx &>>$LOG_FILE_NAME
 VALIDATE $? "starting nginx"

 rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
 VALIDATE $? "Removing existing version of code"

 curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
 VALIDATE $? "Downloading latest code"

 cd /usr/share/nginx/html
 VALIDATE $? "changing directory"

 unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
 VALIDATE $? "unzip the folder"

 cp /home/ec2-user/expense_project_shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE_NAME
 VALIDATE $? "copying "

 systemctl restart nginx &>>$LOG_FILE_NAME
 VALIDATE $? "restarting nginx"



