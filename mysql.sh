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

 dnf install mysql-server -y &>>$LOG_FILE_NAME
 VALIDATE $? "installing mysql-server"

 systemctl enable mysqld &>>$LOG_FILE_NAME
 VALIDATE $? "Enabling mysql-server"

 systemctl start mysqld &>>$LOG_FILE_NAME
 VALIDATE $? "Starting mysql-server"

 
 mysql -h mysql.goksasaikiran.online -u root -pExpenseApp@1 -e 'show databases;'
 if [ $? -ne 0 ]
 then
    echo "Mysql root password is not setup" 
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting root password"
    exit 1
else
    echo -e "$Y Root password is already set $N"
fi