# Environment Configurations

This directory contains environment-specific configurations for different lab scenarios.

## Available Environments

### Standard
Your default lab configuration with:
- 3 Windows Server 2025 Datacenter VMs
- 1 Windows 11 Enterprise workstation
- 1 SQL Server 2022 Developer Edition
- Standard VM sizes (D2s_v3)
- Auto-shutdown enabled

### Dev
Lightweight development environment:
- Same VM count as Standard
- Smaller, cost-effective VM sizes (B2s)
- Auto-shutdown enabled (earlier time)
- Lower costs for development work

### Demo
Performance-optimized for demos:
- Same VM count as Standard
- Larger VM sizes for smooth performance (D4s_v3, D8s_v3)
- Auto-shutdown disabled during demos
- Better performance for presentations

## Using Environment Configurations

### Option 1: Copy to root (Recommended)
```bash
cp environments/standard/terraform.tfvars.example ../terraform.tfvars
# Edit terraform.tfvars with your credentials
```

### Option 2: Use -var-file flag
```bash
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

## Creating New Environments

To add a new environment:

1. Create a new directory: `mkdir environments/your-env-name`
2. Copy an example: `cp environments/standard/terraform.tfvars.example environments/your-env-name/`
3. Customize the values for your specific needs
4. Deploy using the -var-file approach

## Environment Variables

All environments support these configurable variables:
- `environment_name` - Unique identifier for resources
- `location` - Azure region
- `vnet_address_space` - Network CIDR
- `admin_username` / `admin_password` - VM credentials
- `sql_admin_username` / `sql_admin_password` - SQL credentials
- `*_vm_size` - VM sizes for each resource type
- `enable_auto_shutdown` - Cost-saving feature
- `tags` - Resource tags for organization

