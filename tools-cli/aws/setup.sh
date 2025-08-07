#!/bin/bash
# AWS CLI and related tools setup

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Detect OS and architecture
OS="$(uname)"
ARCH="$(uname -m)"

if [[ "$OS" == "Darwin" ]]; then
    PLATFORM="macos"
elif [[ "$OS" == "Linux" ]]; then
    if [[ -f /etc/debian_version ]]; then
        PLATFORM="debian"
    else
        PLATFORM="linux"
    fi
else
    log_warning "Unknown platform: $OS"
    exit 1
fi

install_aws_cli() {
    log_info "Installing AWS CLI v2..."
    
    if command -v aws &> /dev/null; then
        log_info "AWS CLI is already installed: $(aws --version)"
        # Check if it's v2
        if aws --version | grep -q "aws-cli/2"; then
            return 0
        else
            log_info "Upgrading to AWS CLI v2..."
        fi
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install awscli
            else
                # Manual installation
                curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
                sudo installer -pkg AWSCLIV2.pkg -target /
                rm AWSCLIV2.pkg
            fi
            ;;
        debian|linux)
            # Download and install AWS CLI v2
            curl "https://awscli.amazonaws.com/awscli-exe-linux-$ARCH.zip" -o "awscliv2.zip"
            unzip -q awscliv2.zip
            sudo ./aws/install
            rm -rf awscliv2.zip aws/
            ;;
    esac
    
    log_success "AWS CLI v2 installed"
}

install_aws_sam() {
    log_info "Installing AWS SAM CLI..."
    
    if command -v sam &> /dev/null; then
        log_info "AWS SAM CLI is already installed: $(sam --version)"
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install aws-sam-cli
            else
                log_warning "Please install SAM CLI manually from https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
            fi
            ;;
        debian|linux)
            # Install via pip
            if command -v pip3 &> /dev/null; then
                pip3 install --user aws-sam-cli
            elif command -v pipx &> /dev/null; then
                pipx install aws-sam-cli
            else
                log_warning "pip3 or pipx required to install SAM CLI"
            fi
            ;;
    esac
    
    log_success "AWS SAM CLI installed"
}

install_aws_vault() {
    log_info "Installing aws-vault (credential manager)..."
    
    if command -v aws-vault &> /dev/null; then
        log_info "aws-vault is already installed: $(aws-vault --version)"
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install --cask aws-vault
            else
                log_warning "Please install aws-vault manually"
            fi
            ;;
        debian|linux)
            # Get latest version
            VAULT_VERSION=$(curl -s https://api.github.com/repos/99designs/aws-vault/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
            
            # Download and install
            curl -L -o aws-vault "https://github.com/99designs/aws-vault/releases/download/v${VAULT_VERSION}/aws-vault-linux-${ARCH}"
            chmod +x aws-vault
            sudo mv aws-vault /usr/local/bin/
            ;;
    esac
    
    log_success "aws-vault installed"
}

install_eksctl() {
    log_info "Installing eksctl (EKS CLI)..."
    
    if command -v eksctl &> /dev/null; then
        log_info "eksctl is already installed: $(eksctl version)"
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install eksctl
            else
                log_warning "Please install eksctl manually"
            fi
            ;;
        debian|linux)
            # Install eksctl
            curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_$ARCH.tar.gz" | tar xz -C /tmp
            sudo mv /tmp/eksctl /usr/local/bin
            ;;
    esac
    
    log_success "eksctl installed"
}

install_aws_sso_util() {
    log_info "Installing aws-sso-util..."
    
    if command -v aws-sso-util &> /dev/null; then
        log_info "aws-sso-util is already installed"
        return 0
    fi
    
    # Install via pip if available
    if command -v pipx &> /dev/null; then
        pipx install aws-sso-util
    elif command -v pip3 &> /dev/null; then
        pip3 install --user aws-sso-util
    else
        log_warning "Could not install aws-sso-util - pip or pipx required"
    fi
    
    log_success "aws-sso-util installed"
}

install_awslogs() {
    log_info "Installing awslogs (CloudWatch logs viewer)..."
    
    if command -v awslogs &> /dev/null; then
        log_info "awslogs is already installed"
        return 0
    fi
    
    # Install via pip if available
    if command -v pipx &> /dev/null; then
        pipx install awslogs
    elif command -v pip3 &> /dev/null; then
        pip3 install --user awslogs
    else
        log_warning "Could not install awslogs - pip or pipx required"
    fi
    
    log_success "awslogs installed"
}

install_aws_shell() {
    log_info "Installing aws-shell (interactive CLI)..."
    
    if command -v aws-shell &> /dev/null; then
        log_info "aws-shell is already installed"
        return 0
    fi
    
    # Install via pip if available
    if command -v pipx &> /dev/null; then
        pipx install aws-shell
    elif command -v pip3 &> /dev/null; then
        pip3 install --user aws-shell
    else
        log_warning "Could not install aws-shell - pip or pipx required"
    fi
    
    log_success "aws-shell installed"
}

setup_aws_config() {
    log_info "Setting up AWS configuration..."
    
    # Create AWS config directory
    mkdir -p "$HOME/.aws"
    
    # Create basic config file if not exists
    if [[ ! -f "$HOME/.aws/config" ]]; then
        cat > "$HOME/.aws/config" << 'EOF'
[default]
region = us-east-1
output = json
cli_pager = 

# Example profile with SSO
# [profile production]
# sso_start_url = https://my-org.awsapps.com/start
# sso_region = us-east-1
# sso_account_id = 123456789012
# sso_role_name = AdministratorAccess
# region = us-east-1
# output = json

# Example profile with MFA
# [profile staging]
# source_profile = default
# role_arn = arn:aws:iam::123456789012:role/MyRole
# mfa_serial = arn:aws:iam::123456789012:mfa/username
EOF
        log_success "Created AWS config template"
    else
        log_info "AWS config already exists"
    fi
    
    # Create CLI aliases file
    cat > "$HOME/.aws/cli/alias" << 'EOF'
[toplevel]

# Account information
whoami = sts get-caller-identity

# List all regions
regions = ec2 describe-regions --output table --query 'Regions[].{Name:RegionName}'

# EC2 instances
running-instances = ec2 describe-instances \
    --filters Name=instance-state-name,Values=running \
    --output table \
    --query 'Reservations[].Instances[].{ID:InstanceId,Type:InstanceType,Name:Tags[?Key==`Name`]|[0].Value,State:State.Name}'

# S3 operations
bucket-sizes = s3api list-buckets \
    --query "Buckets[].{Name:Name,CreationDate:CreationDate}" \
    --output table

# Lambda functions
list-functions = lambda list-functions \
    --output table \
    --query 'Functions[].{Name:FunctionName,Runtime:Runtime,LastModified:LastModified}'

# CloudFormation stacks
stacks = cloudformation list-stacks \
    --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
    --output table \
    --query 'StackSummaries[].{Name:StackName,Status:StackStatus,Updated:LastUpdatedTime}'

# Cost explorer (last 7 days)
costs = ce get-cost-and-usage \
    --time-period Start=$(date -u -d '7 days ago' '+%Y-%m-%d'),End=$(date -u '+%Y-%m-%d') \
    --granularity DAILY \
    --metrics UnblendedCost \
    --group-by Type=DIMENSION,Key=SERVICE \
    --output table
EOF
    
    mkdir -p "$HOME/.aws/cli"
    log_success "AWS CLI aliases configured"
}

setup_aws_completion() {
    log_info "Setting up AWS CLI completion..."
    
    # Zsh completion
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "aws_completer" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# AWS CLI completion" >> "$HOME/.zshrc"
            echo "autoload bashcompinit && bashcompinit" >> "$HOME/.zshrc"
            echo "complete -C '/usr/local/bin/aws_completer' aws" >> "$HOME/.zshrc"
            log_success "Added AWS CLI zsh completion"
        fi
    fi
    
    # Bash completion
    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -q "aws_completer" "$HOME/.bashrc"; then
            echo "" >> "$HOME/.bashrc"
            echo "# AWS CLI completion" >> "$HOME/.bashrc"
            echo "complete -C '/usr/local/bin/aws_completer' aws" >> "$HOME/.bashrc"
            log_success "Added AWS CLI bash completion"
        fi
    fi
}

setup_aws_aliases() {
    log_info "Setting up AWS aliases..."
    
    local aws_aliases='
# AWS aliases
alias awsw="aws sts get-caller-identity"  # whoami
alias awsp="aws configure list-profiles"  # list profiles
alias awsr="aws configure get region"     # current region

# Profile switching
awsprofile() {
    export AWS_PROFILE="$1"
    echo "Switched to AWS profile: $1"
    aws sts get-caller-identity
}

# SSO login helper
awssso() {
    aws sso login --profile "${1:-default}"
}

# EC2
alias ec2ls="aws ec2 describe-instances --output table --query '\''Reservations[].Instances[].{ID:InstanceId,Type:InstanceType,State:State.Name,Name:Tags[?Key==`Name`]|[0].Value}'\''"
alias ec2running="aws ec2 describe-instances --filters Name=instance-state-name,Values=running --output table"
alias ec2stop="aws ec2 stop-instances --instance-ids"
alias ec2start="aws ec2 start-instances --instance-ids"
alias ec2terminate="aws ec2 terminate-instances --instance-ids"

# S3
alias s3ls="aws s3 ls"
alias s3mb="aws s3 mb"  # make bucket
alias s3rb="aws s3 rb"  # remove bucket
alias s3cp="aws s3 cp"
alias s3mv="aws s3 mv"
alias s3rm="aws s3 rm"
alias s3sync="aws s3 sync"

# Lambda
alias lambdals="aws lambda list-functions --output table"
alias lambdainvoke="aws lambda invoke"
alias lambdalogs="aws logs tail --follow"

# CloudFormation
alias cfnls="aws cloudformation list-stacks --output table"
alias cfndescribe="aws cloudformation describe-stacks"
alias cfnevents="aws cloudformation describe-stack-events"
alias cfndelete="aws cloudformation delete-stack"

# CloudWatch Logs
alias cwlogs="aws logs tail"
alias cwlogsf="aws logs tail --follow"
alias cwgroups="aws logs describe-log-groups --output table"

# ECS
alias ecsls="aws ecs list-clusters"
alias ecsservices="aws ecs list-services"
alias ecstasks="aws ecs list-tasks"

# RDS
alias rdsls="aws rds describe-db-instances --output table"

# DynamoDB
alias ddbls="aws dynamodb list-tables"
alias ddbdescribe="aws dynamodb describe-table"

# IAM
alias iamusers="aws iam list-users --output table"
alias iamroles="aws iam list-roles --output table"
alias iampolicies="aws iam list-policies --scope Local --output table"

# Cost Explorer
awscost() {
    aws ce get-cost-and-usage \
        --time-period Start=$(date -u -d '\''30 days ago'\'' '\''+%Y-%m-%d'\''),End=$(date -u '\''+%Y-%m-%d'\'') \
        --granularity MONTHLY \
        --metrics UnblendedCost \
        --group-by Type=DIMENSION,Key=SERVICE \
        --output table
}

# Get AWS account ID
awsaccount() {
    aws sts get-caller-identity --query Account --output text
}

# List all resources in a region
awsresources() {
    aws resourcegroupstaggingapi get-resources --region "${1:-us-east-1}"
}

# AWS Vault shortcuts
alias av="aws-vault"
alias ave="aws-vault exec"
alias avl="aws-vault list"
alias avs="aws-vault login"

# SAM shortcuts
alias sami="sam init"
alias samb="sam build"
alias samd="sam deploy"
alias saml="sam local start-api"
alias samlog="sam logs"

# EKS shortcuts
alias eksls="eksctl get clusters"
alias eksnodes="kubectl get nodes"
'
    
    # Add to shell RC files
    for rc_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if [[ -f "$rc_file" ]]; then
            if ! grep -q "# AWS aliases" "$rc_file"; then
                echo "$aws_aliases" >> "$rc_file"
                log_success "Added AWS aliases to $(basename $rc_file)"
            else
                log_info "AWS aliases already configured in $(basename $rc_file)"
            fi
        fi
    done
}

create_aws_templates() {
    log_info "Creating AWS templates..."
    
    mkdir -p "$HOME/.config/aws/templates"
    
    # CloudFormation template
    cat > "$HOME/.config/aws/templates/cloudformation-template.yaml" << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Sample CloudFormation Template'

Parameters:
  EnvironmentName:
    Description: Environment name prefix
    Type: String
    Default: dev

Resources:
  S3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${EnvironmentName}-bucket-${AWS::AccountId}'
      VersioningConfiguration:
        Status: Enabled
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true

Outputs:
  BucketName:
    Description: Name of the S3 bucket
    Value: !Ref S3Bucket
    Export:
      Name: !Sub '${AWS::StackName}-BucketName'
EOF
    
    # SAM template
    cat > "$HOME/.config/aws/templates/sam-template.yaml" << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: Sample SAM Application

Globals:
  Function:
    Timeout: 30
    Runtime: python3.9
    Environment:
      Variables:
        TABLE_NAME: !Ref DynamoDBTable

Resources:
  HelloWorldFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: hello_world/
      Handler: app.lambda_handler
      Events:
        HelloWorld:
          Type: Api
          Properties:
            Path: /hello
            Method: get
      Policies:
        - DynamoDBCrudPolicy:
            TableName: !Ref DynamoDBTable

  DynamoDBTable:
    Type: AWS::DynamoDB::Table
    Properties:
      AttributeDefinitions:
        - AttributeName: id
          AttributeType: S
      KeySchema:
        - AttributeName: id
          KeyType: HASH
      BillingMode: PAY_PER_REQUEST

Outputs:
  HelloWorldApi:
    Description: API Gateway endpoint URL
    Value: !Sub "https://${ServerlessRestApi}.execute-api.${AWS::Region}.amazonaws.com/Prod/hello/"
  HelloWorldFunction:
    Description: Lambda Function ARN
    Value: !GetAtt HelloWorldFunction.Arn
EOF
    
    # Lambda function template
    cat > "$HOME/.config/aws/templates/lambda-function.py" << 'EOF'
import json
import boto3
import os
from datetime import datetime

def lambda_handler(event, context):
    """
    Sample Lambda function handler
    """
    
    # Log the received event
    print(f"Received event: {json.dumps(event)}")
    
    # Get environment variables
    table_name = os.environ.get('TABLE_NAME')
    
    # Initialize AWS clients
    dynamodb = boto3.resource('dynamodb')
    
    # Process the event
    try:
        # Your business logic here
        response_body = {
            'message': 'Hello from Lambda!',
            'timestamp': datetime.utcnow().isoformat(),
            'event': event
        }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(response_body)
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
EOF
    
    # IAM policy template
    cat > "$HOME/.config/aws/templates/iam-policy.json" << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ExampleStatement",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::my-bucket/*"
        },
        {
            "Sid": "ListBucket",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::my-bucket"
        }
    ]
}
EOF
    
    log_success "AWS templates created"
}

# Main installation
main() {
    log_info "Setting up AWS CLI and tools..."
    
    install_aws_cli
    install_aws_sam
    install_aws_vault
    install_eksctl
    install_aws_sso_util
    install_awslogs
    install_aws_shell
    setup_aws_config
    setup_aws_completion
    setup_aws_aliases
    create_aws_templates
    
    log_success "AWS tools setup complete!"
    echo
    echo "Installed tools:"
    echo "  • AWS CLI v2 - Command line interface"
    echo "  • AWS SAM CLI - Serverless Application Model"
    echo "  • aws-vault - Secure credential storage"
    echo "  • eksctl - Amazon EKS CLI"
    echo "  • aws-sso-util - SSO utilities"
    echo "  • awslogs - CloudWatch logs viewer"
    echo "  • aws-shell - Interactive shell"
    echo
    echo "Configuration:"
    echo "  • ~/.aws/config - AWS configuration"
    echo "  • ~/.aws/cli/alias - CLI aliases"
    echo
    echo "Quick start:"
    echo "  aws configure           - Set up credentials"
    echo "  aws sso configure       - Set up SSO"
    echo "  aws-vault add profile   - Add secure profile"
    echo "  aws-shell              - Interactive mode"
    echo
    echo "Templates available in ~/.config/aws/templates/"
    echo
    echo "Note: Remember to configure your AWS credentials!"
}

main "$@"