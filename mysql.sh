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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL Server"
systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enable MySQL Server"
systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting MySQL Server" 

mysql_secure_installation --set-root-pass RoboShop@1 # this password we can provide using read cmd but here in practice purpose its ok but in future we will use secrets manager
VALIDATE $? "MySQL Server secure installation"


END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e "Script executed in :$Y $TOTAL_TIME Seconds $N"
