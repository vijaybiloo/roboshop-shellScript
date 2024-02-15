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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$LOGFILE
VALIDATE $? "Configuring YUM Repos from the script provided by vendor"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$LOGFILE
VALIDATE $? "Configureing YUM Repos for RabbitMQ"

yum install rabbitmq-server -y &>>$LOGFILE
VALIDATE $? "Installing rabbitmq-server"

systemctl enable rabbitmq-server &>>$LOGFILE
VALIDATE $? "Enabling rabbitmq-server"

systemctl start rabbitmq-server &>>$LOGFILE
VALIDATE $? "Starting rabbitmq-server"

rabbitmqctl add_user roboshop roboshop123 &>>$LOGFILE
VALIDATE $? "Adding roboshop user and password"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGFILE
VALIDATE $? "Setting permissions"