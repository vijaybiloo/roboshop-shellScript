#!/bin/bash

USERID=$(id -u)
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
        echo -e "$2 ....$R FAILURE $N"
        exit 1
    else
        echo -e "$2 ....$G SUCCES $N"
    fi
}

cp /home/vijay/roboshop-documentation/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copying mongo.repo"

yum install mongodb-org -y &>> $LOGFILE
VALIDATE $? "installing mongodb-org"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabling mongod"

sed -i 's/127.0.0.0/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "changing the ip to public"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarting mongod"