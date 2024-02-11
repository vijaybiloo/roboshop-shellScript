#!/bin/bash

USERID=$(id -u)
DATE=$(date +%F:%H:%M:%S)
SCRIPT=$0
LOGDIR=/tmp
LOGFILE=$LOGDIR/$DATE-$SCRIPT.log
IDROBO=$(id -u roboshop)

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

yum install zip -y &>>$LOGFILE
VALIDATE $? "Installing zip"

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE
VALIDATE $? "Downloading the Nodejs source"

yum install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Nodejs"

if [ $IDROBO -ne 0 ]
then
    SKIP "roboshop user already exists"
else
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
fi

if [ -d /app ]
then
    SKIP "Creating directory app skipping because app directory already Exists"
else
    mkdir /opt/app &>>$LOGFILE
    VALIDATE $? "app directory not exists hence Creating it"
fi

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE
VALIDATE $? "Downloading catalogue software"

cd /opt/app &>>$LOGFILE
VALIDATE $? "changing directory to app"

unzip /tmp/user.zip &>>$LOGFILE
VALIDATE $? "Unziping user"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/vijay/roboshop-documentation/user.service /etc/systemd/system/user.service &>>$LOGFILE
VALIDATE $? "Copying the file user.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloding Daemon"

systemctl enable user &>>$LOGFILE
VALIDATE $? "Enabling user"

systemctl start user &>>$LOGFILE
VALIDATE $? "Starting user"

cp /home/vijay/roboshop-documentation/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE 
VALIDATE $? "Copying the file mongo.repo"

yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "Installing mongodb-org"

mongo --host MONGODB-SERVER-IPADDRESS </app/schema/user.js &>>$LOGFILE
VALIDATE $? "Loading schema"