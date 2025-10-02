#! /bin/bash

USER_ID=$(id -u)
R="\e[31m "
G="\e[32m "
Y="\e[33m "
N="\e[0m  "

LOGS_DIR="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_DIR/$SCRIPT_NAME.log"  # /var/log/shell-roboshop/mongodb.log
START_TIME=$(date +%s)
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

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling existing module of redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling New version:7 of redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Install New version:7 of redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allow remote connection to redis and changing protected mode to no"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enable redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting redis"
END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))

echo "Script executed in :$Y $TOTAL_TIME Seconds $N"