# Google Cloud CLI and Tools

Complete Google Cloud Platform development environment with gcloud CLI, Terraform, and more.

## Installation

```bash
./tools-cli/gcloud/setup.sh
```

## What Gets Installed

### Core Tools
- **gcloud** - Google Cloud CLI with all components
- **gsutil** - Cloud Storage command-line tool
- **kubectl** - Kubernetes CLI (via gcloud components)
- **Cloud SQL Proxy** - Secure database connections
- **Terraform** - Infrastructure as Code
- **Various emulators** - Firestore, Datastore, Pub/Sub

### Components
- gke-gcloud-auth-plugin - GKE authentication
- cloud-build-local - Local Cloud Build
- app-engine-python - App Engine Python support
- Multiple emulators for local development

## Initial Setup

### Authentication
```bash
# Initialize gcloud
gcloud init

# Login
gcloud auth login

# Application default credentials
gcloud auth application-default login

# Service account
gcloud auth activate-service-account --key-file=key.json
```

### Configuration
```bash
# List configurations
gcloud config configurations list

# Create new configuration
gcloud config configurations create my-config

# Set project
gcloud config set project PROJECT_ID

# Set default region/zone
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

# View current config
gcloud config list
```

## Common Operations

### Projects
```bash
# List projects
gcloud projects list
gprojects  # alias

# Switch project
gcloud config set project PROJECT_ID
gcpset PROJECT_ID  # function

# Create project
gcloud projects create PROJECT_ID --name="My Project"

# Get current project
gcloud config get-value project
gproject  # alias
```

### Compute Engine

#### Instances
```bash
# List instances
gcloud compute instances list
gcels  # alias

# Create instance
gcloud compute instances create my-instance \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --image-family=debian-11 \
  --image-project=debian-cloud

# SSH to instance
gcloud compute ssh my-instance --zone=us-central1-a
gcessh my-instance  # alias

# Start/stop instances
gcestart my-instance --zone=us-central1-a
gcestop my-instance --zone=us-central1-a

# Delete instance
gcloud compute instances delete my-instance --zone=us-central1-a
```

#### Networking
```bash
# List networks
gcloud compute networks list

# Create firewall rule
gcloud compute firewall-rules create allow-http \
  --allow tcp:80,tcp:443 \
  --source-ranges 0.0.0.0/0

# List firewall rules
gcloud compute firewall-rules list
```

### Cloud Storage

#### Bucket Operations
```bash
# List buckets
gsutil ls
gcsls  # alias

# Create bucket
gsutil mb gs://my-bucket
gcsmb gs://my-bucket  # alias

# Remove bucket
gsutil rb gs://my-bucket
gcsrb gs://my-bucket  # alias

# Bucket size
gsutil du -sh gs://my-bucket
gcssize my-bucket  # function
```

#### File Operations
```bash
# Upload file
gsutil cp file.txt gs://my-bucket/
gcscp file.txt gs://my-bucket/  # alias

# Download file
gsutil cp gs://my-bucket/file.txt .

# Upload directory
gsutil -m cp -r local-dir gs://my-bucket/

# Sync directories
gsutil rsync -r local-dir gs://my-bucket/remote-dir
gcsrsync local-dir gs://my-bucket/remote-dir  # alias

# Remove file
gsutil rm gs://my-bucket/file.txt
gcsrm gs://my-bucket/file.txt  # alias

# Copy between buckets
gsutil -m cp -r gs://source-bucket/* gs://dest-bucket/
gcscopy source-bucket dest-bucket  # function
```

### Kubernetes Engine (GKE)

#### Cluster Management
```bash
# List clusters
gcloud container clusters list
gkels  # alias

# Create cluster
gcloud container clusters create my-cluster \
  --zone=us-central1-a \
  --num-nodes=3 \
  --machine-type=e2-standard-2

# Get credentials
gcloud container clusters get-credentials my-cluster \
  --zone=us-central1-a
gkeget my-cluster  # alias

# Delete cluster
gcloud container clusters delete my-cluster --zone=us-central1-a

# Resize cluster
gcloud container clusters resize my-cluster \
  --num-nodes=5 \
  --zone=us-central1-a
```

### Cloud Functions
```bash
# List functions
gcloud functions list
gcfls  # alias

# Deploy function
gcloud functions deploy my-function \
  --runtime python39 \
  --trigger-http \
  --entry-point main \
  --allow-unauthenticated
gcfdeploy my-function  # alias

# View logs
gcloud functions logs read my-function
gcflogs my-function  # alias

# Delete function
gcloud functions delete my-function
```

### Cloud Run
```bash
# List services
gcloud run services list
gcrls  # alias

# Deploy service
gcloud run deploy my-service \
  --image gcr.io/PROJECT_ID/my-image \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
gcrdeploy my-service  # alias

# Get service URL
gcloud run services describe my-service \
  --platform managed \
  --region us-central1 \
  --format 'value(status.url)'
```

### App Engine
```bash
# Deploy application
gcloud app deploy
gaedeploy  # alias

# View logs
gcloud app logs tail
gaelogs  # alias

# Browse application
gcloud app browse
gaebrowse  # alias

# List versions
gcloud app versions list

# Stop version
gcloud app versions stop VERSION_ID
```

### BigQuery
```bash
# List datasets
bq ls
bqls  # alias

# Create dataset
bq mk my_dataset

# Query
bq query --use_legacy_sql=false \
  'SELECT * FROM `project.dataset.table` LIMIT 10'
bqquery 'SELECT ...'  # alias

# Load data
bq load --source_format=CSV \
  my_dataset.my_table \
  gs://my-bucket/data.csv \
  schema.json

# Export data
bq extract my_dataset.my_table \
  gs://my-bucket/export.csv
```

### Cloud SQL
```bash
# List instances
gcloud sql instances list

# Create instance
gcloud sql instances create my-instance \
  --database-version=POSTGRES_14 \
  --tier=db-f1-micro \
  --region=us-central1

# Connect with proxy
cloud-sql-proxy PROJECT_ID:REGION:INSTANCE_NAME
sqlproxy PROJECT_ID:REGION:INSTANCE_NAME  # function

# Create database
gcloud sql databases create my-database \
  --instance=my-instance

# Create user
gcloud sql users create my-user \
  --instance=my-instance \
  --password=my-password
```

### IAM & Security

#### Service Accounts
```bash
# List service accounts
gcloud iam service-accounts list
giamls  # alias

# Create service account
gcloud iam service-accounts create my-sa \
  --display-name="My Service Account"

# Create key
gcloud iam service-accounts keys create key.json \
  --iam-account=my-sa@PROJECT_ID.iam.gserviceaccount.com

# Grant role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member='serviceAccount:my-sa@PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/editor'
```

#### Roles and Permissions
```bash
# List roles
gcloud iam roles list
giamroles  # alias

# Describe role
gcloud iam roles describe roles/editor

# Get IAM policy
gcloud projects get-iam-policy PROJECT_ID
```

### Pub/Sub
```bash
# List topics
gcloud pubsub topics list
gpubtopics  # alias

# Create topic
gcloud pubsub topics create my-topic

# List subscriptions
gcloud pubsub subscriptions list
gpubsubs  # alias

# Create subscription
gcloud pubsub subscriptions create my-sub \
  --topic=my-topic

# Publish message
gcloud pubsub topics publish my-topic \
  --message="Hello World"

# Pull messages
gcloud pubsub subscriptions pull my-sub --auto-ack
```

## Terraform with GCP

### Basic Configuration
```hcl
# Provider configuration
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
```

### Common Commands
```bash
# Initialize
terraform init
tfi  # alias

# Plan changes
terraform plan
tfp  # alias

# Apply changes
terraform apply
tfa  # alias

# Destroy resources
terraform destroy
tfd  # alias

# Format code
terraform fmt
tff  # alias
```

## Configured Aliases

### Core
- `gc` - gcloud
- `gcl` - gcloud config list
- `gcp` - gcloud config set project
- `gcauth` - gcloud auth login

### Services
- `gce` - gcloud compute
- `gke` - gcloud container
- `gcf` - gcloud functions
- `gcr` - gcloud run
- `gae` - gcloud app
- `gcs` - gsutil

### Functions
- `gcpset` - Set project
- `gcpactivate` - Activate service account
- `gceconnect` - SSH to instance
- `gcetunnel` - Create SSH tunnel
- `gkelogs` - Get GKE logs
- `gcscopy` - Copy between buckets
- `gcssize` - Get bucket size
- `gcost` - Cost estimate
- `gservices` - List enabled services
- `genable` - Enable API
- `gdisable` - Disable API

## Local Development

### Emulators
```bash
# Start Firestore emulator
gcloud emulators firestore start

# Start Datastore emulator
gcloud emulators datastore start

# Start Pub/Sub emulator
gcloud emulators pubsub start

# Set environment variables for emulator
$(gcloud emulators firestore env-init)
```

### Cloud Build Local
```bash
# Build locally
cloud-build-local --dryrun=false --config=cloudbuild.yaml .
```

## Best Practices

1. **Use configurations** - Separate configs for different projects
2. **Service accounts** - Use for automation, not personal accounts
3. **Least privilege** - Grant minimal necessary permissions
4. **Enable APIs** - Enable only required APIs
5. **Use regions** - Deploy close to users
6. **Resource labels** - Tag resources for organization
7. **Budget alerts** - Set up cost monitoring
8. **Terraform state** - Store in Cloud Storage
9. **Secrets management** - Use Secret Manager
10. **Audit logging** - Enable Cloud Audit Logs

## Troubleshooting

### Authentication Issues
```bash
# Re-authenticate
gcloud auth login --force

# Check current account
gcloud auth list

# Revoke credentials
gcloud auth revoke

# Application default credentials
gcloud auth application-default login
```

### API Errors
```bash
# Enable required API
gcloud services enable SERVICE_NAME.googleapis.com

# List enabled APIs
gcloud services list --enabled

# Check quotas
gcloud compute project-info describe --project=PROJECT_ID
```

### Permission Errors
```bash
# Check IAM policy
gcloud projects get-iam-policy PROJECT_ID

# Test permissions
gcloud projects test-iam-permissions PROJECT_ID \
  --permissions=compute.instances.create
```

## Templates

Templates are available in `~/.config/gcloud/templates/`:
- `main.tf` - Terraform GCP template
- `function.py` - Cloud Function template
- `Dockerfile.cloudrun` - Cloud Run Dockerfile
- `app.yaml` - App Engine configuration
- `query.sql` - BigQuery query template
- `deploy.sh` - Deployment script