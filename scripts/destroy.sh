#!/bin/bash

# Azure Windows Server Lab - Destroy Script
# This script safely tears down your Windows Server Lab

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${RED}================================${NC}"
echo -e "${RED}Azure Windows Server Lab${NC}"
echo -e "${RED}Destroy Script${NC}"
echo -e "${RED}================================${NC}"
echo ""

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check for Terraform
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}ERROR: Terraform is not installed.${NC}"
        exit 1
    fi
    
    # Check Azure login status
    if ! az account show &> /dev/null; then
        echo -e "${RED}ERROR: Not logged in to Azure.${NC}"
        echo "Please run: az login"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Prerequisites checked${NC}"
    echo ""
}

# Function to show current resources
show_resources() {
    echo -e "${YELLOW}Current resources that will be destroyed:${NC}"
    echo ""
    
    cd "$PROJECT_ROOT"
    
    if [ ! -f "terraform.tfstate" ]; then
        echo -e "${YELLOW}No Terraform state found. Nothing to destroy.${NC}"
        exit 0
    fi
    
    terraform show -json | jq -r '.values.root_module.resources[] | "\(.type): \(.name)"' 2>/dev/null || true
    echo ""
}

# Function to destroy infrastructure
destroy() {
    echo -e "${RED}WARNING: This will permanently delete all resources!${NC}"
    echo -e "${RED}This action cannot be undone!${NC}"
    echo ""
    
    read -p "Type 'destroy' to confirm: " confirm
    
    if [ "$confirm" != "destroy" ]; then
        echo -e "${YELLOW}Destruction cancelled.${NC}"
        exit 0
    fi
    
    echo ""
    echo -e "${YELLOW}Destroying infrastructure...${NC}"
    echo -e "${YELLOW}This will take approximately 10-15 minutes...${NC}"
    echo ""
    
    cd "$PROJECT_ROOT"
    terraform destroy -auto-approve
    
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}✓ Infrastructure Destroyed${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
}

# Main execution
main() {
    check_prerequisites
    show_resources
    destroy
}

# Run main function
main

