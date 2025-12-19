## AWS Resource Audit Script

# Project Overview
This project provides a shell script that lists active AWS resources
(EC2, S3, EBS, Lambda, etc.) in a given region using AWS CLI.
It is designed for DevOps engineers to support cost optimization,
resource auditing, and daily reporting.

# Architecture
User → Shell Script → AWS CLI → AWS APIs

# Prerequisites
- Linux / MacOS
- Bash 4+
- AWS CLI installed
- Configured AWS credentials

# Usage
./aws_resource_list.sh <region> <service>

Examples:
./aws_resource_list.sh us-east-1 ec2
./aws_resource_list.sh ap-south-1 s3

# Supported Services
- EC2
- S3
- EBS
- Lambda
- RDS

# Security Best Practices
- Least-privilege IAM policies
- Script permission: chmod 771
- No hard-coded credentials

# Cron Job Example
0 8 * * * /home/ubuntu/scripts/aws_resource_list.sh us-east-1 ec2 >> report.txt


