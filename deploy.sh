#!/bin/bash

# CloudFront with WAF IP Whitelist - Deployment Script
# Usage: ./deploy.sh [stack-name] [aws-profile] [aws-region]

set -e

# Default values
STACK_NAME=${1:-"cloudfront-waf-stack"}
AWS_PROFILE=${2:-"default"}
AWS_REGION=${3:-"us-east-1"}

echo "🚀 Starting CloudFront with WAF deployment..."
echo "Stack Name: $STACK_NAME"
echo "AWS Profile: $AWS_PROFILE"
echo "AWS Region: $AWS_REGION"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if template file exists
if [ ! -f "cloudfront-waf-template.yaml" ]; then
    echo "❌ CloudFormation template file not found: cloudfront-waf-template.yaml"
    exit 1
fi

# Check if parameters file exists
if [ ! -f "parameters.json" ]; then
    echo "❌ Parameters file not found: parameters.json"
    echo "Please create parameters.json with your configuration."
    exit 1
fi

# Validate CloudFormation template
echo "🔍 Validating CloudFormation template..."
aws cloudformation validate-template \
    --template-body file://cloudfront-waf-template.yaml \
    --profile $AWS_PROFILE \
    --region $AWS_REGION

if [ $? -eq 0 ]; then
    echo "✅ Template validation successful"
else
    echo "❌ Template validation failed"
    exit 1
fi

# Check if stack already exists
STACK_EXISTS=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --profile $AWS_PROFILE \
    --region $AWS_REGION \
    --query 'Stacks[0].StackStatus' \
    --output text 2>/dev/null || echo "DOES_NOT_EXIST")

if [ "$STACK_EXISTS" != "DOES_NOT_EXIST" ]; then
    echo "📝 Stack $STACK_NAME already exists. Updating..."
    aws cloudformation update-stack \
        --stack-name $STACK_NAME \
        --template-body file://cloudfront-waf-template.yaml \
        --parameters file://parameters.json \
        --capabilities CAPABILITY_NAMED_IAM \
        --profile $AWS_PROFILE \
        --region $AWS_REGION
    
    echo "⏳ Waiting for stack update to complete..."
    aws cloudformation wait stack-update-complete \
        --stack-name $STACK_NAME \
        --profile $AWS_PROFILE \
        --region $AWS_REGION
else
    echo "🆕 Creating new stack $STACK_NAME..."
    aws cloudformation create-stack \
        --stack-name $STACK_NAME \
        --template-body file://cloudfront-waf-template.yaml \
        --parameters file://parameters.json \
        --capabilities CAPABILITY_NAMED_IAM \
        --profile $AWS_PROFILE \
        --region $AWS_REGION
    
    echo "⏳ Waiting for stack creation to complete..."
    aws cloudformation wait stack-create-complete \
        --stack-name $STACK_NAME \
        --profile $AWS_PROFILE \
        --region $AWS_REGION
fi

# Get stack outputs
echo ""
echo "📊 Stack Outputs:"
aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --profile $AWS_PROFILE \
    --region $AWS_REGION \
    --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
    --output table

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Next Steps:"
echo "1. Update your S3 bucket policy to allow the Origin Access Identity"
echo "2. Upload your content to the S3 bucket"
echo "3. Test the CloudFront distribution"
echo "4. Monitor WAF metrics in CloudWatch"
echo ""
echo "🔗 Useful Commands:"
echo "  View stack events: aws cloudformation describe-stack-events --stack-name $STACK_NAME --profile $AWS_PROFILE --region $AWS_REGION"
echo "  Delete stack: aws cloudformation delete-stack --stack-name $STACK_NAME --profile $AWS_PROFILE --region $AWS_REGION"
echo ""
