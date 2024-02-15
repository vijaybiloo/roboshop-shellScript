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

yum install python36 gcc python3-devel -y &>>$LOGFILE
VALIDATE $? "Installing python36 and gcc python3-devel"


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

curl -o /opt/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE
VALIDATE $? "Downloading payment software"

cd /app &>>$LOGFILE
VALIDATE $? "changing directory to app"

unzip /opt/payment.zip &>>$LOGFILE
VALIDATE $? "unziping payment"

pip3.6 install -r requirements.txt &>>$LOGFILE
VALIDATE $? "Installing requirements"

cp /home/centos/roboshop-shellScript/payment.service /etc/systemd/system/payment.service &>>$LOGFILE
VALIDATE $? "Copying the file payment.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading Daemon"

systemctl enable payment &>>$LOGFILE
VALIDATE $? "Enabling payment"

systemctl start payment &>>$LOGFILE
VALIDATE $? "Starting payment"