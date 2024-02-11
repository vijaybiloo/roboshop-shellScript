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

SKIP(){
	echo -e "$1 Exist... $Y SKIPPING $N"
}

yum module disable mysql -y &>>$LOGFILE
VALIDATE $? "Disabling mysql"

cp /home/vijay/roboshop-documentation/mysql.repo /etc/yum.repos.d/mysql.repo &>>$LOGFILE
VALIDATE $? "Copying the file mysql.repo"

yum install mysql-community-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql-community-server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling mysqld"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGFILE
VALIDATE $? "Setting the Root password"

mysql -uroot -pRoboShop@1 &>>$LOGFILE
VALIDATE $? "Checking the new password"