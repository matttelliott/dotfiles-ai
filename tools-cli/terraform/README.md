# Terraform - Infrastructure as Code

Complete Terraform setup with Terragrunt, linters, security scanners, and documentation tools.

## Installation

```bash
./tools-cli/terraform/setup.sh
```

## What Gets Installed

### Core Tools
- **Terraform** - Infrastructure as Code tool
- **Terragrunt** - DRY Terraform configurations
- **TFLint** - Terraform linter
- **tfsec** - Static security scanner
- **terraform-docs** - Documentation generator

## Basic Usage

### Terraform Workflow
```bash
# Initialize
terraform init

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
terraform plan
terraform plan -out=tfplan

# Apply changes
terraform apply
terraform apply tfplan
terraform apply -auto-approve

# Destroy infrastructure
terraform destroy
terraform destroy -auto-approve
```

### State Management
```bash
# List resources
terraform state list

# Show resource
terraform state show aws_instance.example

# Move resource
terraform state mv aws_instance.old aws_instance.new

# Remove from state
terraform state rm aws_instance.example

# Pull remote state
terraform state pull > terraform.tfstate

# Push state
terraform state push terraform.tfstate
```

### Workspaces
```bash
# List workspaces
terraform workspace list

# Create workspace
terraform workspace new production

# Select workspace
terraform workspace select production

# Delete workspace
terraform workspace delete staging
```

## Configured Aliases

### Basic Commands
- `tf` - terraform
- `tfi` - terraform init
- `tfp` - terraform plan
- `tfa` - terraform apply
- `tfaa` - terraform apply -auto-approve
- `tfd` - terraform destroy
- `tfda` - terraform destroy -auto-approve
- `tfv` - terraform validate
- `tff` - terraform fmt

### State Commands
- `tfs` - terraform state
- `tfsl` - terraform state list
- `tfss` - terraform state show
- `tfsp` - terraform state pull

### Workspace Commands
- `tfw` - terraform workspace
- `tfwl` - terraform workspace list
- `tfws` - terraform workspace select
- `tfwn` - terraform workspace new

### Terragrunt
- `tg` - terragrunt
- `tgi` - terragrunt init
- `tgp` - terragrunt plan
- `tga` - terragrunt apply
- `tgd` - terragrunt destroy

### Functions
- `tfplan` - Plan with output file
- `tfapply` - Apply from plan file
- `tfdiff` - Show detailed plan diff
- `tfimport` - Import existing resource
- `tfgraph` - Generate dependency graph
- `tfcost` - Estimate costs (requires Infracost)
- `tfscan` - Security scan with tfsec
- `tfdoc` - Generate documentation
- `tfclean` - Clean Terraform files
- `tfbackup` - Backup state file

## Configuration Files

### .terraformrc
Located at `~/.terraformrc`:
```hcl
plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
disable_checkpoint = true

credentials "app.terraform.io" {
  token = "YOUR_TERRAFORM_CLOUD_TOKEN"
}
```

## Project Structure

### Basic Structure
```
project/
├── main.tf              # Main configuration
├── variables.tf         # Variable definitions
├── outputs.tf          # Output definitions
├── terraform.tfvars    # Variable values
├── versions.tf         # Provider versions
└── README.md          # Documentation
```

### Module Structure
```
project/
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   │   └── main.tf
│   └── prod/
│       └── main.tf
└── terragrunt.hcl
```

## Best Practices

### 1. State Management
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "path/to/state"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### 2. Variable Validation
```hcl
variable "environment" {
  type = string
  validation {
    condition     = can(regex("^(dev|staging|prod)$", var.environment))
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### 3. Resource Tagging
```hcl
provider "aws" {
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
      CostCenter  = var.cost_center
    }
  }
}
```

### 4. Data Sources
```hcl
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}
```

### 5. Conditionals
```hcl
resource "aws_instance" "example" {
  count = var.create_instance ? 1 : 0
  
  ami           = data.aws_ami.latest.id
  instance_type = var.instance_type
}
```

### 6. Loops
```hcl
resource "aws_instance" "example" {
  for_each = var.instances
  
  ami           = each.value.ami
  instance_type = each.value.type
  
  tags = {
    Name = each.key
  }
}
```

## Terragrunt Usage

### DRY Configuration
```hcl
# terragrunt.hcl
terraform {
  source = "../../modules//vpc"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  vpc_cidr = "10.0.0.0/16"
  environment = "dev"
}
```

### Remote State
```hcl
# root terragrunt.hcl
remote_state {
  backend = "s3"
  config = {
    bucket = "terraform-state-${get_aws_account_id()}"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Security Scanning

### tfsec
```bash
# Basic scan
tfsec .

# JSON output
tfsec . --format json

# Ignore specific checks
tfsec . --exclude AWS001,AWS002

# Custom checks
tfsec . --custom-check-dir ./custom-checks
```

### Checkov
```bash
# Install checkov
pip install checkov

# Scan Terraform
checkov -d .

# Skip specific checks
checkov -d . --skip-check CKV_AWS_20
```

## Cost Estimation

### Infracost
```bash
# Install
brew install infracost

# Configure API key
infracost configure set api_key YOUR_API_KEY

# Estimate costs
infracost breakdown --path .

# Compare with current
infracost diff --path .
```

## Documentation

### terraform-docs
```bash
# Generate markdown
terraform-docs markdown . > README.md

# Generate with table
terraform-docs markdown table .

# Custom template
terraform-docs markdown . --config .terraform-docs.yml
```

### Configuration
```yaml
# .terraform-docs.yml
formatter: markdown table
output:
  file: README.md
  mode: inject
settings:
  anchor: true
  color: true
  default: true
  escape: true
  indent: 2
  required: true
  sensitive: true
  type: true
```

## CI/CD Integration

### GitHub Actions
```yaml
name: Terraform CI
on: [push, pull_request]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.6.6
      
      - run: terraform fmt -check
      - run: terraform init
      - run: terraform validate
      - run: terraform plan
```

### GitLab CI
```yaml
stages:
  - validate
  - plan
  - apply

terraform-validate:
  stage: validate
  script:
    - terraform fmt -check
    - terraform init
    - terraform validate

terraform-plan:
  stage: plan
  script:
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - tfplan
```

## Templates

Templates are available in `~/.config/terraform/templates/`:
- `main.tf` - Basic configuration
- `variables.tf` - Variable definitions
- `outputs.tf` - Output definitions
- `module.tf` - Module usage example
- `terragrunt.hcl` - Terragrunt configuration
- `Makefile` - Common commands
- `terraform-workflow.yml` - GitHub Actions

## Common Patterns

### Remote State Data Source
```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "example" {
  subnet_id = data.terraform_remote_state.network.outputs.subnet_id
}
```

### Dynamic Blocks
```hcl
resource "aws_security_group" "example" {
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidrs
    }
  }
}
```

### Local Values
```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
  
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_instance" "example" {
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-instance"
  })
}
```

## Troubleshooting

### State Lock Issues
```bash
# Force unlock
terraform force-unlock LOCK_ID

# Manual unlock (S3 + DynamoDB)
aws dynamodb delete-item \
  --table-name terraform-locks \
  --key '{"LockID":{"S":"bucket/path/to/state"}}'
```

### Import Existing Resources
```bash
# Import resource
terraform import aws_instance.example i-1234567890abcdef0

# Generate configuration
terraform show -no-color > imported.tf
```

### Debugging
```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Specific provider debugging
export TF_LOG_PROVIDER=DEBUG
```

## Tips

1. **Always use version constraints** for providers and modules
2. **Store state remotely** with locking for team collaboration
3. **Use workspaces** for environment separation
4. **Validate and format** before committing
5. **Review plans carefully** before applying
6. **Tag all resources** for cost tracking
7. **Use data sources** instead of hardcoding
8. **Modularize** common infrastructure patterns
9. **Document** with terraform-docs
10. **Scan for security** issues regularly