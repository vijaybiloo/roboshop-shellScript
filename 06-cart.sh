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
    SKIP "roboshop user already exists"
else
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
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
    mkdir /opt/app &>>$LOGFILE
    VALIDATE $? "app directory not exists hence Creating it"
fi

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOGFILE
VALIDATE $? "Downloading cart software"

cd /opt/app &>>$LOGFILE
VALIDATE $? "changing directory to app"

unzip /tmp/cart.zip &>>$LOGFILE
VALIDATE $? "unziping catalogue"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/vijay/roboshop-documentation/cart.service /etc/systemd/system/cart.service &>>$LOGFILE
VALIDATE $? "Copying the file cart.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading Daemon"

systemctl enable catalogue &>>$LOGFILE
VALIDATE $? "Enabling cart"

systemctl start catalogue &>>$LOGFILE
VALIDATE $? "Starting cart"