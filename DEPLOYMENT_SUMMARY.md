# 🎉 Azure Lab - Deployment Summary

Your Azure Lab repository now has **TWO complete architectures** to choose from!

---

## ✅ What's Been Created

### 🌳 Branch: `master` (Traditional Windows)
**Architecture**: Windows Server-focused  
**Monthly Cost**: $270 (12hr/day)  
**GitHub**: https://github.com/adrian207/Azure-Win-Lab/tree/master

**Components**:
- 3x Windows Server 2025 (Active Directory)
- 1x Windows 11 Workstation
- 1x SQL Server 2022 VM
- 2x Red Hat Enterprise Linux 9.4
- 1x Azure Bastion

**Perfect For**:
- Windows Server certification prep
- Active Directory mastery
- Group Policy learning
- Traditional enterprise IT

---

### 🐳 Branch: `hybrid-docker` (Modern Containers)
**Architecture**: Docker-based  
**Monthly Cost**: $70 (12hr/day) - **74% savings!**  
**GitHub**: https://github.com/adrian207/Azure-Win-Lab/tree/hybrid-docker

**Components**:
- 1x Linux Docker Host with 10+ containers:
  - Samba AD DC (Active Directory replacement)
  - SQL Server 2022 on Linux
  - PostgreSQL 16
  - MongoDB 7
  - Redis 7
  - Nginx web server
  - Portainer (Docker GUI)
  - GitLab CE (DevOps)
  - Jenkins (CI/CD)
  - Adminer (Database GUI)
- 1x Windows 11 Workstation
- 1x Azure Bastion

**Perfect For**:
- Docker & container learning
- DevOps skills
- Cost-conscious labs
- Modern cloud-native development

---

## 📊 Quick Comparison

| Aspect | Master (Windows) | Hybrid-Docker |
|--------|------------------|---------------|
| **Monthly Cost** | $270 | $70 |
| **Annual Cost** | $3,240 | $840 |
| **Number of VMs** | 7 | 2 |
| **Startup Time** | 3-5 minutes | 10-30 seconds |
| **Focus** | Windows Admin | DevOps/Containers |
| **Market Demand** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 🚀 How to Deploy

### Option 1: Windows Architecture (Master)

```bash
cd /Users/v-a.johnson/Documents/WinAutoLab
git checkout master
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your passwords
vim terraform.tfvars

# Deploy
terraform init
terraform apply

# When done, connect via Azure Portal → Bastion
```

**What you'll get**: Full Windows Server lab environment

---

### Option 2: Docker Architecture (Hybrid)

```bash
cd /Users/v-a.johnson/Documents/WinAutoLab
git checkout hybrid-docker
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your passwords and SSH key
vim terraform.tfvars

# Deploy
terraform init
terraform apply

# When done:
# - SSH to Docker host
# - Access Portainer at http://<docker-ip>:9000
# - RDP to Windows 11 via Bastion
```

**What you'll get**: Docker-based lab with 10+ services

---

## 💡 Which One Should You Deploy?

### Deploy **Master** if:
✅ Learning Windows Server administration  
✅ Studying for Windows certifications  
✅ Need full Active Directory features  
✅ Cost is not a primary concern

### Deploy **Hybrid-Docker** if:
✅ Want to learn Docker and DevOps  
✅ Need to minimize costs (save $200/month)  
✅ Interested in modern cloud-native skills  
✅ Want hands-on with CI/CD tools

### Deploy **BOTH** if:
✅ You want comprehensive Windows + Docker skills  
✅ Use different Azure subscriptions or resource groups  
✅ You have the budget ($340/month total)

---

## 📁 Repository Structure

```
Azure-Win-Lab/
├── master branch (Windows Server focus)
│   ├── README.md (Professional enterprise docs)
│   ├── QUICK_START.md
│   ├── modules/
│   │   ├── windows-server/
│   │   ├── windows11-workstation/
│   │   ├── sql-server/
│   │   ├── redhat-linux/
│   │   ├── networking/
│   │   └── bastion/
│   └── BRANCH_GUIDE.md
│
└── hybrid-docker branch (Docker focus)
    ├── README_HYBRID.md
    ├── BRANCH_GUIDE.md
    ├── modules/
    │   ├── docker-host/
    │   │   ├── main.tf
    │   │   ├── scripts/
    │   │   │   ├── cloud-init.yaml
    │   │   │   └── docker-compose.yml (10+ services)
    │   ├── windows11-workstation/
    │   ├── networking/
    │   └── bastion/
    └── terraform.tfvars.example
```

---

## 📚 Key Documentation Files

| File | Purpose | Location |
|------|---------|----------|
| **README.md** | Professional enterprise docs | master |
| **README_HYBRID.md** | Docker architecture guide | hybrid-docker |
| **BRANCH_GUIDE.md** | Compare both architectures | Both branches |
| **QUICK_START.md** | Fast deployment guide | master |
| **COST_ANALYSIS_CONTAINERS.md** | VM vs container costs | Both branches |
| **COST_ANALYSIS_LINUX_ALTERNATIVE.md** | Linux + Docker deep dive | Both branches |

---

## 💰 Cost Savings Analysis

### Scenario 1: Master Only (Windows Learning)
- **Cost**: $270/month
- **Annual**: $3,240
- **Learning**: Windows Server, AD DS, SQL Server

### Scenario 2: Hybrid-Docker Only (DevOps Learning)
- **Cost**: $70/month
- **Annual**: $840
- **Savings vs Master**: $2,400/year (74%)
- **Learning**: Docker, CI/CD, Containers, Modern databases

### Scenario 3: Both (Complete Learning)
Month 1-2: Master ($540 total)  
Month 3+: Switch to Hybrid-Docker ($70/month ongoing)

- **First 2 months**: $540
- **Ongoing**: $70/month
- **Year 1**: $1,240
- **vs. Master year-round**: Save $2,000

---

## 🔄 Switching Between Branches

```bash
# Currently on master? Switch to Docker
git checkout hybrid-docker
terraform destroy  # Destroy Windows infrastructure first
terraform init
terraform apply

# Currently on hybrid-docker? Switch to Windows
git checkout master
terraform destroy  # Destroy Docker infrastructure first
terraform init
terraform apply
```

**Important**: Always `terraform destroy` before switching branches to avoid conflicts!

---

## 🎯 Next Steps

### Immediate Actions:

1. **Choose your architecture** (or deploy both!)
2. **Copy `terraform.tfvars.example` to `terraform.tfvars`**
3. **Edit passwords and credentials**
4. **Generate SSH key** (for hybrid-docker): `ssh-keygen -t rsa -b 4096`
5. **Run `terraform apply`**
6. **Wait ~15 minutes for deployment**
7. **Access via Azure Portal → Bastion**

### Learning Path:

**Beginner**:
- Start with `hybrid-docker` (easier, cheaper)
- Learn Docker basics
- Experiment with containers

**Intermediate**:
- Deploy `master` for Windows Server skills
- Practice Active Directory
- Learn Group Policy

**Advanced**:
- Deploy both in different environments
- Set up hybrid connectivity
- Practice disaster recovery

---

## 🆘 Getting Help

- **Issues**: https://github.com/adrian207/Azure-Win-Lab/issues
- **Documentation**: See README files in each branch
- **Troubleshooting**: Check respective README files
- **Cost questions**: See COST_ANALYSIS_*.md files

---

## 🎉 What You've Achieved

✅ Complete Windows Server lab infrastructure (Terraform)  
✅ Cost-optimized Docker alternative (Terraform)  
✅ Production-ready IaC with best practices  
✅ Comprehensive documentation  
✅ Automated deployment scripts  
✅ Security-first architecture (Bastion, NSGs)  
✅ Cost controls (auto-shutdown)  
✅ Two complete learning paths  
✅ Version-controlled infrastructure  
✅ Professional GitHub repository  

---

## 📈 Recommended Learning Path

### Month 1-2: Foundation
- Deploy `hybrid-docker` (lower cost)
- Learn Docker basics
- Experiment with containers
- Practice CI/CD with GitLab/Jenkins

### Month 3-4: Windows Skills
- Deploy `master` 
- Learn Active Directory
- Practice Group Policy
- Understand Windows Server

### Month 5+: Advanced
- Hybrid scenarios
- Container orchestration
- Advanced networking
- Production readiness

**Total Investment**: ~$1,240 first year  
**Skills Gained**: Windows + Linux + Docker + DevOps  
**Job Market Value**: ⭐⭐⭐⭐⭐

---

## 🎊 You're All Set!

Both architectures are ready to deploy. Choose your path and start learning!

**Quick Start Commands**:

```bash
# Docker architecture (recommended for beginners)
cd /Users/v-a.johnson/Documents/WinAutoLab
git checkout hybrid-docker
cat README_HYBRID.md

# Windows architecture (for Windows career)
cd /Users/v-a.johnson/Documents/WinAutoLab
git checkout master
cat README.md
```

Happy learning! 🚀

---

**Repository**: https://github.com/adrian207/Azure-Win-Lab  
**Branches**:
- `master` - Windows Server focus
- `hybrid-docker` - Docker/DevOps focus

Choose your adventure! 🎓

