#! /bin/bash

set -euo pipefail # set exit when it finds error, u=unset variables, o=option
trap 'echo "Thre is a error in $LINENO and command is $BASH_COMMAND"' ERR # applying trap cmd to handle errors
USER_ID=$(id -u)
R="\e[31m "
G="\e[32m "
Y="\e[33m "
N="\e[0m  "

LOGS_DIR="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_DIR/$SCRIPT_NAME.log"  # /var/log/shell-roboshop/mongodb.log
MONGODB_HOST=mongodb.chiru1982.fun
SCRIPT_DIR=$PWD

mkdir -p $LOGS_DIR
echo "Script execution started at: $(date)" | tee -a $LOG_FILE
if [ $USER_ID -ne 0 ]; then
    echo "ERROR::Install the softwares using root user priveleges!"
    exit 1 # failure is other than 0
fi

#We will remove VALIDATE function and statements written to call VALIDATE function

################## NodeJS ###################
dnf module disable nodejs -y  &>>$LOG_FILE

dnf module enable nodejs:20 -y &>>$LOG_FILE
dnf install nodejs -y &>>$LOG_FILE
id roboshop
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    else
        echo -e "User already exist........$Y..SKIPPING......$N"
    fi
mkdir -p /app 
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
cd /app 

rm -rf /app/*

unzip /tmp/catalogue.zip &>>$LOG_FILE

npm install &>>$LOG_FILE
cp /$SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
systemctl daemon-reload
systemctl enable catalogue &>>$LOG_FILE

cp /$SCRIPT_DIR/mongo.repo  /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongoshdddeee -y &>>$LOG_FILE

INDEX=$(mongosh  mongodb.chiru1982.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
else
    echo -e "Catalogue Products are already loaded into DB .......$Y SKIPPING.....$N"
fi
systemctl restart catalogue
