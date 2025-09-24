#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0f89fe1c50eaa13ba" # replace with your own SG

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro
     --security-group-ids sg-0f89fe1c50eaa13ba   --tag-specifications "ResourceType=instance,Tags=[{Key=Name,
     Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    #Get Private IP
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 
        Instances[0].PrivateIpAddress --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 
        Instances[0].PublicIpAddress --output text)
    fi
    echo "$instance: $IP"
done