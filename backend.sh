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

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling Nodejs20"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "installing nodejs"


id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE_NAME
    VALIDATE $? "Adding user"
else
    echo "user already exist"
fi

mkdir /app
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading Backend"

cd /app
VALIDATE $? "Changing directory"

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzip the application folder"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "installing dependencies"

cp /home/ec2-user/expense_project_shell/backend.service /etc/systemd/system/backend.service

#prepare mysql schema

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "installing mysql client"

mysql -h mysql.gokasaikiran.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "Setting up the transaction schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Daemon reload"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "enabling backend"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "starting backend"


