# miniWeb - AWS Infrastructure as Code Project

## Objective

Practical implementation of typical Junior+/Middle level DevOps tasks using **AWS**, **Terraform**, **Git**, and **CI/CD** through the example of deploying a minimal but fully functional web infrastructure.

---

## 📋 Architecture

### What's Deployed

**Networking:**
- VPC with CIDR 10.0.0.0/16
- 2 public subnets across different AZ (10.0.1.0/24, 10.0.2.0/24)
- 2 private subnets across different AZ (10.0.3.0/24, 10.0.4.0/24)
- Internet Gateway for public access
- NAT Gateway for internet access from private subnets

**Load Balancing & Compute:**
- **Application Load Balancer (ALB)** in public subnets
- **Auto Scaling Group (ASG)** with 1-2 EC2 instances in private subnets
- Launch Template with AMI `ami-0191d47ba10441f0b` (t3.micro)
- Rolling update strategy for zero-downtime deployment

**Security:**
- Three Security Groups with least privilege rules:
  - ALB SG: allows inbound HTTP/HTTPS from the internet
  - Web App SG: allows inbound only from ALB
  - RDS SG: allows inbound only from App SG

**Database:**
- RDS (Postgres or MySQL) in private subnets
- **Not publicly accessible** (public access disabled)
- Configured in Multi-AZ setup

**Infrastructure as Code:**
- Entire stack built with **Terraform** using modular structure
- State file: `terraform.tfstate` (locally, for DEV purposes)
- Secrets passed through `terraform.tfvars` (in .gitignore)

---

## 🚀 How to Run the Project

### Prerequisites

- AWS account with permissions to create resources
- Terraform >= 1.0
- AWS CLI configured with credentials
- SSH key `aws-key` in AWS Region (eu-central-1)

### Setup Steps

1. **Clone the repository:**
   ```bash
   git clone <REPO_URL>
   cd miniWeb/infra
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Create `terraform.tfvars` with required variables:**
   ```bash
   cat > terraform.tfvars << EOF
   REGION      = "eu-central-1"
   project_name = "myproject"
   db_username  = "postgres"
   db_password  = "your_secure_password_here"
   db_name      = "myapp_db"
   EOF
   ```

4. **Review the deployment plan:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

6. **Get outputs (ALB DNS, endpoints, etc.):**
   ```bash
   terraform output
   ```

---

## 📁 Repository Structure

```
miniWeb/
├── infra/                          # Terraform configuration
│   ├── main.tf                     # Main modules
│   ├── variables.tf                # Input variables
│   ├── outputs.tf                  # Outputs (in development)
│   ├── providers.tf                # AWS provider
│   ├── terraform.tf                # Terraform versions
│   ├── terraform.tfvars            # Variable values (in .gitignore)
│   ├── terraform.tfstate*          # State file (locally)
│   └── modules/
│       ├── vpc/                    # VPC, subnets, IGW, NAT
│       ├── security/               # Security Groups
│       ├── compute/                # EC2, ASG, Launch Template
│       ├── alb/                    # ALB, Target Groups, Listeners
│       └── rds/                    # RDS Instance, DB Subnet Group
└── README.md                       # This file
```

---

## 📊 Terraform Modules

### `vpc` module
- Creates VPC, IGW, NAT Gateway
- Public and private subnets across multiple AZ
- Routing tables for public/private subnets

### `security` module
- ALB Security Group (80/443 from internet)
- App Security Group (inbound from ALB)
- RDS Security Group (inbound from App SG)
- EIC Security Group (for EC2 Instance Connect)

### `compute` module
- Launch Template with user_data for web service startup
- Auto Scaling Group (min. 1, max. 2 instances)
- Rolling update with zero-downtime deployment
- Target Group attachment for ALB

### `alb` module
- Application Load Balancer in public subnets
- Target Group for EC2 traffic
- Health checks every 30 seconds

### `rds` module
- RDS Instance (MySQL/Postgres)
- DB Subnet Group for private subnets
- Backup retention configured
- **Not publicly accessible**

---

## ⚙️ Input Variables

| Variable | Description | Type | Default |
|----------|-------------|------|----------|
| `REGION` | AWS region | string | `eu-central-1` |
| `project_name` | Project name (for tagging) | string | `myproject` |
| `vpc_cidr` | VPC CIDR block | string | `10.0.0.0/16` |
| `db_username` | DB admin login | string | - |
| `db_password` | DB password (sensitive) | string (sensitive) | - |
| `db_name` | Database name | string | - |

---

## 🛠️ Technology Stack

- **Infrastructure**: AWS (VPC, EC2, ALB, RDS, IAM, Security Groups)
- **IaC**: Terraform 1.x with modular architecture
- **Compute**: Auto Scaling Group with rolling updates for zero-downtime deployment
- **Database**: RDS (Postgres/MySQL) in private network
- **Security**: Security Groups with least privilege rules, private subnets for app and DB
- **Region**: eu-central-1

---

## 🗑️ Destroying Resources

To delete all AWS resources (to save costs):

```bash
cd infra
terraform destroy
```

**⚠️ This will delete everything!** Please confirm before running.

---

## 📝 Developer Notes

### Secrets and Confidentiality

- **Never** commit `terraform.tfvars` (added to `.gitignore`)
- DB password is passed as a sensitive variable (not shown in logs)
- AWS credentials are stored in `~/.aws/credentials`

### Important Files

- [main.tf](infra/main.tf) - modules and their configuration
- [variables.tf](infra/variables.tf) - input variables
- [modules/compute/main.tf](infra/modules/compute/main.tf) - ASG and EC2 configuration
- [modules/security/main.tf](infra/modules/security/main.tf) - Security Groups

### Future Enhancements

- **HTTPS**: add ACM certificate and Route53 record
- **CI/CD**: integrate with GitHub Actions or GitLab CI for automatic `terraform apply`
- **Environments**: split into dev/prod using workspaces
- **Monitoring**: add CloudWatch logs and alerts
- **App Deployment**: configure user_data or SSM for application deployment

---

## 📞 Contact & Support

For questions or issues, please open an Issue in the repository.

---

**Last README Update:** 19-02-2026
