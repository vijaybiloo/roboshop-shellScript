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
    exit1
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ....$R FAILURE $N"
        exit1
    else
        echo -e "$2 ....$G SUCCESS $N"
    fi
}

SKIP(){
	echo -e "$1 Exist... $Y SKIPPING $N"
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE
VALIDATE $? "Downloading the Nodejs source"

yum install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Nodejs"

if [ $IDROBO -e 0 ]
then
    SKIP "roboshop user already exists"
else
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
fi

if [ -d /app ]
then
    SKIP "Skipping creating directory app, because app directory already Exists"
else
    mkdir /app &>>$LOGFILE
    VALIDATE $? "app directory not exists hence Creating it"
fi

curl -L -o /opt/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE
VALIDATE $? "Downloading catalogue software"

cd /app &>>$LOGFILE
VALIDATE $? "changing directory to app"

unzip /opt/user.zip &>>$LOGFILE
VALIDATE $? "Unziping user"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shellScript/user.service /etc/systemd/system/user.service &>>$LOGFILE
VALIDATE $? "Copying the file user.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloding Daemon"

systemctl enable user &>>$LOGFILE
VALIDATE $? "Enabling user"

systemctl start user &>>$LOGFILE
VALIDATE $? "Starting user"

cp /home/centos/roboshop-shellScript/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE 
VALIDATE $? "Copying the file mongo.repo"

yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "Installing mongodb-org"

mongo --host mongodb.jiondevops.site </app/schema/user.js &>>$LOGFILE
VALIDATE $? "Loading schema"