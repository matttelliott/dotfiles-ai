# AWS CLI and Tools

Complete AWS development environment with CLI v2, SAM, EKS tools, and more.

## Installation

```bash
./tools-cli/aws/setup.sh
```

## What Gets Installed

### Core Tools
- **AWS CLI v2** - Official AWS command line interface
- **AWS SAM CLI** - Serverless Application Model CLI
- **aws-vault** - Secure AWS credential storage
- **eksctl** - Amazon EKS cluster management
- **aws-sso-util** - AWS SSO utilities
- **awslogs** - CloudWatch logs viewer
- **aws-shell** - Interactive AWS CLI shell

### Configuration
- **~/.aws/config** - AWS profiles and settings
- **~/.aws/cli/alias** - Custom CLI aliases
- **Templates** - CloudFormation, SAM, Lambda templates

## Initial Setup

### Configure Credentials
```bash
# Basic configuration
aws configure

# SSO configuration
aws configure sso

# List configured profiles
aws configure list-profiles
```

### Using aws-vault
```bash
# Add new profile
aws-vault add myprofile

# Execute command with profile
aws-vault exec myprofile -- aws s3 ls

# Login to AWS Console
aws-vault login myprofile

# List profiles
aws-vault list
```

## Common Operations

### Account & Identity
```bash
# Who am I?
aws sts get-caller-identity
awsw  # alias

# Get account ID
aws sts get-caller-identity --query Account --output text
awsaccount  # function

# Switch profile
export AWS_PROFILE=production
awsprofile production  # function
```

### EC2 Instances
```bash
# List instances
aws ec2 describe-instances
ec2ls  # alias with table format

# Running instances only
ec2running

# Start/stop instances
ec2start i-1234567890abcdef0
ec2stop i-1234567890abcdef0

# SSH to instance
aws ec2-instance-connect ssh --instance-id i-1234567890abcdef0
```

### S3 Operations
```bash
# List buckets
aws s3 ls
s3ls

# Create bucket
aws s3 mb s3://my-bucket
s3mb s3://my-bucket

# Upload file
aws s3 cp file.txt s3://my-bucket/
s3cp file.txt s3://my-bucket/

# Sync directory
aws s3 sync ./local-dir s3://my-bucket/path/
s3sync ./local-dir s3://my-bucket/path/

# Download file
aws s3 cp s3://my-bucket/file.txt ./

# Remove file
aws s3 rm s3://my-bucket/file.txt
```

### Lambda Functions
```bash
# List functions
aws lambda list-functions
lambdals

# Invoke function
aws lambda invoke --function-name myfunction output.json

# View logs
aws logs tail /aws/lambda/myfunction --follow
lambdalogs /aws/lambda/myfunction

# Update function code
aws lambda update-function-code \
  --function-name myfunction \
  --zip-file fileb://function.zip
```

### CloudFormation
```bash
# List stacks
aws cloudformation list-stacks
cfnls

# Create stack
aws cloudformation create-stack \
  --stack-name mystack \
  --template-body file://template.yaml

# Update stack
aws cloudformation update-stack \
  --stack-name mystack \
  --template-body file://template.yaml

# Delete stack
aws cloudformation delete-stack --stack-name mystack
cfndelete mystack

# View stack events
cfnevents --stack-name mystack
```

## SAM Development

### Create New Application
```bash
# Initialize project
sam init

# Build application
sam build

# Test locally
sam local start-api
sam local invoke FunctionName

# Deploy
sam deploy --guided
```

### Local Testing
```bash
# Start local API
sam local start-api

# Invoke function locally
sam local invoke HelloWorldFunction -e event.json

# Generate sample event
sam local generate-event apigateway aws-proxy > event.json

# Start local Lambda runtime
sam local start-lambda
```

## EKS Management

### Cluster Operations
```bash
# Create cluster
eksctl create cluster --name my-cluster --region us-east-1

# List clusters
eksctl get clusters
eksls

# Delete cluster
eksctl delete cluster --name my-cluster

# Get nodes
kubectl get nodes
eksnodes
```

### Cluster Configuration
```bash
# Update kubeconfig
aws eks update-kubeconfig --name my-cluster

# Scale nodegroup
eksctl scale nodegroup \
  --cluster my-cluster \
  --name my-nodegroup \
  --nodes 3
```

## CloudWatch Logs

### View Logs
```bash
# Tail logs
aws logs tail /aws/lambda/myfunction
cwlogs /aws/lambda/myfunction

# Follow logs
aws logs tail /aws/lambda/myfunction --follow
cwlogsf /aws/lambda/myfunction

# Filter logs
aws logs filter-log-events \
  --log-group-name /aws/lambda/myfunction \
  --filter-pattern ERROR

# Using awslogs
awslogs get /aws/lambda/myfunction --start='2h ago'
```

## IAM Management

### Users and Roles
```bash
# List users
aws iam list-users
iamusers

# List roles
aws iam list-roles
iamroles

# List policies
aws iam list-policies --scope Local
iampolicies

# Get user permissions
aws iam list-attached-user-policies --user-name username
```

### Policy Management
```bash
# Create policy
aws iam create-policy \
  --policy-name MyPolicy \
  --policy-document file://policy.json

# Attach policy to role
aws iam attach-role-policy \
  --role-name MyRole \
  --policy-arn arn:aws:iam::123456789012:policy/MyPolicy
```

## Cost Management

### View Costs
```bash
# Last 30 days by service
awscost

# Custom date range
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics UnblendedCost \
  --group-by Type=DIMENSION,Key=SERVICE
```

## SSO Configuration

### Setup SSO
```bash
# Configure SSO profile
aws configure sso

# Login to SSO
aws sso login --profile my-sso-profile
awssso my-sso-profile

# Use aws-sso-util for advanced SSO
aws-sso-util configure
aws-sso-util login
```

## AWS Shell

### Interactive Mode
```bash
# Start aws-shell
aws-shell

# Features in aws-shell:
# - Auto-completion
# - Fuzzy search
# - Command history
# - Server-side auto-completion
# - Inline documentation
```

## Configured Aliases

### Quick Commands
- `awsw` - Who am I (get-caller-identity)
- `awsp` - List profiles
- `awsr` - Get current region

### Service Shortcuts
- `ec2ls` - List EC2 instances
- `s3ls` - List S3 buckets
- `lambdals` - List Lambda functions
- `cfnls` - List CloudFormation stacks
- `rdsls` - List RDS instances
- `ddbls` - List DynamoDB tables

### Functions
- `awsprofile` - Switch AWS profile
- `awssso` - SSO login
- `awscost` - View costs
- `awsaccount` - Get account ID
- `awsresources` - List all resources

## Best Practices

1. **Use profiles** - Separate credentials by environment
2. **Enable MFA** - Add multi-factor authentication
3. **Use aws-vault** - Secure credential storage
4. **Rotate keys** - Regular credential rotation
5. **Use roles** - Prefer roles over long-term credentials
6. **Tag resources** - Consistent tagging strategy
7. **Monitor costs** - Set up billing alerts
8. **Use regions** - Deploy close to users
9. **Enable logging** - CloudTrail for audit
10. **Least privilege** - Minimal IAM permissions

## Troubleshooting

### Authentication Issues
```bash
# Check current credentials
aws configure list

# Clear cached credentials
rm -rf ~/.aws/cli/cache

# Test credentials
aws sts get-caller-identity
```

### Region Issues
```bash
# Set default region
aws configure set region us-east-1

# Use region flag
aws s3 ls --region eu-west-1

# Export region
export AWS_DEFAULT_REGION=us-east-1
```

### Permission Errors
```bash
# Simulate policy
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:user/username \
  --action-names s3:GetObject \
  --resource-arns arn:aws:s3:::mybucket/*
```

## Templates

Templates are available in `~/.config/aws/templates/`:
- `cloudformation-template.yaml` - Basic CloudFormation template
- `sam-template.yaml` - SAM application template
- `lambda-function.py` - Lambda function boilerplate
- `iam-policy.json` - IAM policy template

## Tips

1. **Use CLI aliases** - Speed up common commands
2. **Enable auto-prompt** - `aws --cli-auto-prompt`
3. **Output formats** - Use `--output table` for readability
4. **Query results** - Use `--query` for filtering
5. **Parallel uploads** - Use `aws s3 cp --recursive`
6. **CLI skeleton** - Generate templates with `--generate-cli-skeleton`
7. **Dry run** - Test commands with `--dry-run`
8. **Wait conditions** - Use `wait` commands for automation
9. **Pagination** - Handle with `--page-size`
10. **Debug mode** - Use `--debug` for troubleshooting