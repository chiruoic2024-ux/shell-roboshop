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
dnf module disable nodejs -y  &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"
id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "Creating sytem user"
    else
        echo -e "User already exist........$Y..SKIPPING......$N"
    fi
mkdir -p /app 
VALIDATE $? "Creating app directory"
curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "Download user code"
cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "Unzip the code" 

npm install &>>$LOG_FILE
VALIDATE $? "Install Dependencies" &>>$LOG_FILE
cp /$SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copy systemctl service"
systemctl daemon-reload
VALIDATE $? "Daemon reload"
systemctl enable user &>>$LOG_FILE
VALIDATE $? "Enable user"

systemctl start user
VALIDATE $? "start user"
