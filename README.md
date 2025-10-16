# Azure Windows Server Lab

**Automated Infrastructure as Code for Windows Server Testing and Demos**

This repository provides a complete, automated Azure lab environment for Windows Server testing, experimentation, and demonstrations. Deploy a full Windows Server infrastructure with a single command.

## 🚀 What This Deploys

Your **Standard Configuration** includes:

- **3x Windows Server 2025 Datacenter** - For domain controllers, application servers, or clustering
- **1x Windows 11 Enterprise Workstation** - Client machine for testing and management
- **1x SQL Server 2022 Developer Edition** - Latest SQL Server with optimized storage configuration
- **1x Azure Bastion Host** - Secure RDP access without public IPs
- **Complete Network Infrastructure** - VNet, subnets, NSGs with proper segmentation

## 📋 Prerequisites

Before deploying, ensure you have:

1. **Azure Subscription** - With appropriate permissions to create resources
2. **Terraform** (>= 1.0) - [Download here](https://www.terraform.io/downloads)
3. **Azure CLI** - [Download here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
4. **Git** - For cloning and version control

## 🎯 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/adrian207/Azure-Win-Lab.git
cd Azure-Win-Lab
```

### 2. Login to Azure

```bash
az login
az account set --subscription "Your-Subscription-Name"
```

### 3. Configure Your Environment

```bash
# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your preferred editor
nano terraform.tfvars  # or vim, code, etc.
```

**Important:** Update these values in `terraform.tfvars`:
- `admin_password` - Must meet Azure password requirements
- `sql_admin_password` - Must meet SQL Server password requirements
- `location` - Your preferred Azure region
- `tags` - Add your owner/cost center information

### 4. Deploy the Lab

#### Option A: Using the Deployment Script (Recommended)

```bash
./scripts/deploy.sh
```

This script will:
- ✓ Check prerequisites
- ✓ Validate configuration
- ✓ Plan deployment
- ✓ Ask for confirmation
- ✓ Deploy infrastructure
- ✓ Display connection information

#### Option B: Manual Deployment

```bash
terraform init
terraform plan
terraform apply
```

### 5. Access Your Lab

After deployment (15-20 minutes), use Azure Bastion to connect:

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to your Resource Group
3. Select a VM
4. Click **Connect** → **Bastion**
5. Enter your credentials from `terraform.tfvars`

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Azure Virtual Network                    │
│                        (10.0.0.0/16)                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐  ┌──────────────────────────────┐   │
│  │ Azure Bastion    │  │  Servers Subnet (10.0.2.0/24)│   │
│  │ (10.0.1.0/26)    │  │  ┌────────┐ ┌────────┐       │   │
│  └──────────────────┘  │  │  DC1   │ │  DC2   │       │   │
│                         │  └────────┘ └────────┘       │   │
│  ┌──────────────────┐  │  ┌────────┐                  │   │
│  │ Workstations     │  │  │  DC3   │                  │   │
│  │ (10.0.3.0/24)    │  │  └────────┘                  │   │
│  │ ┌──────────┐     │  └──────────────────────────────┘   │
│  │ │   WS01   │     │                                      │
│  │ └──────────┘     │  ┌──────────────────────────────┐   │
│  └──────────────────┘  │ Database Subnet (10.0.4.0/24)│   │
│                         │  ┌────────┐                  │   │
│                         │  │  SQL01 │                  │   │
│                         │  └────────┘                  │   │
│                         └──────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Configuration Options

### VM Sizes

Adjust VM sizes based on your needs and budget:

| Resource | Default Size | vCPUs | RAM | Use Case |
|----------|-------------|-------|-----|----------|
| Windows Servers | Standard_D2s_v3 | 2 | 8 GB | Standard workloads |
| Windows 11 WS | Standard_D2s_v3 | 2 | 8 GB | Client operations |
| SQL Server | Standard_D4s_v3 | 4 | 16 GB | Database workloads |

### Auto-Shutdown

Save costs with automatic VM shutdown:

```hcl
enable_auto_shutdown   = true
auto_shutdown_time     = "1900"  # 7:00 PM
auto_shutdown_timezone = "Eastern Standard Time"
```

Estimated monthly savings: **~70%** with 12-hour daily shutdown

## 🎨 Multiple Environments

This solution is designed for extensibility. Deploy different configurations on-demand:

### Standard Environment
Your default configuration - balanced performance and cost.

```bash
cp environments/standard/terraform.tfvars.example terraform.tfvars
terraform apply
```

### Development Environment
Smaller, cost-effective VMs for development work.

```bash
terraform apply -var-file=environments/dev/terraform.tfvars.example
```

### Demo Environment
High-performance VMs for customer demos.

```bash
terraform apply -var-file=environments/demo/terraform.tfvars.example
```

### Creating Custom Environments

1. Create a new directory in `environments/`
2. Copy and modify a tfvars file
3. Deploy with `-var-file` flag

See [environments/README.md](environments/README.md) for details.

## 💰 Cost Estimates

[Inference] Approximate monthly costs for Standard configuration (East US, pay-as-you-go):

| Resource | Quantity | Monthly Cost (USD) |
|----------|----------|-------------------|
| Windows Server VMs | 3 | ~$210 |
| Windows 11 VM | 1 | ~$70 |
| SQL Server VM | 1 | ~$140 |
| Azure Bastion | 1 | ~$140 |
| Storage (Premium SSD) | - | ~$50 |
| **Total** | | **~$610/month** |

**With auto-shutdown (12hrs/day):** ~$215/month

> Note: Costs vary by region and usage. Use [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) for precise estimates.

## 📝 Common Operations

### View Current Resources

```bash
terraform show
```

### Get Connection Information

```bash
terraform output connection_instructions
```

### Update Infrastructure

1. Modify `terraform.tfvars` or module files
2. Run `terraform plan` to preview changes
3. Run `terraform apply` to apply changes

### Destroy Lab Environment

```bash
# Using script (recommended)
./scripts/destroy.sh

# Or manually
terraform destroy
```

## 🔐 Security Best Practices

1. **Passwords**: Use strong, unique passwords
2. **Secrets Management**: Consider Azure Key Vault for production
3. **Network Access**: Bastion provides secure RDP without public IPs
4. **State Files**: Store Terraform state remotely (Azure Storage)
5. **Git**: Never commit `terraform.tfvars` or `.tfstate` files

## 🛠️ Customization

### Add More VMs

Edit `main.tf` and change the count:

```hcl
module "windows_servers" {
  count = 5  # Change from 3 to 5
  # ...
}
```

### Change Network Ranges

Update in `terraform.tfvars`:

```hcl
vnet_address_space = ["172.16.0.0/16"]
```

### Add Custom Scripts

Use VM extensions in module files to run custom PowerShell scripts on deployment.

## 📚 Module Structure

```
.
├── main.tf                    # Main orchestration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── modules/
│   ├── networking/           # VNet, subnets, NSGs
│   ├── bastion/              # Azure Bastion
│   ├── windows-server/       # Windows Server VMs
│   ├── windows11-workstation/# Windows 11 client
│   └── sql-server/           # SQL Server deployment
├── environments/             # Environment configurations
│   ├── standard/
│   ├── dev/
│   └── demo/
└── scripts/                  # Automation scripts
    ├── deploy.sh
    └── destroy.sh
```

## 🐛 Troubleshooting

### Issue: Terraform Init Fails

**Solution:** Ensure Terraform and Azure CLI are installed and updated.

### Issue: Deployment Fails with "Quota Exceeded"

**Solution:** Check your Azure subscription quotas for VM cores in your region.

### Issue: Cannot Connect via Bastion

**Solution:** 
1. Ensure VMs are running
2. Verify Bastion deployment completed
3. Check NSG rules allow Bastion subnet access

### Issue: Password Doesn't Meet Requirements

**Solution:** Azure passwords must:
- Be 12-123 characters long
- Contain 3 of: uppercase, lowercase, numbers, special characters

## 🤝 Contributing

Improvements and suggestions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is open source and available under the MIT License.

## 🙋 Support

For issues and questions:
- Check the [Troubleshooting](#-troubleshooting) section
- Review Terraform and Azure documentation
- Open an issue in this repository

## 🎯 Future Enhancements

Potential additions:
- [ ] Active Directory automated configuration
- [ ] Domain join automation for workstations
- [ ] PowerShell DSC configurations
- [ ] Azure DevOps integration
- [ ] Backup and recovery automation
- [ ] Monitoring and alerting setup
- [ ] Azure Policy assignments

## 📌 Version History

- **v1.0** - Initial release with standard configuration
  - 3 Windows Server 2025 VMs
  - 1 Windows 11 workstation
  - 1 SQL Server 2022
  - Azure Bastion
  - Multi-environment support

---

**Built with ❤️ for Windows Server professionals**

Made by Adrian Johnson | [GitHub](https://github.com/adrian207/Azure-Win-Lab)

