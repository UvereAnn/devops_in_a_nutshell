#!/bin/bash

# Test runner for AWS Resource Audit script

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== AWS Resource Audit Test Suite ===${NC}"
echo ""

# Set correct paths - You're already in the project root!
PROJECT_ROOT="$(pwd)"
MAIN_SCRIPT="$PROJECT_ROOT/scripts/aws_resource_list.sh"
TEST_FILE="$PROJECT_ROOT/tests/test_aws_resource_list.bats"

echo "Project Root: $PROJECT_ROOT"
echo "Main Script: $MAIN_SCRIPT"
echo "Test File: $TEST_FILE"
echo ""

# Check if main script exists
if [[ ! -f "$MAIN_SCRIPT" ]]; then
    echo -e "${RED}Error: Main script not found!${NC}"
    echo "Expected at: $MAIN_SCRIPT"
    echo "Current directory contents:"
    ls -la
    exit 1
fi


# Check if BATS is installed
if ! command -v bats &>/dev/null; then
    echo -e "${RED}Error: BATS is not installed${NC}"
    echo "Install with:"
    echo "  sudo apt install bats  # Ubuntu/Debian"
    echo "  brew install bats      # macOS"
    exit 1
fi

# Set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_FILE="$PROJECT_ROOT/tests/test_aws_resource_list.bats"

# Create tests directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/tests"

# If test file doesn't exist, create it from the template above
if [[ ! -f "$TEST_FILE" ]]; then
    echo -e "${YELLOW}Creating test file from template...${NC}"
    cat > "$TEST_FILE" << 'EOF'
#!/usr/bin/env bats
[The entire BATS test file from above goes here]
EOF
fi

# Make test file executable
chmod +x "$TEST_FILE"

# Run tests
echo -e "${YELLOW}Running unit tests...${NC}"
echo ""

if bats "$TEST_FILE"; then
    echo ""
    echo -e "${GREEN}✅ All tests passed!${NC}"
else
    echo ""
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi

# Integration test (requires actual AWS credentials)
echo ""
echo -e "${YELLOW}Running integration test (dry-run)...${NC}"
cd "$PROJECT_ROOT" && ./01-aws_resource_audit/scripts/aws_resource_list.sh eu-north-1 ec2,s3 --dry-run --no-notify --no-cost

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✅ Integration test passed!${NC}"
else
    echo -e "${RED}❌ Integration test failed${NC}"
fi

echo ""
echo -e "${YELLOW}=== Test Suite Complete ===${NC}"