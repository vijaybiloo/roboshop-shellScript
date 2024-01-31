#!/bin/bash

USERID=$(id -u)
DATE=$(date +%F:%H:%M:%S)
SCRIPT=$0
LOGDIR=/tmp
LOGFILE=$LOGDIR/$DATE-$SCRIPT.log

USERIDROBO=$(id -u roboshop)
DIR=/app

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
        exit 1
    else
        echo -e "$2 ....$G SUCCES $N"
    fi
}

SKIP(){
	echo -e "$1 Exist... $Y SKIPPING $N"
}

if [ $USERIDROBO -e 0 ]
then
    SKIP "roboshop user already exists"
else
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
fi

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE
VALIDATE $? "Downloading the Nodejs source"

yum install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

if [ ! -d $DIR ]
then
    SKIP "creating app dir"
else
    mkdir /opt/$DIR &>>$LOGFILE
    VALIDATE $? "creating app dir"
fi

curl -o /opt/$DIR/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE
VALIDATE $? "Downloading catalogue software"

cd /opt/$DIR &>>$LOGFILE
VALIDATE $? "changing directory to app"

yum install zip -y &>>$LOGFILE
VALIDATE $? "Installing zip"

unzip /opt/$DIR/catalogue.zip &>>$LOGFILE
VALIDATE $? "unziping catalogue"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/vijay/roboshop-documentation/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE
VALIDATE $? "Copying the file catalogue.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading Daemon"

systemctl enable catalogue &>>$LOGFILE
VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>>$LOGFILE
VALIDATE $? "Starting catalogue"

cp /home/vijay/roboshop-documentation/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE 
VALIDATE $? "Copying the file mongo.repo"

yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "Installing mongo-org-shell"

mongo --host 10.160.0.2 </opt/$DIR/schema/catalogue.js &>>$LOGFILE
VALIDATE $? "Loading schema"