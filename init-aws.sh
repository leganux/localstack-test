#!/bin/bash

# Wait for LocalStack to be ready
echo "Waiting for LocalStack to be ready..."
while ! nc -z localhost 4566; do
  sleep 1
done

# Configure AWS CLI for LocalStack
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"
export ENDPOINT_URL="http://localhost:4566"

# Create S3 bucket
echo "Creating S3 bucket..."
awslocal s3 mb s3://my-test-bucket

# Create a test secret in Secrets Manager
echo "Creating test secret..."
awslocal secretsmanager create-secret \
    --name "/dev/app/config" \
    --description "Development configuration" \
    --secret-string '{"database":"mydb","username":"admin","password":"mypassword"}'

# Create SES email identity
echo "Verifying SES email..."
awslocal ses verify-email-identity --email-address noreply@example.com

# Create API Gateway
echo "Creating API Gateway..."
API_ID=$(awslocal apigateway create-rest-api --name "TestAPI" --query 'id' --output text)

# Create a DynamoDB table
echo "Creating DynamoDB table..."
awslocal dynamodb create-table \
    --table-name TestTable \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# Create an SQS queue
echo "Creating SQS queue..."
awslocal sqs create-queue --queue-name test-queue

# Create an SNS topic
echo "Creating SNS topic..."
awslocal sns create-topic --name test-topic

echo "LocalStack initialization completed!"
