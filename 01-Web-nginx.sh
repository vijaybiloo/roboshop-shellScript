#!/bin/bash

USERID=$(id -u)
LOGDIR=/tmp
DATE=$(date +%F:%H:%M:%S)
SCRIPT=$0
LOGFILE=$LOGDIR/$SCRIPT-$DATE.log

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
        echo -e "Installing $2.. $R FAILURE $N"
        exit 1
    else
        echo -e "Installing $2 ..$R SUCCESS $N"
    fi

}

yum install nginx -y &>> $LOGFILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "Starting Nginx"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "Downloading Roboshop-software"

cd /usr/share/nginx/html &>> $LOGFILE

cp /home/vijay/roboshop-documentation/roboshop.conf  /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

systemctl restart nginx &>> $LOGFILE