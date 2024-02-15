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
        echo -e "$2.. $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ..$G SUCCESS $N"
    fi

}

yum install nginx -y &>>$LOGFILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removing defalut files from html"

curl -o /opt/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOGFILE
VALIDATE $? "Downloading Roboshop-software"

cd /usr/share/nginx/html &>>$LOGFILE
VALIDATE $? "changing the directory to html"

unzip /opt/web.zip &>>$LOGFILE
VALIDATE $? "unziping the roboshop zip file"

cp /home/centos/roboshop-shellScript/roboshop.conf  /etc/nginx/default.d/roboshop.conf &>>$LOGFILE
VALIDATE $? "Coping the roboshop.conf"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting nginx"