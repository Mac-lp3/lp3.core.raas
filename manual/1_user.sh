#!/bin/bash

FIX=""
AWS_REGION="ap-southeast-2"
USER_NAME="core-raas-run-identity"
ROLE_NAME="core-raas-run-role"
POLICY_NAME="core-raas-run-policy"
USER_PATH="/lp3/core/"
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

ACCOUNT_ID=$(aws sts get-caller-identity --output json | jq '.Account')
TAGS="Key=$TAG_ENV_KEY,Value=$TAG_ENV_VAL Key=$TAG_MAN_BY_KEY,Value=$TAG_MAN_BY_VAL"

aws iam create-user --user-name $USER_NAME --no-cli-pager --path $USER_PATH
aws iam tag-user --user-name $USER_NAME --tags '{"Key": "'$TAG_ENV_KEY'", "Value": "'$TAG_ENV_VAL'"}'
aws iam tag-user --user-name $USER_NAME --tags '{"Key": "'$TAG_MAN_BY_KEY'", "Value": "'$TAG_MAN_BY_VAL'"}'

sleep 5

aws iam create-role --role-name $ROLE_NAME --no-cli-pager --path $USER_PATH --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Principal": {
            "AWS": [
                "arn:aws:iam::'$(eval echo $ACCOUNT_ID)':user'$(eval echo $USER_PATH)$(eval echo $USER_NAME)'",
                "arn:aws:iam::'$(eval echo $ACCOUNT_ID)':user/administrator"
            ]
        },
        "Action":"sts:AssumeRole"
    }]
}'

aws iam tag-role --role-name $ROLE_NAME --tags '{"Key": "'$TAG_ENV_KEY'", "Value": "'$TAG_ENV_VAL'"}'
aws iam tag-role --role-name $ROLE_NAME --tags '{"Key": "'$TAG_MAN_BY_KEY'", "Value": "'$TAG_MAN_BY_VAL'"}'

# This role needs all of the permissions to create application deployer users and roles.
# It also needs any additional permissions required by terraform to access / modify the back ends.
aws iam put-role-policy --role-name $ROLE_NAME --policy-name $POLICY_NAME --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
            "Effect": "Allow",
            "Action": [
                "iam:ListRoles",
                "iam:ListUsers",
                "iam:CreateRole",
                "iam:CreateUser",
                "iam:GetRole",
                "iam:UpdateUser",
                "iam:DeleteRole",
                "iam:DeleteUser",
                "iam:DeleteRolePolicy",
                "iam:UpdateRole",
                "iam:GetUser",
                "iam:GetRolePolicy",
                "iam:TagUser",
                "iam:TagRole",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:PutRolePolicy",
                "iam:ListInstanceProfilesForRole"
            ],
            "Resource": [
                "arn:aws:iam::'$(eval echo $ACCOUNT_ID)':role/lp3/raas/*",
                "arn:aws:iam::'$(eval echo $ACCOUNT_ID)':user/lp3/raas/*"
            ]
        }, {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::core-raas-state*"
        }
    ]
}'
