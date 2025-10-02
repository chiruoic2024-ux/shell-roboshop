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
MYSQL_HOST=mysql.chiru1982.fun
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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven"
id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "Creating sytem user"
    else
        echo -e "User already exist........$Y..SKIPPING......$N"
    fi
mkdir -p /app 
VALIDATE $? "Creating app directory"
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Download shipping code"
cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Unzip the code" 

mvn clean package &>>$LOG_FILE
VALIDATE $? "Cleaning the package"
mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Moving the jar"
cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "copy systemctl service"
systemctl daemon-reload
VALIDATE $? "Daemon reload"
systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling shipping"
dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Install mysql client"
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
else
    echo -e "Shipping data is already loaded ....$Y SKIPPING.....$N"
fi

systemctl restart shipping
VALIDATE $? "Restart shipping "