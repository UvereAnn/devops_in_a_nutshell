#!/usr/bin/env bats

# Simple test file for aws_resource_list.sh
# Testing basic functionality only

setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR" || exit 1
}

teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

@test "Script exists in project" {
    SCRIPT="/home/vboxuser/devops_in_a_nutshell/projects/01-aws_resource_audit/scripts/aws_resource_list.sh"
    [ -f "$SCRIPT" ]
}

@test "Script is executable" {
    SCRIPT="/home/vboxuser/devops_in_a_nutshell/projects/01-aws_resource_audit/scripts/aws_resource_list.sh"
    [ -x "$SCRIPT" ]
}

@test "Script has correct shebang" {
    SCRIPT="/home/vboxuser/devops_in_a_nutshell/projects/01-aws_resource_audit/scripts/aws_resource_list.sh"
    run head -1 "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == "#!/bin/bash" ]]
}

@test "Project structure exists" {
    PROJECT="/home/vboxuser/devops_in_a_nutshell/projects/01-aws_resource_audit"
    [ -d "$PROJECT/config" ]
    [ -d "$PROJECT/scripts" ]
    [ -d "$PROJECT/reports" ]
    [ -d "$PROJECT/tests" ]
}

@test "Config file exists or can be created" {
    CONFIG_FILE="/home/vboxuser/devops_in_a_nutshell/projects/01-aws_resource_audit/config/config.env"
    # Just check if config directory is accessible
    [ -d "$(dirname "$CONFIG_FILE")" ]
}