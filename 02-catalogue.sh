#!/bin/bash

USERID=$(id -u)
DATE=$(date +%F:%H:%M:%S)
SCRIPT=$0
LOGDIR=/tmp
LOGFILE=$LOGDIR/$DATE-$SCRIPT.log

IDROBO=$(id roboshop)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]
then 
    echo "You should be the root user to execute this command"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ....$R FAILURE $N"
        exit 1
    else
        echo -e "$2 ....$G SUCCES $N"
    fi
}

SKIP(){
	echo -e "$1 Exist... $Y SKIPPING $N"
}

if [ $IDROBO -ne 0 ]
then
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    SKIP "roboshop user already exists"

fi

yum install zip -y &>>$LOGFILE
VALIDATE $? "Installing zip"

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE
VALIDATE $? "Downloading the Nodejs source"

yum install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

if [ -d /app ]
then
    SKIP  "Creating directory app skipping because app directory already Exists"
else
    mkdir /app &>>$LOGFILE
    VALIDATE $? "app directory not exists hence Creating it"
fi

curl -o /opt/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE
VALIDATE $? "Downloading catalogue software"

cd /app &>>$LOGFILE
VALIDATE $? "changing directory to app"

unzip /opt/catalogue.zip &>>$LOGFILE
VALIDATE $? "unziping catalogue"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-documentation/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE
VALIDATE $? "Copying the file catalogue.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading Daemon"

systemctl enable catalogue &>>$LOGFILE
VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>>$LOGFILE
VALIDATE $? "Starting catalogue"

cp /home/centos/roboshop-documentation/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE 
VALIDATE $? "Copying the file mongo.repo"

yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "Installing mongo-org-shell"

mongo --host 10.160.0.2 </tmp/app/schema/catalogue.js &>>$LOGFILE
VALIDATE $? "Loading schema"