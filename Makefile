# Azure Hybrid Infrastructure Platform - Makefile
# Simplifies common Terraform operations

.PHONY: help init plan apply destroy fmt validate clean bootstrap

# Default target
help:
	@echo "Azure Hybrid Infrastructure Platform - Available Commands:"
	@echo ""
	@echo "  make init        - Initialize Terraform"
	@echo "  make plan        - Create execution plan"
	@echo "  make apply       - Deploy infrastructure"
	@echo "  make destroy     - Destroy infrastructure"
	@echo "  make fmt         - Format Terraform files"
	@echo "  make validate    - Validate Terraform configuration"
	@echo "  make security    - Run security scans (tfsec)"
	@echo "  make clean       - Clean Terraform files"
	@echo "  make bootstrap   - Bootstrap remote state storage"
	@echo "  make docs        - Generate module documentation"
	@echo ""

# Initialize Terraform
init:
	@echo "==> Initializing Terraform..."
	terraform init

# Create execution plan
plan:
	@echo "==> Creating Terraform plan..."
	terraform plan -out=tfplan

# Deploy infrastructure
apply:
	@echo "==> Deploying infrastructure..."
	@if [ ! -f tfplan ]; then \
		echo "Error: No plan file found. Run 'make plan' first."; \
		exit 1; \
	fi
	terraform apply tfplan
	@rm -f tfplan

# Destroy infrastructure
destroy:
	@echo "==> WARNING: This will destroy all infrastructure!"
	@read -p "Are you sure? Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		terraform destroy; \
	else \
		echo "Destroy cancelled."; \
	fi

# Format Terraform files
fmt:
	@echo "==> Formatting Terraform files..."
	terraform fmt -recursive

# Validate configuration
validate:
	@echo "==> Validating Terraform configuration..."
	terraform fmt -check -recursive
	terraform validate

# Security scan
security:
	@echo "==> Running security scans..."
	@if command -v tfsec >/dev/null 2>&1; then \
		tfsec .; \
	else \
		echo "tfsec not installed. Install: brew install tfsec"; \
	fi
	@if command -v checkov >/dev/null 2>&1; then \
		checkov -d .; \
	else \
		echo "checkov not installed. Install: pip install checkov"; \
	fi

# Clean Terraform artifacts
clean:
	@echo "==> Cleaning Terraform artifacts..."
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f tfplan
	rm -f terraform.tfstate.backup
	@echo "Clean complete. Re-run 'make init' before next deployment."

# Bootstrap remote state storage
bootstrap:
	@echo "==> Bootstrapping remote state storage..."
	cd bootstrap && terraform init && terraform apply
	@echo ""
	@echo "Bootstrap complete! Copy the backend configuration to main.tf"
	@echo "Then run: terraform init -migrate-state"

# Generate documentation
docs:
	@echo "==> Generating module documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table --output-file README_MODULES.md modules/; \
	else \
		echo "terraform-docs not installed. Install: brew install terraform-docs"; \
	fi

# Quick deployment (plan + apply in one command)
deploy: plan apply
	@echo "==> Deployment complete!"

# Full cycle: format, validate, security, plan
check: fmt validate security plan
	@echo "==> All checks passed!"

