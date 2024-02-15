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

yum install maven -y &>>$LOGFILE
VALIDATE $? "Installing mavan"

yum install zip -y &>>$LOGFILE
VALIDATE $? "Installing zip"

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

curl -L -o /opt/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE
VALIDATE $? "Downloading shipping software"

cd /app &>>$LOGFILE
VALIDATE $? "changing directory to app"

unzip /opt/shipping.zip &>>$LOGFILE
VALIDATE $? "unziping shipping"

mvn clean package &>>$LOGFILE
VALIDATE $? "Cleaning packages"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE
VALIDATE $? "Moving shipping to jar file"

cp /home/centos/roboshop-shellScript/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE
VALIDATE $? "Copying the file shipping.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading Daemon"

systemctl enable shipping &>>$LOGFILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>>$LOGFILE
VALIDATE $? "Starting shipping"

yum install mysql -y &>>$LOGFILE
VALIDATE $? "Installing mysql"

mysql -h mysql.jiondevops.site -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$LOGFILE
VALIDATE $? "Loading the schema"

systemctl restart shipping &>>$LOGFILE
VALIDATE $? "Restating shipping"