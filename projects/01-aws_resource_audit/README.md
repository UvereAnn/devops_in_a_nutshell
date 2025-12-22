
# AWS Resource Audit Tool
## 📋 Overview
A comprehensive AWS resource auditing and cost management system that provides automated inventory, reporting, and cost analysis for AWS resources across multiple regions and services.

## 🎯 Features
- Multi-Region Support: Audit single regions or all AWS regions
- Multi-Service Coverage: EC2, S3, EBS, Lambda, RDS
- Cost Estimation: 30-day cost analysis using AWS Cost Explorer
- Multiple Output Formats: JSON, CSV, and human-readable text reports
- Notifications: Email and Slack integration
- Dry-Run Mode: Preview API calls without execution
- Comprehensive Logging: Detailed execution logs for debugging

## 📁 Project Structure
```tree
01-aws_resource_audit/
├── README.md                    # This documentation file
├── run_tests.sh                # Test execution script
├── aws_resource_audit.log      # Execution logs (gitignored)
├── .gitignore                 # Git ignore rules
├── LICENSE                    # MIT License file
├── config/
│   ├── config.env             # Configuration file (gitignored)
│   └── config.env.example     # Configuration template
├── scripts/
│   └── aws_resource_list.sh   # Main audit script
├── tests/
│   └── test_aws_resource_list.bats # BATS test suite
├── screenshots/               # Proof of working features and project diagrams
│   ├── Component_Interaction_Diagram.png
│   ├── Process_Flowchart.png
│   ├── System_Architecture_Overview.png
│   └── System_Architecture_Diagram.png
└── reports/                   # Generated reports (gitignored)
```

## 🚀 Quick Start
Prerequisites
AWS CLI configured with appropriate IAM permissions
jq (JSON processor)
Bash 4.4+

## Installation
1. Clone the repository (if applicable):
git clone <repository-url>
cd projects/01-aws_resource_audit

2. Set up configuration:
cp config/config.env.example config/config.env
### Edit config/config.env with your settings

3. Make scripts executable:
chmod +x scripts/aws_resource_list.sh
chmod +x run_tests.sh

## Configuration
Edit config/config.env with your settings:
# AWS Configuration
AWS_REGION=us-east-1

### Email Configuration
- EMAIL_ENABLED=true
- EMAIL_TO="your-email@example.com"
- EMAIL_FROM="your-email@example.com"
- EMAIL_SUBJECT="AWS Resource Audit Report"

### SMTP Configuration
- SMTP_SERVER="smtp.gmail.com"
- SMTP_PORT="587"
- SMTP_USER="your-email@gmail.com"
- SMTP_PASSWORD="your-app-password"

### Slack Configuration
SLACK_WEBHOOK_URL=""

### Cost Estimation Tags
- COST_TAG_KEY="Environment"
- COST_TAG_VALUE="Production"

## IAM Permissions
Create an IAM policy with the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ec2:DescribeVolumes",
        "s3:ListAllMyBuckets",
        "lambda:ListFunctions",
        "rds:DescribeDBInstances",
        "ce:GetCostAndUsage",
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    }
  ]
}
```
## 📖 Usage
### Basic Commands
1. Single region, multiple services:
./scripts/aws_resource_list.sh us-east-1 ec2,s3

2. All regions, specific service:
./scripts/aws_resource_list.sh all ec2

3. Dry run (no API calls):
./scripts/aws_resource_list.sh eu-north-1 ec2,s3 --dry-run

4. Without notifications:
./scripts/aws_resource_list.sh us-west-2 ec2 --no-notify

5. Without cost estimation:
./scripts/aws_resource_list.sh us-east-1 ec2,s3 --no-cost

6. Verbose output:
./scripts/aws_resource_list.sh eu-central-1 ec2 --verbose

## Supported Services
- ec2: Elastic Compute Cloud instances
- s3: Simple Storage Service buckets
- ebs: Elastic Block Store volumes
- lambda: Serverless functions
- rds: Relational Database Service instances

## 🧪 Testing
Run the test suite:
./run_tests.sh

This will:
1. Check for required dependencies (BATS, AWS CLI, jq)
2. Run unit tests for script validation
3. Execute integration tests (dry-run mode)

## Test Coverage
- Script existence and permissions
- Project structure validation
- Configuration file accessibility
- Integration testing with AWS APIs

## 📊 Output
The tool generates reports in the reports/ directory with timestamped filenames:

- aws_audit_YYYYMMDD_HHMMSS_detailed.json - Complete audit data
- aws_audit_YYYYMMDD_HHMMSS_summary.json - Aggregated summary with costs
- aws_audit_YYYYMMDD_HHMMSS_summary.csv - Tabular format for analysis
- aws_audit_YYYYMMDD_HHMMSS_summary.txt - Human-readable executive summary

Note: The reports/ directory is gitignored and should not be committed to version control.

## 🔧 Configuration Details
Email Setup (Gmail Example)
1. Enable 2-factor authentication on your Google account
2. Generate an App Password: https://myaccount.google.com/apppasswords
3. Use the app password as SMTP_PASSWORD

## Slack Integration
1. Create an incoming webhook in your Slack workspace
2. Add the webhook URL to SLACK_WEBHOOK_URL in config.env

## Cost Estimation
- Requires AWS Cost Explorer permissions
- Uses the specified tag (COST_TAG_KEY=COST_TAG_VALUE) to filter costs
- Shows 30-day cost trends

## 🐛 Troubleshooting
Common Issues
1. "AWS credentials not configured"
aws configure

2. Missing dependencies
### Ubuntu/Debian
sudo apt install jq awscli
### macOS
brew install jq awscli

3. Permission denied errors
- Verify IAM policy is attached to your user/role
- Check file permissions: chmod +x scripts/aws_resource_list.sh

4. SMTP authentication failed
- Verify Gmail app password is correct
- Check if "Less secure apps" is enabled (if not using app passwords)

## Debug Mode
###  Run with verbose output:
./scripts/aws_resource_list.sh us-east-1 ec2 --verbose --no-notify --no-cost

### Check logs:
tail -f aws_resource_audit.log

## Git Management
### Files to Commit
- README.md
- config/config.env.example
- scripts/aws_resource_list.sh
- tests/test_aws_resource_list.bats
- run_tests.sh
- .gitignore

## Files to Ignore (gitignored)
- config/config.env (contains secrets)
- reports/ (generated files)
- aws_resource_audit.log (log files)
- Any AWS credentials or secret files

## 🤝 Contributing
1. Fork the repository
2. Create a feature branch (git checkout -b feature/amazing-feature)
3. Add tests for new functionality
4. Ensure all tests pass (./run_tests.sh)
5. Update documentation
6. Submit a pull request

## ⚠️ No License (All Rights Reserved)
This project currently has no explicit license. All rights are reserved by the author.
Contact the author for permissions regarding use, modification, or distribution.

## 👥 Authors
Ivuaku Annastassia - Initial implementation and ongoing maintenance

## 🙏 Acknowledgments
AWS CLI team for the excellent command-line interface
jq developers for the powerful JSON processor
BATS-core team for the Bash Automated Testing System

