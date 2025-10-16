# Quick Start Guide - Azure Windows Server Lab

## 🎯 Get Started in 5 Minutes

### Step 1: Configure Your Credentials
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update:
- `admin_password` - Your VM administrator password
- `sql_admin_password` - Your SQL Server password

### Step 2: Login to Azure
```bash
az login
az account set --subscription "Your-Subscription-Name"
```

### Step 3: Deploy
```bash
./scripts/deploy.sh
```

### Step 4: Connect
1. Go to Azure Portal
2. Find your Resource Group (check output from Step 3)
3. Select any VM
4. Click **Connect** → **Bastion**
5. Enter credentials from `terraform.tfvars`

## 📦 What Gets Deployed

- ✅ 3x Windows Server 2025 Datacenter (dc1, dc2, dc3)
- ✅ 1x Windows 11 Enterprise Workstation (ws01)
- ✅ 1x SQL Server 2022 Developer Edition (sql01)
- ✅ 1x Azure Bastion (secure RDP access)
- ✅ Complete networking (VNet, subnets, NSGs)

## 💡 Common Commands

### View Resources
```bash
terraform output connection_instructions
```

### Destroy Everything
```bash
./scripts/destroy.sh
```

### Deploy Different Environment
```bash
# Dev environment (smaller VMs, lower cost)
terraform apply -var-file=environments/dev/terraform.tfvars.example

# Demo environment (larger VMs, better performance)
terraform apply -var-file=environments/demo/terraform.tfvars.example
```

## 💰 Cost Control

**Auto-shutdown is enabled by default!**

VMs automatically shut down at 7:00 PM Eastern Time.

To disable:
```hcl
enable_auto_shutdown = false
```

## 🆘 Quick Troubleshooting

### "Password doesn't meet requirements"
Passwords must be 12+ characters with uppercase, lowercase, and numbers.

### "Quota exceeded"
Request quota increase in Azure Portal for your region.

### "Cannot connect via Bastion"
Wait 2-3 minutes after deployment completes for Bastion to fully initialize.

## 📖 Full Documentation

See [README.md](README.md) for complete documentation.

---

**Repository:** https://github.com/adrian207/Azure-Win-Lab

