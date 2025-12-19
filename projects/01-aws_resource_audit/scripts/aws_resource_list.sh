#!/bin/bash

# -----------------------------------------------------------------------------------------------------------------
# Name        : aws_resource_list.sh
# Description : Automates listing of active AWS resources for selected services and regions
# Author      : Ivuaku Annastassia
# Version     : v0.0.2
#
# Supported Services:
#   - ec2
#   - s3
#   - ebs
#   - lambda
#   - rds
#
# Usage:
#   ./aws_resource_list.sh <region|all> <service1,service2> [json|table] [--dry-run]
#
# Examples:
#   ./aws_resource_list.sh us-east-1 ec2,s3
#   ./aws_resource_list.sh all ec2,lambda json
#   ./aws_resource_list.sh eu-north-1 ec2,s3 --dry-run
# -----------------------------------------------------------------------------------------------------------------

#set -euo pipefail

CONFIG_FILE="./config.env"
LOG_FILE="./aws_resource_audit.log"

SUPPORTED_SERVICES=("ec2" "s3" "ebs" "lambda" "rds")

# ----------------------------- Logging -----------------------------
log() {
  echo "$(date '+%F %T') | $1" | tee -a "$LOG_FILE"
}

# ----------------------------- Usage -------------------------------
usage() {
  echo "Usage: $0 <region|all> <service1,service2> [json|table] [--dry-run]"
  echo "Supported services: ${SUPPORTED_SERVICES[*]}"
  exit 1
}

# ----------------------------- Input Validation --------------------
validate_inputs() {
  [[ $# -lt 2 ]] && usage
}

# ----------------------------- Dependency Checks -------------------
check_dependencies() {
  echo "Checking dependencies..."

  if ! command -v aws &>/dev/null; then
    log "ERROR: AWS CLI is not installed"
    echo "Install with: sudo apt install awscli"
    exit 1
  fi

  if [[ ! -d "$HOME/.aws" ]]; then
    log "ERROR: AWS CLI is not configured. Run 'aws configure'"
    echo "Run: aws configure"
    exit 1
  fi

  if ! aws sts get-caller-identity &>/dev/null; then
    log "ERROR: Invalid or expired AWS credentials"
    echo "Check your ~/.aws/credentials file or run: aws configure"
    exit 1
  fi
}

# ----------------------------- Service Validation ------------------
validate_services() {
  for svc in $SERVICES; do
    if [[ ! " ${SUPPORTED_SERVICES[*]} " =~ " ${svc} " ]]; then
      log "ERROR: Unsupported service: $svc"
      usage
    fi
  done
}

# ----------------------------- Region Handling ---------------------
get_regions() {
  aws ec2 describe-regions \
    --query "Regions[].RegionName" \
    --output text
}

# ----------------------------- Service Functions -------------------
list_ec2() {
  aws ec2 describe-instances \
    --region "$1" \
    --query "Reservations[].Instances[].InstanceId" \
    --output "$2"
}

list_s3() {
  aws s3api list-buckets \
    --query "Buckets[].Name" \
    --output "$2"
}

list_ebs() {
  aws ec2 describe-volumes \
    --region "$1" \
    --query "Volumes[].VolumeId" \
    --output "$2"
}

list_lambda() {
  aws lambda list-functions \
    --region "$1" \
    --query "Functions[].FunctionName" \
    --output "$2"
}

list_rds() {
  aws rds describe-db-instances \
    --region "$1" \
    --query "DBInstances[].DBInstanceIdentifier" \
    --output "$2"
}

# ----------------------------- Main --------------------------------
main() {

  validate_inputs "$@"
  check_dependencies

  REGION="$1"
  SERVICES=$(echo "$2" | tr ',' ' ')
  OUTPUT="${3:-table}"

  validate_services

  DRY_RUN=false
  if [[ "${@: -1}" == "--dry-run" ]]; then
    DRY_RUN=true
  fi

  if [[ "$REGION" == "all" ]]; then
    REGIONS=$(get_regions)
  else
    REGIONS="$REGION"
  fi

  USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
  log "Script executed by: $USER_ARN"

  for r in $REGIONS; do
    for svc in $SERVICES; do
      log "Region=$r | Service=$svc"

      if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY-RUN] list_$svc $r $OUTPUT"
        continue
      fi

      "list_$svc" "$r" "$OUTPUT"
    done
  done

  log "AWS resource audit completed successfully"
}

main "$@"

