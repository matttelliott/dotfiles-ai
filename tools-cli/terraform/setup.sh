#!/bin/bash
# Terraform installation and setup

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
    PLATFORM="darwin"
elif [[ "$OS" == "Linux" ]]; then
    PLATFORM="linux"
else
    log_warning "Unknown platform: $OS"
    exit 1
fi

# Detect architecture
case "$ARCH" in
    x86_64)
        ARCH_TF="amd64"
        ;;
    arm64|aarch64)
        ARCH_TF="arm64"
        ;;
    *)
        log_warning "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

install_terraform() {
    log_info "Installing Terraform..."
    
    if command -v terraform &> /dev/null; then
        log_info "Terraform is already installed: $(terraform version | head -n1)"
        return 0
    fi
    
    # Get latest version
    TF_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    
    if [[ -z "$TF_VERSION" ]]; then
        TF_VERSION="1.6.6"  # Fallback version
    fi
    
    log_info "Installing Terraform ${TF_VERSION}..."
    
    # Download and install
    curl -LO "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_${PLATFORM}_${ARCH_TF}.zip"
    unzip -q "terraform_${TF_VERSION}_${PLATFORM}_${ARCH_TF}.zip"
    sudo mv terraform /usr/local/bin/
    rm "terraform_${TF_VERSION}_${PLATFORM}_${ARCH_TF}.zip"
    
    log_success "Terraform installed"
}

install_terragrunt() {
    log_info "Installing Terragrunt..."
    
    if command -v terragrunt &> /dev/null; then
        log_info "Terragrunt is already installed: $(terragrunt --version)"
        return 0
    fi
    
    # Get latest version
    TG_VERSION=$(curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    
    if [[ -z "$TG_VERSION" ]]; then
        TG_VERSION="0.54.0"  # Fallback version
    fi
    
    # Download and install
    curl -LO "https://github.com/gruntwork-io/terragrunt/releases/download/v${TG_VERSION}/terragrunt_${PLATFORM}_${ARCH_TF}"
    chmod +x "terragrunt_${PLATFORM}_${ARCH_TF}"
    sudo mv "terragrunt_${PLATFORM}_${ARCH_TF}" /usr/local/bin/terragrunt
    
    log_success "Terragrunt installed"
}

install_tflint() {
    log_info "Installing TFLint..."
    
    if command -v tflint &> /dev/null; then
        log_info "TFLint is already installed: $(tflint --version)"
        return 0
    fi
    
    # Install via script
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    
    log_success "TFLint installed"
}

install_tfsec() {
    log_info "Installing tfsec (Terraform security scanner)..."
    
    if command -v tfsec &> /dev/null; then
        log_info "tfsec is already installed"
        return 0
    fi
    
    # Get latest version
    TFSEC_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    
    # Download and install
    curl -LO "https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-${PLATFORM}-${ARCH_TF}"
    chmod +x "tfsec-${PLATFORM}-${ARCH_TF}"
    sudo mv "tfsec-${PLATFORM}-${ARCH_TF}" /usr/local/bin/tfsec
    
    log_success "tfsec installed"
}

install_terraform_docs() {
    log_info "Installing terraform-docs..."
    
    if command -v terraform-docs &> /dev/null; then
        log_info "terraform-docs is already installed"
        return 0
    fi
    
    # Get latest version
    TF_DOCS_VERSION=$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    
    # Download and install
    curl -LO "https://github.com/terraform-docs/terraform-docs/releases/download/v${TF_DOCS_VERSION}/terraform-docs-v${TF_DOCS_VERSION}-${PLATFORM}-${ARCH_TF}.tar.gz"
    tar xzf "terraform-docs-v${TF_DOCS_VERSION}-${PLATFORM}-${ARCH_TF}.tar.gz"
    sudo mv terraform-docs /usr/local/bin/
    rm "terraform-docs-v${TF_DOCS_VERSION}-${PLATFORM}-${ARCH_TF}.tar.gz"
    
    log_success "terraform-docs installed"
}

setup_terraform_config() {
    log_info "Setting up Terraform configuration..."
    
    # Create Terraform config directory
    mkdir -p "$HOME/.terraform.d"
    mkdir -p "$HOME/.terraform.d/plugin-cache"
    
    # Create .terraformrc
    cat > "$HOME/.terraformrc" << 'EOF'
plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
disable_checkpoint = true

credentials "app.terraform.io" {
  # token = "YOUR_TERRAFORM_CLOUD_TOKEN"
}
EOF
    
    log_success "Terraform configuration created"
}

setup_terraform_aliases() {
    log_info "Setting up Terraform aliases..."
    
    local terraform_aliases='
# Terraform aliases
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfaa="terraform apply -auto-approve"
alias tfd="terraform destroy"
alias tfda="terraform destroy -auto-approve"
alias tfv="terraform validate"
alias tff="terraform fmt"
alias tfr="terraform refresh"
alias tfo="terraform output"
alias tfs="terraform state"
alias tfsl="terraform state list"
alias tfss="terraform state show"
alias tfsp="terraform state pull"
alias tfw="terraform workspace"
alias tfwl="terraform workspace list"
alias tfws="terraform workspace select"
alias tfwn="terraform workspace new"

# Terragrunt aliases
alias tg="terragrunt"
alias tgi="terragrunt init"
alias tgp="terragrunt plan"
alias tga="terragrunt apply"
alias tgd="terragrunt destroy"
alias tgv="terragrunt validate"
alias tgf="terragrunt fmt"

# Terraform functions
tfplan() {
    # Plan with output file
    terraform plan -out=tfplan "$@"
}

tfapply() {
    # Apply from plan file
    if [[ -f tfplan ]]; then
        terraform apply tfplan
        rm tfplan
    else
        terraform apply "$@"
    fi
}

tfdiff() {
    # Show plan diff
    terraform plan -detailed-exitcode "$@"
}

tfimport() {
    # Import resource
    terraform import "$@"
}

tfmv() {
    # Move state resource
    terraform state mv "$@"
}

tfrm() {
    # Remove from state
    terraform state rm "$@"
}

tflock() {
    # Lock state
    terraform force-unlock "$@"
}

tfgraph() {
    # Generate dependency graph
    terraform graph | dot -Tpng > terraform-graph.png
    echo "Graph saved to terraform-graph.png"
}

tfcost() {
    # Estimate costs (requires Infracost)
    if command -v infracost &> /dev/null; then
        infracost breakdown --path .
    else
        echo "Infracost not installed"
    fi
}

tfscan() {
    # Security scan
    if command -v tfsec &> /dev/null; then
        tfsec .
    else
        echo "tfsec not installed"
    fi
}

tfdoc() {
    # Generate documentation
    if command -v terraform-docs &> /dev/null; then
        terraform-docs markdown . > README.md
    else
        echo "terraform-docs not installed"
    fi
}

tfclean() {
    # Clean Terraform files
    rm -rf .terraform terraform.tfstate* .terraform.lock.hcl tfplan
    echo "Terraform files cleaned"
}

tfbackup() {
    # Backup state file
    if [[ -f terraform.tfstate ]]; then
        cp terraform.tfstate "terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)"
        echo "State backed up"
    else
        echo "No state file found"
    fi
}

# Workspace management
tfws-new() {
    terraform workspace new "$1"
    terraform workspace select "$1"
}

tfws-delete() {
    terraform workspace select default
    terraform workspace delete "$1"
}

# Module management
tfmod-init() {
    # Initialize new module
    mkdir -p "$1"
    cd "$1"
    touch main.tf variables.tf outputs.tf README.md
    echo "Module $1 initialized"
}
'
    
    # Add to shell RC files
    for rc_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if [[ -f "$rc_file" ]]; then
            if ! grep -q "# Terraform aliases" "$rc_file"; then
                echo "$terraform_aliases" >> "$rc_file"
                log_success "Added Terraform aliases to $(basename $rc_file)"
            else
                log_info "Terraform aliases already configured in $(basename $rc_file)"
            fi
        fi
    done
}

create_terraform_templates() {
    log_info "Creating Terraform templates..."
    
    mkdir -p "$HOME/.config/terraform/templates"
    
    # Main configuration template
    cat > "$HOME/.config/terraform/templates/main.tf" << 'EOF'
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # backend "s3" {
  #   bucket = "terraform-state-bucket"
  #   key    = "path/to/state"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
    }
  }
}
EOF
    
    # Variables template
    cat > "$HOME/.config/terraform/templates/variables.tf" << 'EOF'
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = can(regex("^(dev|staging|prod)$", var.environment))
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
EOF
    
    # Outputs template
    cat > "$HOME/.config/terraform/templates/outputs.tf" << 'EOF'
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}
EOF
    
    # Module template
    cat > "$HOME/.config/terraform/templates/module.tf" << 'EOF'
module "vpc" {
  source = "./modules/vpc"
  
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones
  environment        = var.environment
  project_name       = var.project_name
  
  tags = var.tags
}

module "security_groups" {
  source = "./modules/security-groups"
  
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name
}

module "ec2" {
  source = "./modules/ec2"
  
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.app_sg_id]
  environment        = var.environment
  project_name       = var.project_name
}
EOF
    
    # Terragrunt template
    cat > "$HOME/.config/terraform/templates/terragrunt.hcl" << 'EOF'
include "root" {
  path = find_in_parent_folders()
}

locals {
  environment = "dev"
  region      = "us-east-1"
}

inputs = {
  environment  = local.environment
  aws_region   = local.region
  project_name = "my-project"
}
EOF
    
    # GitHub Actions workflow
    cat > "$HOME/.config/terraform/templates/terraform-workflow.yml" << 'EOF'
name: Terraform CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  TF_VERSION: "1.6.6"
  TF_VAR_environment: ${{ github.ref == 'refs/heads/main' && 'prod' || 'dev' }}

jobs:
  terraform:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: ${{ env.TF_VERSION }}
    
    - name: Terraform Format Check
      run: terraform fmt -check -recursive
    
    - name: Terraform Init
      run: terraform init
    
    - name: Terraform Validate
      run: terraform validate
    
    - name: Terraform Plan
      run: terraform plan -out=tfplan
    
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main'
      run: terraform apply tfplan
EOF
    
    # Makefile for Terraform
    cat > "$HOME/.config/terraform/templates/Makefile" << 'EOF'
.PHONY: help init plan apply destroy fmt validate clean

help:
	@echo "Available targets:"
	@echo "  init     - Initialize Terraform"
	@echo "  plan     - Create execution plan"
	@echo "  apply    - Apply changes"
	@echo "  destroy  - Destroy infrastructure"
	@echo "  fmt      - Format code"
	@echo "  validate - Validate configuration"
	@echo "  clean    - Clean up files"

init:
	terraform init

plan: init
	terraform plan -out=tfplan

apply: plan
	terraform apply tfplan
	@rm -f tfplan

destroy:
	terraform destroy -auto-approve

fmt:
	terraform fmt -recursive

validate: init
	terraform validate
	tflint
	tfsec .

clean:
	rm -rf .terraform terraform.tfstate* .terraform.lock.hcl tfplan

docs:
	terraform-docs markdown . > README.md
EOF
    
    log_success "Terraform templates created"
}

# Main installation
main() {
    log_info "Setting up Terraform and related tools..."
    
    install_terraform
    install_terragrunt
    install_tflint
    install_tfsec
    install_terraform_docs
    setup_terraform_config
    setup_terraform_aliases
    create_terraform_templates
    
    log_success "Terraform setup complete!"
    echo
    echo "Installed tools:"
    echo "  • Terraform - Infrastructure as Code"
    echo "  • Terragrunt - DRY Terraform configurations"
    echo "  • TFLint - Terraform linter"
    echo "  • tfsec - Security scanner"
    echo "  • terraform-docs - Documentation generator"
    echo
    echo "Configuration:"
    echo "  • ~/.terraformrc - Terraform configuration"
    echo "  • ~/.terraform.d/ - Plugins and cache"
    echo
    echo "Quick commands:"
    echo "  tf init          - Initialize"
    echo "  tfp              - Plan"
    echo "  tfa              - Apply"
    echo "  tfd              - Destroy"
    echo "  tfscan           - Security scan"
    echo "  tfdoc            - Generate docs"
    echo
    echo "Templates available in ~/.config/terraform/templates/"
}

main "$@"