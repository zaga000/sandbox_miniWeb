# miniWeb - Complete AWS DevOps Project

## Objective

Practical implementation of Junior+/Middle level DevOps tasks using **AWS**, **Terraform**, **Git**, and **CI/CD**. This project demonstrates Infrastructure as Code best practices with separate dev/prod environments, automated CI/CD pipelines, and a real Flask web application that displays random quotes from a database.

---

## 📋 Quick Navigation

- [Project Structure](#project-structure)
- [Architecture Overview](#architecture-overview)
- [Quick Start](#quick-start)
- [Application Details](#application-details)
- [CI/CD Pipeline](#cicd-pipeline)
- [Infrastructure Modules](#infrastructure-modules)
- [Deployment Guide](#deployment-guide)
- [Troubleshooting](#troubleshooting)

---

## 📁 Project Structure

```
miniWeb/
├── infra/                          # Terraform Infrastructure as Code
│   ├── environments/               # Environment-specific configurations
│   │   ├── dev/                    # Development environment
│   │   │   ├── main.tf             # Module instantiation for dev
│   │   │   ├── variables.tf        # Dev-specific variables
│   │   │   ├── outputs.tf          # Dev-specific outputs
│   │   │   ├── terraform.tf        # Terraform version constraints
│   │   │   ├── terraform.tfvars    # Dev variable values (in .gitignore)
│   │   │   └── .terraform/         # Dev state (local)
│   │   └── prod/                   # Production environment
│   │       ├── main.tf             # Module instantiation for prod
│   │       ├── variables.tf        # Prod-specific variables
│   │       ├── outputs.tf          # Prod-specific outputs
│   │       ├── terraform.tf
│   │       ├── terraform.tfvars    # Prod variable values (in .gitignore)
│   │       └── .terraform/         # Prod state (local)
│   └── modules/                    # Reusable Terraform modules
│       ├── vpc/                    # Virtual Private Cloud
│       │   ├── main.tf             # VPC, subnets, IGW, NAT resources
│       │   ├── variables.tf        # VPC input variables
│       │   └── output.tf           # VPC outputs (IDs, endpoints)
│       ├── security/               # Security Groups & IAM
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── output.tf
│       ├── compute/                # EC2 & Auto Scaling
│       │   ├── main.tf             # Launch template, ASG configuration
│       │   ├── userdata.tftpl      # EC2 startup script (app deployment)
│       │   └── variables.tf
│       ├── alb/                    # Application Load Balancer
│       │   ├── main.tf             # ALB, target groups, listeners
│       │   ├── variables.tf
│       │   └── output.tf
│       ├── rds/                    # Relational Database Service
│       │   ├── main.tf             # MySQL instance, subnet groups
│       │   ├── variables.tf
│       │   └── output.tf
│       ├── s3/                     # Object Storage (app artifacts)
│       │   ├── main.tf             # S3 bucket for deployments
│       │   ├── variables.tf
│       │   └── output.tf
│       ├── iam/                    # Identity & Access Management
│       │   ├── main.tf             # EC2 roles, instance profiles
│       │   ├── variables.tf
│       │   └── output.tf
│       └── dns/                    # Route53 DNS (optional)
│           ├── main.tf
│           ├── variable.tf
│           └── output.tf
├── app/                            # Flask Web Application
│   ├── main.py                     # Flask server & routes (Quote API)
│   ├── requirements.txt            # Python dependencies
│   └── templates/
│       └── index.html              # HTML template for quote display
├── .github/                        # GitHub integrations
│   └── workflows/
│       └── ci.yml                  # GitHub Actions CI/CD pipeline
├── .gitignore                      # Git ignore rules
└── README.md                       # This file
```

---

## 🏗️ Architecture Overview

### Network Design

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Region: eu-central-1                 │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ VPC (10.0.0.0/16)                                    │  │
│  │                                                       │  │
│  │ ┌──────────────────────────────────────────────────┐ │  │
│  │ │ Public Subnets (AZ1, AZ2)                       │ │  │
│  │ │ 10.0.1.0/24, 10.0.2.0/24                        │ │  │
│  │ │                                                  │ │  │
│  │ │ ┌─────────────────────────────────────────────┐ │ │  │
│  │ │ │ Application Load Balancer                  │ │ │  │
│  │ │ │ (Listens on 80/443)                        │ │ │  │
│  │ │ └──────────────────────────────────────────────┘ │ │  │
│  │ │           ▼                                      │ │  │
│  │ │ Internet Gateway ◄──────────────────────────────┤ │  │
│  │ └──────────────────────────────────────────────────┘ │  │
│  │           ▼                                          │  │
│  │ ┌──────────────────────────────────────────────────┐ │  │
│  │ │ Private Subnets (AZ1, AZ2)                      │ │  │
│  │ │ 10.0.3.0/24, 10.0.4.0/24                        │ │  │
│  │ │                                                  │ │  │
│  │ │ ┌────────────────────────────────────────────┐  │ │  │
│  │ │ │ Auto Scaling Group                         │  │ │  │
│  │ │ │ EC2 Instances (t3.micro/small)             │  │ │  │
│  │ │ │ Running Flask Application                  │  │ │  │
│  │ │ └────────────────────────────────────────────┘  │ │  │
│  │ │           ▼                                      │ │  │
│  │ │ ┌────────────────────────────────────────────┐  │ │  │
│  │ │ │ RDS MySQL Database                         │  │ │  │
│  │ │ │ (Multi-AZ, Automated Backups)              │  │ │  │
│  │ │ └────────────────────────────────────────────┘  │ │  │
│  │ │           ▼                                      │ │  │
│  │ │ ┌────────────────────────────────────────────┐  │ │  │
│  │ │ │ S3 Bucket                                  │  │ │  │
│  │ │ │ (Application Artifacts)                    │  │ │  │
│  │ │ └────────────────────────────────────────────┘  │ │  │
│  │ └──────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Key Components

| Component | Purpose | Location |
|-----------|---------|----------|
| **VPC** | Isolated network with 10.0.0.0/16 CIDR | Spans 2 AZ |
| **Public Subnets (2)** | ALB placement | 10.0.1.0/24, 10.0.2.0/24 |
| **Private Subnets (2)** | EC2 and RDS placement | 10.0.3.0/24, 10.0.4.0/24 |
| **Internet Gateway** | Route to internet | Attached to VPC |
| **NAT Gateway** | Outbound internet for private subnets | In public subnet |
| **ALB** | Distribute traffic to EC2 | Public subnets |
| **ASG** | Auto scale EC2 instances (1-2) | Private subnets |
| **EC2 Instances** | Run Flask application | Private subnets |
| **RDS MySQL** | Database with quotes | Private subnets |
| **S3 Bucket** | Store application artifacts | Region: eu-central-1 |

---

## 🚀 Quick Start

### Prerequisites

```bash
# Check you have these installed
terraform version                    # >= 1.0
aws --version                        # Latest AWS CLI
git --version

# AWS credentials configured
aws sts get-caller-identity
```

### Option 1: GitHub Actions (Recommended)

1. **Push to repository:**
   ```bash
   git push origin feature/setup-terraform  # Deploys to dev
   # or
   git push origin main                     # Deploys to prod
   ```

2. **Configure GitHub Secrets:**
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `TF_VAR_DB_PASSWORD`

3. **Monitor pipeline:**
   - Go to **Actions** tab in GitHub repository
   - Watch infrastructure and app deployment

### Option 2: Manual Deployment (Dev)

```bash
cd infra/environments/dev

# Initialize Terraform
terraform init

# Review changes
terraform plan

# Deploy infrastructure
terraform apply

# Get outputs
terraform output
```

### Option 3: Manual Deployment (Prod)

```bash
cd infra/environments/prod

terraform init
terraform plan
terraform apply

# Get ALB DNS to access application
terraform output alb_dns_name
```

---

## 🧪 Application Details

### Flask Quote Application (`/app`)

A simple web application that displays random quotes from a MySQL database.

**Tech Stack:**
- **Framework**: Flask (Python web framework)
- **ORM**: Flask-SQLAlchemy (database abstraction)
- **Driver**: PyMySQL (MySQL connector)
- **Template**: Jinja2 (HTML templates)

**Key Features:**

| Feature | Implementation |
|---------|-----------------|
| **Random Quote Display** | `GET /` fetches random quote from RDS |
| **Health Check** | `GET /health` verifies DB connectivity |
| **Version Tracking** | Shows git SHA on page for deployment tracking |
| **Error Handling** | Graceful fallback if database is empty |

**Source Code Highlights:**

```python
# app/main.py excerpts

@app.route('/')
def index():
    # Fetch random quote from database
    random_quote = Quote.query.order_by(func.rand()).first()
    return render_template('index.html', quote=..., author=...)

@app.route('/health')
def health():
    # Health check for ALB
    try:
        db.session.execute('SELECT 1')
        return {"status": "ok", "db": "connected"}, 200
    except Exception as e:
        return {"status": "error", "message": str(e)}, 500
```

**Environment Variables (set by Terraform):**

```bash
DB_USER         # RDS username (default: "admin")
DB_PASSWORD     # RDS password (sensitive - from secrets)
DB_HOST         # RDS endpoint (e.g., myapp.xxxxx.eu-central-1.rds.amazonaws.com)
DB_NAME         # Database name (default: "quotedb")
GIT_SHA         # Git commit SHA (for version display)
```

**Application Deployment Flow:**

1. Developer commits to Git
2. GitHub Actions triggers CI/CD pipeline
3. Pipeline packages app as `app.zip`
4. Pipeline uploads to S3 bucket
5. Pipeline triggers ASG instance refresh
6. EC2 `user_data` script (from Terraform):
   - Downloads `app.zip` from S3
   - Extracts files
   - Installs Python dependencies (`pip install -r requirements.txt`)
   - Starts Flask application
   - ALB health checks verify app is running

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow (`.github/workflows/ci.yml`)

**Trigger Events:**
- Push to `main` branch → Deploy to **Prod**
- Push to `feature/setup-terraform` branch → Deploy to **Dev**
- Manual trigger via workflow_dispatch

**Environment Selection:**
```yaml
TARGET_ENV: ${{ github.ref == 'main' && 'prod' || 'dev'}}
```

**Pipeline Jobs:**

#### 1. Terraform Job (Infrastructure)

```
┌─────────────────────────────────────────┐
│ Job: Terraform                          │
├─────────────────────────────────────────┤
│ 1. Checkout code                        │
│ 2. Setup Terraform                      │
│ 3. Configure AWS credentials            │
│ 4. terraform init                       │
│ 5. terraform plan -out=tfplan           │
│ 6. terraform apply -auto-approve tfplan │
└─────────────────────────────────────────┘
```

#### 2. Deploy Job (Application)

```
┌──────────────────────────────────────────────┐
│ Job: Deploy (depends on Terraform)           │
├──────────────────────────────────────────────┤
│ 1. Checkout code                             │
│ 2. Configure AWS credentials                 │
│ 3. Package app: zip -r app.zip app/          │
│ 4. Find S3 bucket (via AWS API)              │
│ 5. Upload: aws s3 cp app.zip s3://bucket/    │
│ 6. Find ASG name (via AWS API)               │
│ 7. Trigger rolling update (instance refresh) │
│ 8. Wait for instances to become healthy      │
└──────────────────────────────────────────────┘
```

**Key Features:**
- ✅ Separate infrastructure and application jobs
- ✅ Automatic environment selection (dev vs prod)
- ✅ AWS credentials from GitHub Secrets
- ✅ Zero-downtime deployment via rolling update
- ✅ Automatic artifact discovery and deployment
- ✅ Health check verification

---

## 📊 Infrastructure Modules

### Module Reference

All modules follow Terraform best practices:

| Module | Responsibility |
|--------|-----------------|
| **vpc** | Network foundation (subnets, routing, NAT) |
| **security** | Access control (SGs, NACLs, IAM roles) |
| **compute** | EC2 lifecycle management (ASG, templates) |
| **alb** | Traffic distribution (load balancer, routing) |
| **rds** | Database service (MySQL, backups, replicas) |
| **s3** | Artifact storage (versioning, policies) |
| **iam** | Identity management (roles, instance profiles) |
| **dns** | Domain management (Route53 records) |

### VPC Module

**Resources Created:**
- 1 VPC with custom CIDR
- 2 public subnets (1 per AZ)
- 2 private subnets (1 per AZ)
- Internet Gateway
- NAT Gateway with Elastic IP
- Route tables for public/private traffic

**Outputs:**
```hcl
vpc_id
public_subnet_ids
private_subnet_ids
nat_gateway_ip
```

### Security Module

**Resources Created:**
- ALB Security Group (allow 80, 443 from 0.0.0.0/0)
- App Security Group (allow from ALB only)
- RDS Security Group (allow from App SG only)
- EIC Security Group (EC2 Instance Connect)
- IAM role for EC2 instances (S3 access)

### Compute Module

**Key Configuration:**

```hcl
resource "aws_launch_template" "web_launch_template" {
  # User data script automatically deploys app
  user_data = base64encode(templatefile("userdata.tftpl", {
    bucket_name  = var.artifact_bucket_name
    rds_endpoint = var.rds_endpoint
    db_user      = var.db_username
    db_password  = var.db_password
    db_name      = var.db_name
  }))
}

resource "aws_autoscaling_group" "web_asg" {
  # Min/max instances based on environment
  min_size             = 1  # dev
  max_size             = 2  # prod
  desired_capacity     = 1  # dev, 2 for prod
  
  # Rolling updates for zero downtime
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
    }
  }
}
```

### RDS Module

**Configuration:**
- Engine: MySQL 8.0
- Instance Type: t3.micro (dev) / t3.small (prod)
- Allocated Storage: 20 GB
- Backup Retention: 7 days (dev) / 30 days (prod)
- Multi-AZ: false (dev) / true (prod)
- Public Access: false (always)

---

## ⚙️ Environment Configuration

### Development Environment

**Location:** `infra/environments/dev/`

**Characteristics:**
- Single t3.micro EC2 instance
- Minimal resource footprint (cost-effective)
- Single-AZ deployment
- 7-day backup retention
- No production SLA

**Variable Overrides:**
```hcl
# dev/terraform.tfvars
instance_type     = "t3.micro"
db_instance_type  = "db.t3.micro"
instance_count    = 1
backup_retention  = 7
multi_az          = false
environment       = "dev"
```

### Production Environment

**Location:** `infra/environments/prod/`

**Characteristics:**
- 2x t3.small EC2 instances (with ASG scaling)
- Multi-AZ deployment (high availability)
- 30-day backup retention
- Enhanced monitoring
- Production SLA compliance

**Variable Overrides:**
```hcl
# prod/terraform.tfvars
instance_type     = "t3.small"
db_instance_type  = "db.t3.small"
instance_count    = 2
backup_retention  = 30
multi_az          = true
environment       = "prod"
```

---

## 📝 Input Variables Reference

### Common Variables (both environments)

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `project_name` | string | Used for resource naming/tagging | `"myproject"` |
| `environment` | string | Environment identifier | `"dev"` or `"prod"` |
| `vpc_cidr` | string | VPC CIDR block | `"10.0.0.0/16"` |
| `db_username` | string | RDS master username | `"admin"` |
| `db_password` | string (sensitive) | RDS master password | `"Secure!Pass123"` |
| `db_name` | string | Initial database name | `"quotedb"` |

### Environment-Specific Variables

| Variable | Dev | Prod |
|----------|-----|------|
| `instance_type` | `t3.micro` | `t3.small` |
| `instance_count` | `1` | `2` |
| `db_instance_type` | `db.t3.micro` | `db.t3.small` |
| `backup_retention` | `7` | `30` |
| `multi_az` | `false` | `true` |

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **IaC** | Terraform 1.x | Infrastructure as Code |
| **Cloud** | AWS | Cloud provider (eu-central-1) |
| **Networking** | VPC, ALB, NAT | Network infrastructure |
| **Compute** | EC2, ASG | Scalable compute resources |
| **Database** | RDS MySQL | Persistent data storage |
| **Storage** | S3 | Application artifacts |
| **Security** | Security Groups, IAM | Access control |
| **Application** | Python Flask | Web framework |
| **ORM** | SQLAlchemy | Database abstraction |
| **CI/CD** | GitHub Actions | Automation pipeline |
| **DNS** | Route53 (optional) | Domain management |

---

## 📡 Accessing the Application

### Get Load Balancer DNS

```bash
cd infra/environments/dev  # or prod

# Method 1: Using terraform output
terraform output alb_dns_name

# Method 2: Using AWS CLI
aws elbv2 describe-load-balancers \
  --region eu-central-1 \
  --query 'LoadBalancers[0].DNSName'
```

### Access Application

```bash
# Get ALB DNS
ALB_DNS=$(terraform output -raw alb_dns_name)

# Visit web application
curl http://$ALB_DNS/

# Health check
curl http://$ALB_DNS/health
```

### Health Check Response

**Success:**
```json
{"status": "ok", "db": "connected"}
```

**Failure:**
```json
{"status": "error", "message": "Connection refused"}
```

---

## 🔐 Security Best Practices

### Secrets Management

✅ **What we do right:**
- Database passwords stored in GitHub Secrets (not in code)
- AWS credentials only in CI/CD, never hardcoded
- EC2 instances use IAM roles (no embedded keys)
- `terraform.tfvars` in `.gitignore`
- Sensitive variables marked with `sensitive = true`

❌ **Never do this:**
- Commit `.tfvars` files to Git
- Hardcode passwords in Terraform code
- Store AWS keys in environment variables locally
- Use root AWS access keys for automation

### Network Security

✅ **What we implement:**
- EC2 instances in **private subnets** (no direct internet)
- RDS in **private subnets** (database never public)
- ALB only resource in **public subnets**
- Security Groups with **least privilege** rules
- NACLs for additional network filtering

### Application Security

✅ **What we include:**
- No hardcoded secrets in application code
- Environment variable-based configuration
- SQL queries via ORM (SQLAlchemy) - prevents injection
- Health check endpoint for monitoring
- Deployment verification via health checks

---

## 🗑️ Destroying Resources

### Clean Up Dev Environment

```bash
cd infra/environments/dev
terraform destroy
```

### Clean Up Prod Environment

```bash
cd infra/environments/prod
terraform destroy
```

### Destroy Everything

```bash
# Be very careful with production!
cd infra/environments/prod && terraform destroy
cd ../dev && terraform destroy
```

**⚠️ Warning:** Destroying production will:
- Delete RDS database (data loss!)
- Delete EC2 instances
- Delete S3 artifacts
- Delete VPC and all networking

---

## 🔧 Troubleshooting

### EC2 Instances Not Running

**Check ASG status:**
```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names myproject-web-asg \
  --region eu-central-1
```

**Check instance logs:**
```bash
# SSH via Systems Manager Session Manager
aws ssm start-session --target i-xxxxxxxxxx

# View user_data logs
cat /var/log/user-data.log
tail -f /var/log/messages
```

### Application Not Responding

**Check ALB target health:**
```bash
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:...
```

**Check security group rules:**
```bash
# Verify ALB can reach targets
aws ec2 describe-security-groups \
  --group-ids sg-xxxxxxxx \
  --region eu-central-1
```

### Database Connection Failed

**Test RDS connectivity:**
```bash
# Get RDS endpoint from Terraform
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)

# Test connection
mysql -h $RDS_ENDPOINT -u admin -p

# Or test from EC2
aws ssm start-session --target i-xxxxxxxx
mysql -h myapp.xxxxx.rds.amazonaws.com -u admin -p
```

**Check RDS security group:**
```bash
# Verify inbound rule: port 3306 from App SG
aws ec2 describe-security-groups \
  --group-ids sg-rds-xxxxxxxx
```

### S3 Artifact Not Found

**List S3 contents:**
```bash
aws s3 ls s3://myproject-artifacts/
```

**Check IAM permissions:**
```bash
# Verify EC2 instance has S3 access
aws iam get-role-policy \
  --role-name myproject-ec2-role \
  --policy-name s3-access
```

### CI/CD Pipeline Failures

**Check GitHub Actions logs:**
1. Navigate to **Actions** tab
2. Click failed workflow
3. Expand job logs
4. Look for error messages

**Common issues:**
- Missing AWS credentials in secrets
- Terraform plan shows destructive changes
- Database password contains special characters
- IAM permissions insufficient

---

## 📈 Monitoring

### CloudWatch Metrics

**Auto-scaling group:**
- Instances in service
- Pending instances
- Terminating instances
- Scaling activities

**Load balancer:**
- Request count
- Target response time
- HTTP 4xx/5xx errors
- Unhealthy host count

**RDS database:**
- Connections
- CPU utilization
- Storage space
- Read/write latency

**EC2 instances:**
- CPU utilization
- Network in/out
- Disk I/O
- Status checks

### Application Logs

**Locations:**
- `/var/log/user-data.log` - Deployment script output
- `/var/log/messages` - System logs
- CloudWatch Logs - If configured

**View logs:**
```bash
# Via EC2 Instance Connect
aws ssm start-session --target i-xxxxxxxx
sudo tail -f /var/log/user-data.log
```

---

## 📝 Configuration Reference

### Creating `terraform.tfvars`

**Dev environment:**
```hcl
# infra/environments/dev/terraform.tfvars
project_name    = "myproject"
environment     = "dev"
instance_type   = "t3.micro"
db_username     = "admin"
db_password     = "DevPassword123!"
db_name         = "quotedb"
```

**Prod environment:**
```hcl
# infra/environments/prod/terraform.tfvars
project_name    = "myproject"
environment     = "prod"
instance_type   = "t3.small"
db_username     = "admin"
db_password     = "ProdPassword123!"
db_name         = "quotedb"
```

### GitHub Actions Secrets

Set in repository Settings → Secrets and variables → Actions:

```
AWS_ACCESS_KEY_ID          = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_ACCESS_KEY      = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
TF_VAR_DB_PASSWORD         = "YourSecurePassword123!"
```

---

## 🚀 Next Steps & Enhancements

### Quick Wins
- [ ] Configure CloudWatch alarms for alerts
- [ ] Add CloudWatch dashboard for monitoring

### Medium Term
- [ ] Implement database read replicas (prod)
- [ ] Add ElastiCache for performance
- [ ] Configure auto-scaling policies
- [ ] Implement blue-green deployment

### Advanced Features
- [ ] Multi-region deployment
- [ ] DynamoDB for caching
- [ ] Lambda for serverless functions
- [ ] API Gateway for REST API
- [ ] CloudFront for CDN
- [ ] Secrets Manager for credential rotation

---

## 📞 Support & Issues

For questions or problems:

1. **Check CloudWatch logs** - Most issues are visible in logs
2. **Verify AWS credentials** - Test with `aws sts get-caller-identity`
3. **Review Terraform plan** - Run `terraform plan` to see what's happening
4. **Check security groups** - Verify inbound/outbound rules
5. **Test connectivity** - Use `curl` and `telnet` to verify endpoints

---

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [EC2 Auto Scaling Guide](https://docs.aws.amazon.com/autoscaling/)
- [RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Last Updated:** 24-02-2026
**Version:** 1.0
**Status:** Production Ready
