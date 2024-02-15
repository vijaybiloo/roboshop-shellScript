#!/bin/bash

NAMES=("web-nginx" "catalogue" "mongodb" "redis" "user" "cart" "mysql" "shipping" "payment" "dispatch")
INSTANCE_TYPE=""
IMAGE_ID=ami-0f3c7d07486cad139
SECURITY_GROUP_ID=sg-0938b20d2c338196a
DOMAIN_NAME=jiondevops.site
HOSTED_ZONE_ID=Z0630267198Z1Q0Y8S23T

# if mysql or mongodb instance_type should be t3.medium , for all others it is t2.micro

for i in "${NAMES[@]}"
do
    if [[ $i == "mongodb" || $i == "mysql" ]]
    then
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t2.micro"
    fi
    echo "Creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "Created $i instance: $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '
    {
            "Changes":[{
            "Action":"CREATE",
                        "ResourceRecordSet":{
                            "Name":"'$i.$DOMAIN_NAME'",
                            "Type":"A",
                            "TTL":300,
                            "ResourceRecords":[{"Value":"'$IP_ADDRESS'"}]
                        }}]
    }
    '
done