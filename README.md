# Task 3: Infrastructure Security and DocumentDB

AWS infrastructure for Node.js demo app with DocumentDB, IAM security, and AWS Inspector.

## What's New in Task 3

### 1. DocumentDB (MongoDB-compatible Database)
- Amazon DocumentDB cluster for the Todo application
- Encrypted storage, automated backups
- Private access only (from EC2 instances in private subnets)

### 2. Security Groups
- **ALB SG**: HTTP/HTTPS from internet
- **EC2 SG**: Port 8080 from ALB, SSH from internet
- **DocumentDB SG**: Port 27017 ONLY from EC2 SG (virtual firewall)

### 3. IAM Policies
- **EC2-DocumentDB Policy**: Allows EC2 to connect to DocumentDB
- **CloudWatch Logs Policy**: Allows writing logs
- **SSM Policy**: Session Manager access (no SSH keys needed)

### 4. AWS Inspector (Bonus)
- Automated security assessment for EC2 instances
- Finds vulnerabilities and deviations from best practices
- SNS notifications for critical/high findings

## Structure

```
terragrunt-infra/
├── root.hcl
├── modules/
│   ├── vpc/main.tf
│   ├── sg/main.tf         (+ DocumentDB SG)
│   ├── alb/main.tf
│   ├── ec2/main.tf        (+ DocumentDB connection)
│   ├── cloudwatch/main.tf
│   ├── docdb/main.tf      (NEW)
│   ├── iam/main.tf        (NEW)
│   └── inspector/main.tf  (NEW)
├── dev/app/{vpc,sg,alb,ec2,cloudwatch,docdb,iam,inspector}/
├── production/app/{...}/
└── load-testing/app/{...}/
```

## Environments

| Environment | Instance Type | DocDB Class | Instances | Purpose |
|---|---|---|---|---|
| dev | t3.micro | db.t3.medium | 1 | Development |
| production | t3.small | db.r6g.large | 2 | Production |
| load-testing | t3.medium | db.t3.medium | 1 | Performance testing |

## Security Flow

```
Internet → ALB (SG: 80/443) → EC2 (SG: 8080) → DocumentDB (SG: 27017)
                ↓                                    ↑
            AWS Inspector                    IAM Role (rds-db:connect)
            (scans EC2)
```

## Usage

```bash
# Deploy all units in dev
cd dev
terragrunt run-all apply

# Deploy all units in production
cd production
terragrunt run-all apply
```

## Cost Estimation

```bash
infracost breakdown --config infracost.yml
```
