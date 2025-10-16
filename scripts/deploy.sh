#!/bin/bash

# Azure Windows Server Lab - Deployment Script
# This script automates the deployment of your Windows Server Lab

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

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Azure Windows Server Lab${NC}"
echo -e "${BLUE}Automated Deployment Script${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check for Terraform
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}ERROR: Terraform is not installed.${NC}"
        echo "Please install Terraform from: https://www.terraform.io/downloads"
        exit 1
    fi
    echo -e "${GREEN}✓ Terraform found: $(terraform version -json | jq -r '.terraform_version')${NC}"
    
    # Check for Azure CLI
    if ! command -v az &> /dev/null; then
        echo -e "${RED}ERROR: Azure CLI is not installed.${NC}"
        echo "Please install Azure CLI from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi
    echo -e "${GREEN}✓ Azure CLI found: $(az version --query '"azure-cli"' -o tsv)${NC}"
    
    # Check Azure login status
    if ! az account show &> /dev/null; then
        echo -e "${RED}ERROR: Not logged in to Azure.${NC}"
        echo "Please run: az login"
        exit 1
    fi
    
    local subscription_name=$(az account show --query 'name' -o tsv)
    local subscription_id=$(az account show --query 'id' -o tsv)
    echo -e "${GREEN}✓ Logged in to Azure${NC}"
    echo -e "  Subscription: ${subscription_name}"
    echo -e "  ID: ${subscription_id}"
    
    echo ""
}

# Function to check for terraform.tfvars
check_config() {
    echo -e "${YELLOW}Checking configuration...${NC}"
    
    cd "$PROJECT_ROOT"
    
    if [ ! -f "terraform.tfvars" ]; then
        echo -e "${RED}ERROR: terraform.tfvars not found!${NC}"
        echo ""
        echo "Please create terraform.tfvars from the example:"
        echo "  cp terraform.tfvars.example terraform.tfvars"
        echo ""
        echo "Then edit terraform.tfvars with your credentials and settings."
        exit 1
    fi
    
    echo -e "${GREEN}✓ Configuration file found${NC}"
    echo ""
}

# Function to initialize Terraform
init_terraform() {
    echo -e "${YELLOW}Initializing Terraform...${NC}"
    cd "$PROJECT_ROOT"
    
    terraform init
    
    echo -e "${GREEN}✓ Terraform initialized${NC}"
    echo ""
}

# Function to validate Terraform configuration
validate_terraform() {
    echo -e "${YELLOW}Validating Terraform configuration...${NC}"
    cd "$PROJECT_ROOT"
    
    terraform validate
    
    echo -e "${GREEN}✓ Configuration is valid${NC}"
    echo ""
}

# Function to plan deployment
plan_deployment() {
    echo -e "${YELLOW}Planning deployment...${NC}"
    cd "$PROJECT_ROOT"
    
    terraform plan -out=tfplan
    
    echo ""
    echo -e "${GREEN}✓ Deployment plan created${NC}"
    echo ""
}

# Function to deploy
deploy() {
    echo -e "${YELLOW}Starting deployment...${NC}"
    echo -e "${YELLOW}This will take approximately 15-20 minutes...${NC}"
    echo ""
    
    cd "$PROJECT_ROOT"
    
    terraform apply tfplan
    
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}✓ Deployment Complete!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    
    # Show outputs
    echo -e "${BLUE}Connection Information:${NC}"
    terraform output -raw connection_instructions
    echo ""
    
    # Clean up plan file
    rm -f tfplan
}

# Main execution
main() {
    check_prerequisites
    check_config
    init_terraform
    validate_terraform
    plan_deployment
    
    echo -e "${YELLOW}Ready to deploy!${NC}"
    echo ""
    read -p "Do you want to proceed with deployment? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ] || [ "$confirm" = "y" ]; then
        deploy
    else
        echo -e "${YELLOW}Deployment cancelled.${NC}"
        echo "Plan file saved as 'tfplan'. Run 'terraform apply tfplan' to deploy later."
        exit 0
    fi
}

# Run main function
main

