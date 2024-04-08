#!/bin/bash
set -euxo pipefail  # Exit script on stderr, unassigned variables, or pipe fails

# Login to Azure
if [[ -z $AWS_ACCESS_KEY_ID ]]; then 
    printf "variable AWS_ACCESS_KEY_ID not set" && exit 1
fi
if [[ -z $AWS_SECRET_ACCESS_KEY ]]; then 
    printf "variable AWS_SECRET_ACCESS_KEY not set" && exit 1
fi
if [[ -z $AWS_REGION ]]; then 
    printf "variable  AWS_REGION not set" && exit 1
fi

# Login to AWS
aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
aws configure set default.region ${AWS_REGION}

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

# Set variables for naming resources
# DeloitteCE has eu-central-1 as default region, ask IT before changing this
if [[ -z $PROJECT ]]; then 
    printf "variable ${PROJECT} not set" && exit 1
fi
if [[ -z $ENVIRONMENT ]]; then 
    printf "variable ${ENVIRONMENT} not set" && exit 1
fi

BUCKET="${PROJECT}-${ACCOUNT_ID}-s3-tfstate-${ENVIRONMENT}-01"
LOCK_TABLE="${PROJECT}-${ACCOUNT_ID}-s3-tflocks-${ENVIRONMENT}-01"

if aws s3api list-buckets | grep -oq $BUCKET; then
    printf "S3 bucket already created"
else
    #Create s3 bucket
    aws s3api create-bucket \
        --region "${AWS_REGION}" \
        --bucket "$BUCKET" \
        --create-bucket-configuration LocationConstraint=${AWS_REGION} \
        --acl private

    #Configure bucket to block public access  
    aws s3api put-public-access-block \
        --bucket "$BUCKET" \
        --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

    #Deny insecure S3 requests
    aws s3api put-bucket-policy \
        --bucket "$BUCKET" \
        --policy "{
        \"Version\": \"2012-10-17\",
        \"Statement\": [
            {
            \"Sid\": \"AllowSSLRequestsOnly\",
            \"Effect\": \"Deny\",
            \"Principal\": \"*\",
            \"Action\": \"s3:*\",
            \"Resource\": [
                \"arn:aws:s3:::${BUCKET}\",
                \"arn:aws:s3:::${BUCKET}/*\"
            ],
            \"Condition\": {
                \"Bool\": {
                \"aws:SecureTransport\": \"false\"
                }
            }
            }
        ]
        }"
    fi

if aws dynamodb list-tables | grep -oq ${LOCK_TABLE}; then
    printf "DynamoDB Table already created"
else
    #Create dynamodb table
    aws dynamodb create-table \
        --region "${AWS_REGION}" \
        --table-name "${LOCK_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
fi

cat <<EOF > ./backend.tf
terraform {
    backend "s3" {
        bucket         = "${BUCKET}"
        key            = "${PROJECT}-${ENVIRONMENT}.tfstate"
        region         = "${AWS_REGION}"
        dynamodb_table = "${LOCK_TABLE}"
    }
}
EOF

#Check if backend.tf is created
cat backend.tf
