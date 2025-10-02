#! /bin/bash

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

VALIDATE(){ # Functions receives inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
    echo -e "$2 .....$R Failure $N" | tee -a $LOG_FILE
    exit 1 # failure is other than 0
    else
    echo -e "$2 .....$G Success $N" | tee -a $LOG_FILE
    fi

}

################## NodeJS ###################
dnf module disable nodejs -y
VALIDATE $? "Disabling NodeJS"
dnf module enable nodejs:20 -y
VALIDATE $? "Enabling NodeJS"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"
id roboshop
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "Creating sytem user"
    else
        echo "User already exist........$Y..SKIPPING......$N"
    fi
mkdir -p /app 
VALIDATE $? "Creating app directory"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Download catalogue code"
cd /app 
VALIDATE $? "Changing to app directory"
unzip /tmp/catalogue.zip
VALIDATE $? "Unzip the code" &>>$LOG_FILE

npm install &>>$LOG_FILE
VALIDATE $? "Install Dependencies" &>>$LOG_FILE
cp /$SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copy systemctl service"
systemctl daemon-reload
VALIDATE $? "Daemon reload"
systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "Enable catalogue"

cp mongo.repo  /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy mango repo"
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB client"
mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "Load catalogue products"
systemctl restart catalogue
VALIDATE $? "Restart catalogue"