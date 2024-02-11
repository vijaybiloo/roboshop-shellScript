#!/bin/bash

USERID=$(id -u)
DATE=$(date +%F:%H:%M:%S)
LOGDIR=/tmp
SCRIPT=$0
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
        echo -e "$2 ....$R FAILURE $N"
        exit 1
    else
        echo -e "$2 ....$G SUCCES $N"
    fi
}

yum install redis -y &>>$LOGFILE
VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>>$LOGFILE
VALIDATE $? "changing the ip to public"

systemctl enable redis &>>$LOGFILE
VALIDATE $? "Enabling redis"

systemctl start redis &>>$LOGFILE
VALIDATE $? "Staring redis"