#!/bin/bash

FIX=""
AWS_REGION="ap-southeast-2"
TAG_ENV_KEY="env"
TAG_ENV_VAL="prod"
TAG_MAN_BY_KEY="managedBy"
TAG_MAN_BY_VAL="raas"

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <bucket_name> [region]"
    echo "Default region is ${AWS_REGION}"
    exit 1
fi

# update the postfix if this is for dev
if [ "$1" = "dev" ] || [ "$1" = "dv" ]; then
    FIX="-dv"
    TAG_ENV_VAL="dev"
fi

# if a region is provided, use it
if [ $# -ge 2 ]; then
    AWS_REGION="$2"
fi

BUCKET_NAME="core-raas-state"

# create and tag the bucked
echo "Creating S3 bucket in ${AWS_REGION} with the name ${BUCKET_NAME}"
aws s3api create-bucket --bucket $BUCKET_NAME --create-bucket-configuration LocationConstraint=${AWS_REGION}
aws s3api put-bucket-tagging --bucket $BUCKET_NAME --tagging "TagSet=[{Key=$TAG_ENV_KEY,Value=$TAG_ENV_VAL}]"
aws s3api put-bucket-tagging --bucket $BUCKET_NAME --tagging "TagSet=[{Key=$TAG_MAN_BY_KEY,Value=$TAG_MAN_BY_VAL}]"
