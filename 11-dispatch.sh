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

yum install golang -y &>>$LOGFILE
VALIDATE $? "Installing golang"


if [ $IDROBO -ne 0 ]
then
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo "roboshop user already exists"
fi

if [ -d /app ]
then
    SKIP  "Creating directory app skipping because app directory already Exists"
else
    mkdir /app &>>$LOGFILE
    VALIDATE $? "app directory not exists hence Creating it"
fi

curl -o /opt/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>$LOGFILE
VALIDATE $? "Downloading dispatch software"

cd /app &>>$LOGFILE
VALIDATE $? "changing directory to app"

unzip /opt/dispatch.zip &>>$LOGFILE
VALIDATE $? "unziping dispatch"

go mod init dispatch &>>$LOGFILE && go get &>>$LOGFILE && go build &>>$LOGFILE
VALIDATE $? "downloading the dependencies & build the software"

cp /home/centos/roboshop-shellScript/dispatch.service /etc/systemd/system/dispatch.service &>>$LOGFILE
VALIDATE $? "Copying the file dispatch.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading Daemon"

systemctl enable dispatch &>>$LOGFILE
VALIDATE $? "Enabling dispatch"

systemctl start dispatch &>>$LOGFILE
VALIDATE $? "Starting dispatch"