# Terraform State Storage Bootstrap

This directory contains the bootstrap configuration for creating Azure Storage backend for Terraform state.

## One-Time Setup

Run this **ONCE** before deploying the main infrastructure:

```bash
cd bootstrap

# Initialize and deploy state storage
terraform init
terraform apply

# Note the output - you'll need the storage account name
terraform output backend_config
```

## After Bootstrap

Once deployed, configure the main Terraform to use remote state:

1. Copy the backend configuration from output
2. Add to `main.tf` in the root directory
3. Run `terraform init -migrate-state` to move local state to Azure

## Important Notes

- This creates a **separate** resource group for state management
- State storage uses **GRS** (geo-redundant) for disaster recovery
- **Blob versioning** is enabled for state file history
- **TLS 1.2** enforced for security
- State locking is automatic via Azure Storage blob leases

## Cleanup

**WARNING**: Only destroy this if you're completely done with the lab:

```bash
terraform destroy
```

This will delete all state history!

