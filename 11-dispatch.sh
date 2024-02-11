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

yum install golang -y &>>$LOGFILE
VALIDATE $? "Installing golang"


if [ $IDROBO -ne 0 ]
then
    SKIP "roboshop user already exists"
else
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
fi

yum install zip -y &>>$LOGFILE
VALIDATE $? "Installing zip"

if [ -d /app ]
then
    SKIP  "Creating directory app skipping because app directory already Exists"
else
    mkdir /opt/app &>>$LOGFILE
    VALIDATE $? "app directory not exists hence Creating it"
fi

curl -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>$LOGFILE
VALIDATE $? "Downloading dispatch software"

cd /opt/app &>>$LOGFILE
VALIDATE $? "changing directory to app"

unzip /tmp/dispatch.zip &>>$LOGFILE
VALIDATE $? "unziping dispatch"

go mod init dispatch &>>$LOGFILE && go get &>>$LOGFILE && go build &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/vijay/roboshop-documentation/dispatch.service /etc/systemd/system/dispatch.service &>>$LOGFILE
VALIDATE $? "Copying the file dispatch.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading Daemon"

systemctl enable dispatch &>>$LOGFILE
VALIDATE $? "Enabling dispatch"

systemctl start dispatch &>>$LOGFILE
VALIDATE $? "Starting dispatch"