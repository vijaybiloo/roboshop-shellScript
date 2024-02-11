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

yum install python36 gcc python3-devel -y &>>$LOGFILE
VALIDATE $? "Installing python36 and gcc python3-devel"


if [ $IDROBO -ne 0 ]
then
    SKIP "roboshop user already exists"
else
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
fi

if [ -d /app ]
then
    SKIP  "Creating directory app skipping because app directory already Exists"
else
    mkdir /opt/app &>>$LOGFILE
    VALIDATE $? "app directory not exists hence Creating it"
fi

curl -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE
VALIDATE $? "Downloading payment software"

cd /opt/app &>>$LOGFILE
VALIDATE $? "changing directory to app"

unzip /tmp/payment.zip &>>$LOGFILE
VALIDATE $? "unziping payment"

pip3.6 install -r requirements.txt &>>$LOGFILE
VALIDATE $? "Installing requirements"

cp /home/vijay/roboshop-documentation/payment.service /etc/systemd/system/payment.service &>>$LOGFILE
VALIDATE $? "Copying the file payment.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading Daemon"

systemctl enable payment &>>$LOGFILE
VALIDATE $? "Enabling payment"

systemctl start payment &>>$LOGFILE
VALIDATE $? "Starting payment"