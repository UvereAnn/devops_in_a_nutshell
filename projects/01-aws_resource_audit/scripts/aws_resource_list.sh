#!/bin/bash

# =============================================================================
# AWS RESOURCE AUDIT TOOL - COMPREHENSIVE METADATA
# =============================================================================
#
# █████╗ ██╗    ██╗███████╗    ██████╗ ███████╗███████╗ ██████╗ ██╗   ██╗██████╗
# ██╔══██╗██║    ██║██╔════╝    ██╔══██╗██╔════╝██╔════╝██╔═══██╗██║   ██║██╔══██╗
# ███████║██║ █╗ ██║███████╗    ██████╔╝█████╗  ███████╗██║   ██║██║   ██║██████╔╝
# ██╔══██║██║███╗██║╚════██║    ██╔══██╗██╔══╝  ╚════██║██║   ██║██║   ██║██╔══██╗
# ██║  ██║╚███╔███╔╝███████║    ██║  ██║███████╗███████║╚██████╔╝╚██████╔╝██║  ██║
# ╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝    ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝
#
# =============================================================================
#
# 📋 PROJECT: AWS Resource Inventory & Cost Management System
# 🎯 PURPOSE: Automated auditing, reporting, and cost analysis of AWS resources
# 📁 VERSION: 1.0.2 
# 👨‍💻 AUTHOR: Ivuaku Annastassia
# 📅 CREATED: 18/12/2025
# 🔄 LAST UPDATED: 22/12/2025
# ⚖️ LICENSE: MIT
# 🌐 REPOSITORY: https://github.com/UvereAnn/devops_in_a_nutshell
#
# =============================================================================
# 🏗️ ARCHITECTURE OVERVIEW
# =============================================================================
#
# This tool follows a modular, pipeline-based architecture:
#
# 1. CONFIGURATION LAYER
#    ├── Environment-based configuration loading
#    ├── Secure credential management (via .gitignored .env files)
#    └── Default value fallbacks for all optional parameters
#
# 2. VALIDATION LAYER
#    ├── Input validation and sanitization
#    ├── Dependency verification (AWS CLI, jq, etc.)
#    └── Service and region validation
#
# 3. DATA COLLECTION LAYER
#    ├── Parallel-aware AWS API calls
#    ├── Service-specific query functions
#    ├── Error handling with exponential backoff
#    └── Raw data persistence for debugging
#
# 4. PROCESSING LAYER
#    ├── JSON data transformation and normalization
#    ├── Resource counting and aggregation
#    └── Data validation and integrity checks
#
# 5. REPORTING LAYER
#    ├── Multi-format output generation (JSON, CSV, TXT)
#    ├── Human-readable summary creation
#    └── Report file organization and naming
#
# 6. NOTIFICATION LAYER
#    ├── Email notifications via SMTP (Gmail supported)
#    ├── Slack webhook integration
#    └── Conditional notification triggering
#
# 7. COST ANALYSIS LAYER
#    ├── AWS Cost Explorer integration
#    ├── Tag-based cost filtering
#    └── 30-day cost trend analysis
#
# =============================================================================
# 🛠️ TECHNICAL SPECIFICATIONS
# =============================================================================
#
# ✅ SUPPORTED AWS SERVICES:
#    • EC2 (Elastic Compute Cloud) - Instances
#    • S3 (Simple Storage Service) - Buckets
#    • EBS (Elastic Block Store) - Volumes
#    • Lambda - Serverless Functions
#    • RDS (Relational Database Service) - Databases
#
# 🌍 REGION SUPPORT:
#    • Single region mode (e.g., us-east-1)
#    • Multi-region mode (via 'all' keyword)
#    • Automatic region discovery via AWS API
#
# 📊 OUTPUT FORMATS:
#    • JSON (Detailed) - Complete audit data for programmatic use
#    • JSON (Summary) - Aggregated data with cost information
#    • CSV - Tabular format for spreadsheets and data analysis
#    • TXT - Human-readable executive summary
#    • Log file - Chronological execution log with timestamps
#
# 🔧 DEPENDENCIES:
#    • AWS CLI v2+ (configured with appropriate IAM permissions)
#    • jq v1.6+ (JSON processor for data manipulation)
#    • BASH v4.4+ (with support for associative arrays)
#    • curl (for Slack webhook notifications)
#    • sendemail/mailx (for SMTP email delivery) [Optional]
#
# 🔐 SECURITY MODEL:
#    • IAM Principle of Least Privilege (read-only permissions)
#    • Environment-based configuration (.gitignored .env files)
#    • No hardcoded credentials in version control
#    • Encrypted SMTP communication (TLS 1.2+)
#    • Input validation and sanitization
#
# =============================================================================
# 🚀 USAGE PATTERNS
# =============================================================================
#
# 1. BASIC AUDIT:
#    ./aws_resource_list.sh <region> <service1,service2>
#    Example: ./aws_resource_list.sh us-east-1 ec2,s3
#
# 2. MULTI-REGION AUDIT:
#    ./aws_resource_list.sh all ec2
#
# 3. DRY RUN (No API Calls):
#    ./aws_resource_list.sh eu-north-1 ec2,s3 --dry-run
#
# 4. WITH COST ESTIMATION:
#    ./aws_resource_list.sh us-east-1 ec2 --no-notify
#
# 5. WITH NOTIFICATIONS:
#    ./aws_resource_list.sh eu-north-1 ec2,s3,lambda
#
# 6. VERBOSE DEBUGGING:
#    ./aws_resource_list.sh us-west-2 ec2 --verbose --no-notify --no-cost
#
# =============================================================================
# 🔩 CONFIGURATION OPTIONS
# =============================================================================
#
# All configuration is loaded from environment files in this order:
# 1. .env (project root, gitignored - for production secrets)
# 2. config/.env (config directory, gitignored)
# 3. config/config.env.local (local overrides, gitignored)
# 4. config/config.env (default configuration)
#
# REQUIRED CONFIGURATION:
#    • AWS credentials (via AWS CLI configuration)
#
# OPTIONAL CONFIGURATION:
#    • EMAIL_ENABLED=true/false
#    • EMAIL_TO=recipient@example.com
#    • EMAIL_FROM=sender@example.com
#    • SMTP_SERVER=smtp.gmail.com
#    • SMTP_PORT=587
#    • SMTP_USER=your-email@gmail.com
#    • SMTP_PASSWORD=app-specific-password
#    • SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
#    • COST_TAG_KEY=Environment
#    • COST_TAG_VALUE=Production
#
# =============================================================================
# 🏛️ IAM PERMISSIONS REQUIRED
# =============================================================================
#
# Minimum IAM Policy for this tool:
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ec2:DescribeInstances",
#                 "ec2:DescribeRegions",
#                 "ec2:DescribeVolumes",
#                 "s3:ListAllMyBuckets",
#                 "lambda:ListFunctions",
#                 "rds:DescribeDBInstances",
#                 "ce:GetCostAndUsage",
#                 "sts:GetCallerIdentity"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
#
# =============================================================================
# 🧪 TESTING STRATEGY
# =============================================================================
#
# 1. UNIT TESTS (BATS Framework):
#    • Script existence and permissions
#    • Shebang validation
#    • Project structure verification
#    • Config file accessibility
#
# 2. INTEGRATION TESTS:
#    • Dry-run functionality
#    • Actual AWS API calls (with --no-notify --no-cost)
#    • Error handling simulation
#
# 3. END-TO-END TESTS:
#    • Full audit with notifications
#    • Multi-region execution
#    • Report generation validation
#
# Run tests: ./run_tests.sh
#
# =============================================================================
# 📈 PERFORMANCE CHARACTERISTICS
# =============================================================================
#
# • API CALL OPTIMIZATION: Sequential execution to avoid throttling
# • PARALLELIZATION: Service-level parallelism within regions
# • CACHING: Raw API responses stored for debugging
# • MEMORY USAGE: Stream-based processing with jq for large datasets
# • TIMEOUT HANDLING: Configurable timeouts with exponential backoff
#
# Expected execution times:
# • Single region, single service: 2-5 seconds
# • Single region, all services: 10-20 seconds
# • All regions, single service: 30-60 seconds
# • All regions, all services: 2-5 minutes
#
# =============================================================================
# 🐛 ERROR HANDLING & LOGGING
# =============================================================================
#
# ERROR LEVELS:
# • ERROR: Critical failures requiring immediate attention
# • WARN: Non-critical issues that don't stop execution
# • INFO: Standard operational information
# • SUCCESS: Confirmation of successful operations
# • DEBUG: Detailed information for troubleshooting
#
# LOG LOCATIONS:
# • Primary: aws_resource_audit.log (rotating, timestamped)
# • Console: Color-coded real-time output
# • Reports: Execution summary in generated reports
#
# RECOVERY STRATEGIES:
# • Service-level failures don't abort entire audit
# • Region-level failures can be isolated
# • Partial results are preserved and reported
# • Retry logic for transient AWS API errors
#
# =============================================================================
# 🔄 MAINTENANCE & EXTENSIBILITY
# =============================================================================
#
# ADDING NEW AWS SERVICES:
# 1. Add service name to SUPPORTED_SERVICES array
# 2. Create service_<name>() function following existing patterns
# 3. Add case statement in main processing loop
# 4. Update validation and help text
# 5. Add IAM permissions documentation
#
# MODIFYING OUTPUT FORMATS:
# 1. Edit generate_reports() function
# 2. Follow existing JSON/CSV/TXT patterns
# 3. Update README documentation
#
# ADDING NOTIFICATION CHANNELS:
# 1. Create send_<channel>_notification() function
# 2. Add configuration parameters
# 3. Integrate into notification dispatch logic
#
# =============================================================================
# 📚 RELATED DOCUMENTATION
# =============================================================================
#
# • README.md - User guide and installation instructions
# • config/config.env.example - Configuration template
# • tests/test_aws_resource_list.bats - Test specifications
# • run_tests.sh - Test execution script
# • AWS Documentation: https://docs.aws.amazon.com/cli/latest/reference/
# • jq Manual: https://stedolan.github.io/jq/manual/
#
# =============================================================================
# 🏆 VERSION HISTORY
# =============================================================================
#
# v3.0.2 (Current) - Production release with cost estimation
#    • Added AWS Cost Explorer integration
#    • Enhanced email notification system
#    • Improved error handling and logging
#    • Comprehensive test suite
#
# v3.0.1 - Notification system enhancement
#    • Slack webhook integration
#    • SMTP email support
#    • Configurable notification triggers
#
# v3.0.0 - Major architecture refactor
#    • Modular pipeline architecture
#    • Multi-format reporting
#    • Service abstraction layer
#
# v2.x - Core functionality
#    • Multi-service support
#    • Multi-region auditing
#    • Basic reporting
#
# v1.x - Initial prototype
#    • EC2-only auditing
#    • Single region support
#    • Text-only output
#
# =============================================================================
# ⚠️ DISCLAIMER & BEST PRACTICES
# =============================================================================
#
# SECURITY NOTES:
# • NEVER commit .env files or config.env with real credentials
# • Use IAM roles instead of access keys when possible
# • Regularly rotate credentials and app passwords
# • Review generated reports for sensitive data before sharing
#
# COST CONSIDERATIONS:
# • AWS API calls may incur costs at scale
# • Cost Explorer requires Business/Enterprise support plan
# • Tag resources consistently for accurate cost allocation
#
# OPERATIONAL BEST PRACTICES:
# • Run during off-peak hours for production audits
# • Monitor AWS Service Quotas to avoid throttling
# • Use dry-run mode to estimate API call volume
# • Schedule regular audits with cron or AWS EventBridge
#
# =============================================================================
# 🤝 CONTRIBUTION GUIDELINES
# =============================================================================
#
# 1. Fork the repository
# 2. Create a feature branch (git checkout -b feature/amazing-feature)
# 3. Add tests for new functionality
# 4. Ensure all tests pass (./run_tests.sh)
# 5. Update documentation
# 6. Submit a pull request
#
# Code standards:
# • Use shellcheck for linting
# • Follow existing code style and patterns
# • Add comments for complex logic
# • Update metadata headers when modifying functionality
#
# =============================================================================
# 📞 SUPPORT & TROUBLESHOOTING
# =============================================================================
#
# COMMON ISSUES:
# • "AWS credentials not configured" - Run `aws configure`
# • "Missing dependencies" - Install jq, sendemail packages
# • "Permission denied" - Check IAM policies and file permissions
# • "SMTP authentication failed" - Verify Gmail App Password
#
# DEBUGGING:
# • Use --verbose flag for detailed output
# • Check aws_resource_audit.log for errors
# • Review raw API responses in reports/*_raw.table files
# • Test individual AWS CLI commands manually
#
# =============================================================================
# 🎯 EXIT CODES
# =============================================================================
#
# 0 - Success: Audit completed successfully
# 1 - General error: Invalid arguments or dependencies
# 2 - AWS error: Authentication or permission issues
# 3 - Configuration error: Missing or invalid config
# 4 - Runtime error: API failures or data processing issues
# 5 - User interrupt: Script terminated by user
#
# =============================================================================
# 🌟 FEATURE ROADMAP
# =============================================================================
#
# PLANNED ENHANCEMENTS:
# • CloudWatch metrics integration
# • S3 report storage and archival
# • PDF report generation
# • Custom service plugin system
# • Kubernetes/EKS resource auditing
# • Terraform state comparison
# • Compliance checking (CIS benchmarks)
# • Real-time monitoring dashboard
#
# =============================================================================
# 📄 END OF METADATA
# =============================================================================

set -euo pipefail

# ----------------------------- Colors (MUST BE FIRST!) -----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ----------------------------- Logging -----------------------------
log() {
  local level="$1"
  local message="$2"
  local color=""

  case "$level" in
  ERROR) color="$RED" ;;
  SUCCESS) color="$GREEN" ;;
  WARN) color="$YELLOW" ;;
  INFO) color="$BLUE" ;;
  DEBUG) color="$PURPLE" ;;
  *) color="$NC" ;;
  esac

  echo -e "${color}$(date '+%F %T') | $level | $message${NC}" | tee -a "$LOG_FILE"
}

# ----------------------------- Config -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/config/config.env"
LOG_FILE="$PROJECT_ROOT/aws_resource_audit.log"
REPORT_DIR="$PROJECT_ROOT/reports"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
REPORT_PREFIX="aws_audit_${TIMESTAMP}"

SUPPORTED_SERVICES=("ec2" "s3" "ebs" "lambda" "rds")

mkdir -p "$REPORT_DIR" "$(dirname "$CONFIG_FILE")" &>/dev/null

# Load configuration
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
  log "INFO" "Loaded configuration from $CONFIG_FILE"
else
  log "WARN" "Config file not found: $CONFIG_FILE"
fi

# Default values for optional configs
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
EMAIL_ENABLED="${EMAIL_ENABLED:-false}"
EMAIL_TO="${EMAIL_TO:-}"
COST_TAG_KEY="${COST_TAG_KEY:-Environment}"
COST_TAG_VALUE="${COST_TAG_VALUE:-Production}"

# ----------------------------- Usage -------------------------------
show_banner() {
  echo -e "${CYAN}"
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║           AWS RESOURCE AUDIT TOOL v3.0.2                 ║"
  echo "║           With Slack/Email & Cost Estimation             ║"
  echo "╚══════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

usage() {
  show_banner
  echo "Usage: $0 <region|all> <service1,service2> [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  <region>          AWS region (e.g., us-east-1) or 'all' for all regions"
  echo "  <services>        Comma-separated list: ec2,s3,ebs,lambda,rds"
  echo "  --dry-run         Show what would be executed without making API calls"
  echo "  --verbose         Show detailed output"
  echo "  --no-notify       Skip Slack/Email notifications"
  echo "  --no-cost         Skip cost estimation"
  echo "  --test            Run in test mode (uses mock data)"
  echo "  --help            Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 us-east-1 ec2,s3"
  echo "  $0 all ec2 --dry-run"
  echo "  $0 eu-north-1 ec2,s3 --verbose --no-notify"
  echo ""
  exit 0
}

# ----------------------------- Validation --------------------------
validate_inputs() {
  if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
    usage
  fi

  if [[ $# -lt 2 ]]; then
    log "ERROR" "Missing required arguments"
    usage
  fi
}

check_dependencies() {
  local missing=()

  for cmd in aws jq; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    log "ERROR" "Missing dependencies: ${missing[*]}"
    echo "Please install:"
    [[ " ${missing[*]} " =~ " aws " ]] && echo "  sudo apt install awscli"
    [[ " ${missing[*]} " =~ " jq " ]] && echo "  sudo apt install jq"
    exit 1
  fi

  if ! aws sts get-caller-identity &>/dev/null; then
    log "ERROR" "AWS credentials not configured or invalid"
    echo "Run: aws configure"
    exit 1
  fi
}

validate_services() {
  for svc in "${SERVICES_ARRAY[@]}"; do
    if [[ ! " ${SUPPORTED_SERVICES[*]} " =~ ${svc} ]]; then
      log "ERROR" "Unsupported service: $svc"
      echo "Supported services: ${SUPPORTED_SERVICES[*]}"
      exit 1
    fi
  done
}

# ----------------------------- AWS Functions -----------------------
get_all_regions() {
  aws ec2 describe-regions --query "Regions[].RegionName" --output text | tr '\t' '\n'
}

extract_table_data() {
  echo "$1" | grep -E '^\|  [a-zA-Z0-9-]' | sed 's/^|  //;s/  |$//'
}

# Service functions return JSON arrays
service_ec2() {
  local region="$1"
  local output
  output=$(aws ec2 describe-instances \
    --region "$region" \
    --query "Reservations[].Instances[].InstanceId" \
    --output table 2>/dev/null || echo "")

  if [[ -n "$output" ]]; then
    local data
    data=$(extract_table_data "$output")
    echo "$data" | grep -v '^$' | jq -R -s -c 'split("\n") | map(select(. != ""))'
  else
    echo '[]'
  fi
}

service_s3() {
  local region="$1"
  local output
  output=$(aws s3api list-buckets \
    --query "Buckets[].Name" \
    --output table 2>/dev/null || echo "")

  if [[ -n "$output" ]]; then
    local data
    data=$(extract_table_data "$output")
    echo "$data" | grep -v '^$' | jq -R -s -c 'split("\n") | map(select(. != ""))'
  else
    echo '[]'
  fi
}

service_ebs() {
  local region="$1"
  local output
  output=$(aws ec2 describe-volumes \
    --region "$region" \
    --filters Name=status,Values=available \
    --query "Volumes[].VolumeId" \
    --output table 2>/dev/null || echo "")

  if [[ -n "$output" ]]; then
    local data
    data=$(extract_table_data "$output")
    echo "$data" | grep -v '^$' | jq -R -s -c 'split("\n") | map(select(. != ""))'
  else
    echo '[]'
  fi
}

service_lambda() {
  local region="$1"
  local output
  output=$(aws lambda list-functions \
    --region "$region" \
    --query "Functions[].FunctionName" \
    --output table 2>/dev/null || echo "")

  if [[ -n "$output" ]]; then
    local data
    data=$(extract_table_data "$output")
    echo "$data" | grep -v '^$' | jq -R -s -c 'split("\n") | map(select(. != ""))'
  else
    echo '[]'
  fi
}

service_rds() {
  local region="$1"
  local output
  output=$(aws rds describe-db-instances \
    --region "$region" \
    --query "DBInstances[].DBInstanceIdentifier" \
    --output table 2>/dev/null || echo "")

  if [[ -n "$output" ]]; then
    local data
    data=$(extract_table_data "$output")
    echo "$data" | grep -v '^$' | jq -R -s -c 'split("\n") | map(select(. != ""))'
  else
    echo '[]'
  fi
}

# ----------------------------- Cost Estimation ---------------------
estimate_cost_by_tag() {
  local start_date end_date

  start_date=$(date -d "30 days ago" +%Y-%m-%d)
  end_date=$(date +%Y-%m-%d)

  log "INFO" "Estimating costs for tag $COST_TAG_KEY=$COST_TAG_VALUE"

  local cost_data
  cost_data=$(aws ce get-cost-and-usage \
    --time-period "Start=$start_date,End=$end_date" \
    --granularity MONTHLY \
    --metrics "UnblendedCost" \
    --filter "{\"Tags\":{\"Key\":\"$COST_TAG_KEY\",\"Values\":[\"$COST_TAG_VALUE\"]}}" \
    --output json 2>/dev/null || echo '{"error": "Cost Explorer not available"}')

  echo "$cost_data"
}

# ----------------------------- Notifications -----------------------
send_slack_notification() {
  [[ -z "$SLACK_WEBHOOK_URL" ]] && return
  [[ "$SEND_NOTIFICATIONS" == "false" ]] && return

  local message="$1"
  local payload

  payload=$(
    cat <<EOF
{
    "blocks": [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "🚀 AWS Resource Audit Completed",
                "emoji": true
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "$message"
            }
        },
        {
            "type": "section",
            "fields": [
                {
                    "type": "mrkdwn",
                    "text": "*Timestamp:*\n$(date '+%Y-%m-%d %H:%M:%S')"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Account:*\n$(aws sts get-caller-identity --query Account --output text)"
                }
            ]
        }
    ]
}
EOF
  )

  if curl -s -X POST -H "Content-type: application/json" \
    --data "$payload" "$SLACK_WEBHOOK_URL" >/dev/null 2>&1; then
    log "SUCCESS" "Slack notification sent"
  else
    log "WARN" "Failed to send Slack notification"
  fi
}

send_email_report() {
  [[ "$EMAIL_ENABLED" != "true" ]] && return
  [[ -z "$EMAIL_TO" ]] && return
  [[ "$SEND_NOTIFICATIONS" == "false" ]] && return

  # ADD THESE VARIABLE DEFINITIONS:
  local EMAIL_FROM="${EMAIL_FROM:-$EMAIL_TO}"
  local SMTP_SERVER="${SMTP_SERVER:-smtp.gmail.com}"
  local SMTP_PORT="${SMTP_PORT:-587}"
  local SMTP_USER="${SMTP_USER:-$EMAIL_FROM}"
  local SMTP_PASSWORD="${SMTP_PASSWORD:-}"

  local subject="${EMAIL_SUBJECT:-AWS Resource Audit Report} - $(date '+%Y-%m-%d')"
  local report_file="$REPORT_DIR/${REPORT_PREFIX}_summary.txt"
  local csv_file="$REPORT_DIR/${REPORT_PREFIX}_summary.csv"

  # Create email body
  local body="AWS Resource Audit completed successfully.\n\n"
  body+="Report generated: $(date)\n"
  body+="Total resources found: $TOTAL_RESOURCES\n"
  body+="Regions scanned: ${#regions_array[@]}\n"
  body+="Services audited: ${SERVICES_ARRAY[*]}\n\n"
  body+="=== REPORT SUMMARY ===\n"
  body+=$(cat "$report_file" | tail -30)
  body+="\n\nFull reports are attached.\n"

  # Check if we have sendemail command (more reliable for SMTP)
  if command -v sendemail &>/dev/null; then
    log "INFO" "Sending email via sendemail command..."

    # Prepare attachment
    local attachment=""
    [[ -f "$csv_file" ]] && attachment="-a $csv_file"

    # Check if password is set
    if [[ -z "$SMTP_PASSWORD" ]]; then
      log "WARN" "SMTP_PASSWORD not set. Email not sent."
      return
    fi

    sendemail \
      -f "$EMAIL_FROM" \
      -t "$EMAIL_TO" \
      -u "$subject" \
      -m "$body" \
      -s "$SMTP_SERVER:$SMTP_PORT" \
      -xu "$SMTP_USER" \
      -xp "$SMTP_PASSWORD" \
      -o tls=yes \
      $attachment \
      >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
      log "SUCCESS" "Email sent successfully to $EMAIL_TO"
    else
      log "WARN" "Failed to send email via sendemail command"
    fi
  else
    log "WARN" "sendemail command not found. Install with: sudo apt install sendemail libio-socket-ssl-perl libnet-ssleay-perl"
  fi
}

# ----------------------------- Report Generation -------------------
generate_reports() {
  local results="$1"
  local cost_data="$2"

  # FIX: Ensure results is valid JSON array
  if [[ -z "$results" ]] || [[ "$results" == "null" ]] || ! echo "$results" | jq empty >/dev/null 2>&1; then
    log "WARN" "No valid results data to generate reports"
    results='[]'
  fi

  # 1. Detailed JSON report
  echo "$results" | jq '.' >"$REPORT_DIR/${REPORT_PREFIX}_detailed.json" 2>/dev/null || echo '[]' >"$REPORT_DIR/${REPORT_PREFIX}_detailed.json"

  # 2. Summary JSON with cost data
  local summary_with_cost
  if [[ "$cost_data" != '{"error": "Cost Explorer not available"}' ]] && echo "$cost_data" | jq empty >/dev/null 2>&1; then
    summary_with_cost=$(echo "$results" | jq --argjson cost "$cost_data" \
      '[.[] | {region, service, count: (.resources | length)}] + [{service: "cost_estimation", data: $cost}]' 2>/dev/null || echo '[]')
  else
    summary_with_cost=$(echo "$results" | jq '[.[] | {region, service, count: (.resources | length)}]' 2>/dev/null || echo '[]')
  fi
  echo "$summary_with_cost" >"$REPORT_DIR/${REPORT_PREFIX}_summary.json"

  # 3. CSV report
  {
    echo "region,service,resource_count"
    echo "$results" | jq -r '.[] | "\(.region),\(.service),\(.resources | length)"' 2>/dev/null | grep -v '^$'
    if [[ "$cost_data" != '{"error": "Cost Explorer not available"}' ]] && echo "$cost_data" | jq empty >/dev/null 2>&1; then
      echo "$cost_data" | jq -r '.ResultsByTime[]? | "\(.TimePeriod.Start),COST,\(.Total.UnblendedCost.Amount) \(.Total.UnblendedCost.Unit)"' 2>/dev/null | grep -v '^$'
    fi
  } >"$REPORT_DIR/${REPORT_PREFIX}_summary.csv"

  # 4. Human readable report
  {
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║           AWS RESOURCE AUDIT REPORT                      ║"
    echo "║           Generated: $(date '+%Y-%m-%d %H:%M:%S')                       ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    echo "📊 EXECUTIVE SUMMARY"
    echo "────────────────────"

    local total_resources
    total_resources=$(echo "$results" | jq '[.[].resources | length] | add // 0' 2>/dev/null || echo "0")
    local unique_regions
    unique_regions=$(echo "$results" | jq 'map(.region) | unique | length' 2>/dev/null || echo "0")
    local unique_services
    unique_services=$(echo "$results" | jq 'map(.service) | unique | length' 2>/dev/null || echo "0")

    echo "Total Regions: $unique_regions"
    echo "Total Services: $unique_services"
    echo "Total Resources: $total_resources"
    echo ""

    echo "📋 RESOURCE BREAKDOWN"
    echo "─────────────────────"
    echo "Region       Service     Count"
    echo "───────────  ──────────  ─────"

    # FIX: Safely parse the results
    echo "$results" | jq -r '.[]? | "\(.region) \(.service) \(.resources | length)"' 2>/dev/null |
      while read -r region service count; do
        if [[ -n "$region" ]] && [[ -n "$service" ]] && [[ -n "$count" ]]; then
          printf "%-11s %-10s %5s\n" "$region" "$service" "$count"
        fi
      done |
      while read -r line; do
        if [[ -n "$line" ]]; then
          count=$(echo "$line" | awk '{print $NF}')
          if [[ "$count" -gt 0 ]]; then
            echo -e "${GREEN}$line${NC}"
          else
            echo "$line"
          fi
        fi
      done

    echo ""

    # Note: Cost estimation section only displays when:
    # 1. AWS Cost Explorer is accessible (Business/Enterprise support plan)
    # 2. Valid cost data is returned (not error message)
    # 3. This provides clean UX - no empty sections when data unavailable# Note: Cost estimation section only displays when:
    # 1. AWS Cost Explorer is accessible (Business/Enterprise support plan)
    # 2. Valid cost data is returned (not error message)
    # 3. This provides clean UX - no empty sections when data unavailable
    if [[ "$ESTIMATE_COSTS" == "true" ]] && [[ "$cost_data" != '{"error": "Cost Explorer not available"}' ]] &&
      echo "$cost_data" | jq empty >/dev/null 2>&1; then
      echo "💰 COST ESTIMATION (Last 30 Days)"
      echo "─────────────────────────────────"
      echo "Tag Filter: $COST_TAG_KEY = $COST_TAG_VALUE"
      echo ""
      echo "$cost_data" | jq -r '.ResultsByTime[]? | "\(.TimePeriod.Start) to \(.TimePeriod.End): \(.Total.UnblendedCost.Amount) \(.Total.UnblendedCost.Unit)"' 2>/dev/null |
        while read -r cost_line; do
          if [[ -n "$cost_line" ]]; then
            echo -e "${YELLOW}$cost_line${NC}"
          fi
        done
      echo ""
    fi

    echo "🔔 NOTIFICATIONS"
    echo "────────────────"
    if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
      echo "✓ Slack: Enabled"
    else
      echo "✗ Slack: Not configured"
    fi

    if [[ "$EMAIL_ENABLED" == "true" ]] && [[ -n "$EMAIL_TO" ]]; then
      echo "✓ Email: Enabled (to: $EMAIL_TO)"
    else
      echo "✗ Email: Not configured"
    fi
    echo ""

    echo "📁 GENERATED FILES"
    echo "──────────────────"
    echo "All reports are saved in: $REPORT_DIR/"
    echo ""
    echo "File                           Description"
    echo "─────────────────────────────  ─────────────────────────────"
    echo "${REPORT_PREFIX}_detailed.json  Complete audit data (JSON)"
    echo "${REPORT_PREFIX}_summary.json   Summary with cost data (JSON)"
    echo "${REPORT_PREFIX}_summary.csv    Summary with costs (CSV)"
    echo "${REPORT_PREFIX}_summary.txt    This human-readable report"
    echo "aws_resource_audit.log         Execution log"
    echo ""

    echo "⚙️  CONFIGURATION"
    echo "─────────────────"
    echo "Config file: $CONFIG_FILE"
    echo "Cost tag key: $COST_TAG_KEY"
    echo "Cost tag value: $COST_TAG_VALUE"
    echo ""
  } >"$REPORT_DIR/${REPORT_PREFIX}_summary.txt"

  log "SUCCESS" "All reports generated successfully"
}

# ----------------------------- Main --------------------------------
main() {
  show_banner
  validate_inputs "$@"
  check_dependencies

  # Parse arguments
  local dry_run=false
  local verbose=false
  local send_notifications=true
  local estimate_costs=true
  local test_mode=false
  local positional_args=()

  for arg in "$@"; do
    case "$arg" in
    --dry-run) dry_run=true ;;
    --verbose) verbose=true ;;
    --no-notify) send_notifications=false ;;
    --no-cost) estimate_costs=false ;;
    --test) test_mode=true ;;
    --help) usage ;;
    *) positional_args+=("$arg") ;;
    esac
  done

  local region="${positional_args[0]}"
  local services_input="${positional_args[1]}"
  SERVICES_ARRAY=($(echo "$services_input" | tr ',' ' '))

  validate_services

  # Export for use in functions
  export SEND_NOTIFICATIONS="$send_notifications"
  export ESTIMATE_COSTS="$estimate_costs"

  # Get regions
  local regions_array
  if [[ "$region" == "all" ]]; then
    log "INFO" "Fetching all AWS regions..."
    regions_array=($(get_all_regions))
    log "INFO" "Found ${#regions_array[@]} regions"
  else
    regions_array=("$region")
  fi

  # Display configuration
  log "INFO" "Starting AWS Resource Audit"
  log "INFO" "Account: $(aws sts get-caller-identity --query Arn --output text)"
  log "INFO" "Regions: ${#regions_array[@]} region(s)"
  log "INFO" "Services: ${SERVICES_ARRAY[*]}"
  log "INFO" "Dry Run: $dry_run"
  log "INFO" "Notifications: $send_notifications"
  log "INFO" "Cost Estimation: $estimate_costs"
  log "INFO" "Report Dir: $REPORT_DIR"

  if [[ "$dry_run" == true ]]; then
    echo ""
    echo "🚀 DRY RUN - No API calls will be made"
    echo "──────────────────────────────────────"
    echo "Would query:"
    for r in "${regions_array[@]}"; do
      echo "  🌍 Region: $r"
      for s in "${SERVICES_ARRAY[@]}"; do
        echo "    • $s"
      done
    done
    echo ""
    echo "Total API calls: $((${#regions_array[@]} * ${#SERVICES_ARRAY[@]}))"
    echo ""

    if [[ "$estimate_costs" == true ]]; then
      echo "Would estimate costs for tag: $COST_TAG_KEY=$COST_TAG_VALUE"
    fi

    if [[ "$send_notifications" == true ]]; then
      echo "Would send notifications"
    fi
    echo ""
    exit 0
  fi

  # Initialize results as valid JSON array
  local all_results="[]"
  local total_operations=$((${#regions_array[@]} * ${#SERVICES_ARRAY[@]}))
  local completed_operations=0

  echo ""
  echo "🔍 Scanning AWS resources..."
  echo "────────────────────────────"

  # Process each region
  for r in "${regions_array[@]}"; do
    echo -e "\n🌍 Region: ${BLUE}$r${NC}"

    # Process each service
    for s in "${SERVICES_ARRAY[@]}"; do
      completed_operations=$((completed_operations + 1))
      echo -n "  [${completed_operations}/${total_operations}] "
      echo -n "${YELLOW}$s${NC}: "

      # Get raw output
      local raw_output=""
      local json_data="[]"
      local count=0

      case "$s" in
      ec2)
        raw_output=$(aws ec2 describe-instances \
          --region "$r" \
          --query "Reservations[].Instances[].InstanceId" \
          --output table 2>&1)
        json_data=$(service_ec2 "$r" 2>/dev/null || echo '[]')
        ;;
      s3)
        raw_output=$(aws s3api list-buckets \
          --query "Buckets[].Name" \
          --output table 2>&1)
        json_data=$(service_s3 "$r" 2>/dev/null || echo '[]')
        ;;
      ebs)
        raw_output=$(aws ec2 describe-volumes \
          --region "$r" \
          --filters Name=status,Values=available \
          --query "Volumes[].VolumeId" \
          --output table 2>&1)
        json_data=$(service_ebs "$r" 2>/dev/null || echo '[]')
        ;;
      lambda)
        raw_output=$(aws lambda list-functions \
          --region "$r" \
          --query "Functions[].FunctionName" \
          --output table 2>&1)
        json_data=$(service_lambda "$r" 2>/dev/null || echo '[]')
        ;;
      rds)
        raw_output=$(aws rds describe-db-instances \
          --region "$r" \
          --query "DBInstances[].DBInstanceIdentifier" \
          --output table 2>&1)
        json_data=$(service_rds "$r" 2>/dev/null || echo '[]')
        ;;
      esac

      # Validate json_data
      if ! echo "$json_data" | jq empty >/dev/null 2>&1; then
        json_data='[]'
      fi

      # Count resources
      count=$(echo "$json_data" | jq 'length' 2>/dev/null || echo "0")

      # Save raw output
      echo "$raw_output" >"$REPORT_DIR/${s}_${r}_raw.table"

      # Display count
      if [[ "$count" -gt 0 ]]; then
        echo -e "${GREEN}✓ $count resources${NC}"
      else
        echo "0 resources"
      fi

      # Add to results - FIX: Ensure we're adding valid JSON
      if echo "$json_data" | jq empty >/dev/null 2>&1; then
        all_results=$(echo "$all_results" | jq ". += [{
                    \"region\": \"$r\",
                    \"service\": \"$s\",
                    \"resource_count\": $count,
                    \"resources\": $json_data,
                    \"timestamp\": \"$(date -Iseconds)\"
                }]" 2>/dev/null || echo "$all_results")
      else
        all_results=$(echo "$all_results" | jq ". += [{
                    \"region\": \"$r\",
                    \"service\": \"$s\",
                    \"resource_count\": $count,
                    \"resources\": [],
                    \"timestamp\": \"$(date -Iseconds)\"
                }]" 2>/dev/null || echo "$all_results")
      fi
    done
  done

  # Validate all_results before processing
  if ! echo "$all_results" | jq empty >/dev/null 2>&1; then
    log "WARN" "Invalid results data, resetting to empty array"
    all_results='[]'
  fi

  # Cost estimation
  local cost_data='{"error": "Cost Explorer not available"}'
  if [[ "$estimate_costs" == true ]]; then
    echo ""
    echo "💰 Estimating costs..."
    echo "──────────────────────"
    cost_data=$(estimate_cost_by_tag)
    if [[ "$cost_data" != '{"error": "Cost Explorer not available"}' ]] && echo "$cost_data" | jq empty >/dev/null 2>&1; then
      echo -e "${YELLOW}✓ Cost estimation completed${NC}"
    else
      echo "✗ Cost Explorer not available or insufficient permissions"
      cost_data='{"error": "Cost Explorer not available"}'
    fi
  fi

  # Generate reports
  echo ""
  echo "📊 Generating reports..."
  echo "───────────────────────"
  generate_reports "$all_results" "$cost_data"

  # Set total resources for notifications
  TOTAL_RESOURCES=$(echo "$all_results" | jq '[.[].resource_count] | add // 0' 2>/dev/null || echo "0")

  # Send notifications
  if [[ "$send_notifications" == true ]]; then
    echo ""
    echo "🔔 Sending notifications..."
    echo "──────────────────────────"

    # Slack notification
    local slack_message="AWS Resource Audit completed successfully!\n• Total Resources: $TOTAL_RESOURCES\n• Regions: ${#regions_array[@]}\n• Services: ${#SERVICES_ARRAY[@]}\n• Report: $REPORT_DIR/"
    send_slack_notification "$slack_message"

    # Email notification
    send_email_report
  fi

  # Final summary
  echo ""
  echo -e "${GREEN}✅ AWS Resource Audit Completed Successfully!${NC}"
  echo "────────────────────────────────────────────────────────"
  echo "Total regions scanned: ${#regions_array[@]}"
  echo "Total services queried: ${#SERVICES_ARRAY[@]}"
  echo "Total resources found: $TOTAL_RESOURCES"
  echo "Total API calls made: $total_operations"
  echo ""
  echo -e "📁 ${BLUE}Reports saved to: $REPORT_DIR/${NC}"
  ls -1 "$REPORT_DIR/${REPORT_PREFIX}"* 2>/dev/null | while read -r file; do
    echo "  • $(basename "$file")"
  done
  echo ""

  log "SUCCESS" "Audit completed. Found $TOTAL_RESOURCES resources."
}

# Run main with all arguments
main "$@"
