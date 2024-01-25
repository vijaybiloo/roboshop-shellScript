#!/bin/bash

USERID=$(du -u)
USERIDROBO=$(du -u roboshop)
DATE=$(date +%F:%H:%M:%S)
SCRIPT=$0
LOGDIR=/tmp
LOGFILE=$LOGDIR/$DATE-$SCRIPT.log

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
        echo -e "Installing $2 .. $R FAILURE $N"
        exit1
    else
        echo -e "Installing $2 .. $G SUCCESS $N"
    if

}

if [ $USERIDROBO -ne 0 ]
then
    echo "roboshop found"
else
    echo "roboshop not found"
fi

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE
VALIDATE $? "Downloading the Nodejs source"

yum install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing nodejs"


useradd roboshop &>> $LOGFILE
VALIDATE $? "Creating roboshop user"

mkdir /app

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloading catalogue software"

cd /app &>> $LOGFILE
VALIDATE $? "changing directory to app"

yum install zip -y &>> $LOGFILE
VALIDATE $? "Installing zip"

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "unziping catalogue"

npm install

cp /home/vijay/roboshop-documentation/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Copying the file catalogue.service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading Daemon"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Starting catalogue"

cp /home/vijay/roboshop-documentation/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE 
VALIDATE $? "Copying the file mongo.repo"

yum install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing mongo-org-shell"

mongo --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Loading schema"