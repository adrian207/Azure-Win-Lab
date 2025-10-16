# Branch Guide: Choosing Your Lab Architecture

This repository offers **two complete lab architectures** - choose based on your learning goals and budget.

---

## 🌳 Branches Overview

| Branch | Architecture | Monthly Cost | Focus | Best For |
|--------|-------------|--------------|-------|----------|
| **master** | Traditional Windows | $270 | Windows Server | Windows Admin, MCSA/MCSE |
| **hybrid-docker** | Linux + Containers | $70 | Docker + DevOps | Modern DevOps, Cost savings |

---

## 🪟 Master Branch (Traditional Windows)

### What You Get
- 3x Windows Server 2025 Datacenter (Active Directory)
- 1x Windows 11 Workstation
- 1x SQL Server 2022 VM
- 2x Red Hat Enterprise Linux 9.4
- 1x Azure Bastion Host

### Cost
- **$270/month** (12 hours/day with auto-shutdown)
- **$540/month** (24/7 operation)

### Learning Focus
- ✅ Windows Server Administration
- ✅ Active Directory Domain Services (Full AD DS)
- ✅ Group Policy management
- ✅ Windows Server clustering
- ✅ SQL Server on Windows
- ✅ PowerShell DSC
- ✅ Windows-centric environments

### Use This If You Want To:
- 🎯 Prepare for Windows Server certifications
- 🎯 Learn traditional enterprise IT
- 🎯 Practice Active Directory administration
- 🎯 Master Group Policy
- 🎯 Work in Windows-heavy environments
- 🎯 Simulate production Windows infrastructure

### Deploy Master Branch
```bash
git checkout master
terraform init
terraform apply
```

---

## 🐳 Hybrid-Docker Branch (Modern Containers)

### What You Get
- 1x Linux Docker Host (Ubuntu 22.04)
  - Samba AD DC (Active Directory replacement)
  - SQL Server 2022 on Linux
  - PostgreSQL 16
  - MongoDB 7
  - Redis 7
  - Nginx
  - Portainer (Docker GUI)
  - GitLab CE
  - Jenkins
  - Adminer (Database GUI)
- 1x Windows 11 Workstation
- 1x Azure Bastion Host

### Cost
- **$70/month** (12 hours/day with auto-shutdown)
- **$140/month** (24/7 operation)
- **74% cheaper** than master branch

### Learning Focus
- ✅ Docker & Docker Compose
- ✅ Container orchestration
- ✅ DevOps practices
- ✅ CI/CD pipelines (GitLab + Jenkins)
- ✅ Modern microservices
- ✅ Multi-database architectures
- ✅ Samba AD (90% compatible with Windows AD)
- ✅ Infrastructure automation

### Use This If You Want To:
- 🎯 Learn Docker and containers
- 🎯 Build DevOps skills
- 🎯 Minimize costs (save $200/month)
- 🎯 Practice modern cloud-native development
- 🎯 Explore microservices architecture
- 🎯 Get hands-on with CI/CD tools
- 🎯 Prepare for Docker/Kubernetes certifications

### Deploy Hybrid-Docker Branch
```bash
git checkout hybrid-docker
terraform init
terraform apply
```

---

## 📊 Detailed Comparison

### Feature Matrix

| Feature | Master (Windows) | Hybrid (Docker) |
|---------|------------------|-----------------|
| **Infrastructure** |
| Number of VMs | 7 | 2 |
| Linux Hosts | 2 RHEL VMs | 1 Ubuntu + containers |
| Windows Hosts | 4 Windows VMs | 1 Windows 11 VM |
| **Costs** |
| Monthly (12hr) | $270 | $70 |
| Monthly (24hr) | $540 | $140 |
| Annual (12hr) | $3,240 | $840 |
| **Savings vs Master** | Baseline | -74% |
| **Active Directory** |
| Technology | Windows AD DS | Samba AD DC |
| Domain Services | ✅ Full | ✅ 90% |
| Group Policy | ✅ Complete | ⚠️ Basic |
| LDAP | ✅ | ✅ |
| Kerberos | ✅ | ✅ |
| Domain Join | ✅ | ✅ |
| **Databases** |
| SQL Server | Windows VM | Linux container |
| PostgreSQL | ❌ | ✅ |
| MongoDB | ❌ | ✅ |
| Redis | ❌ | ✅ |
| **DevOps Tools** |
| GitLab | ❌ | ✅ |
| Jenkins | ❌ | ✅ |
| Container Registry | ❌ | ✅ |
| **Management** |
| RDP Access | ✅ 4 VMs | ✅ 1 VM |
| SSH Access | ✅ 2 VMs | ✅ 1 VM |
| Web UI | ❌ | ✅ Portainer |
| CLI Tools | PowerShell | Docker Compose |
| **Performance** |
| Startup Time | 3-5 minutes | 10-30 seconds |
| Resource Usage | High | Low |
| Scalability | Manual | `docker-compose scale` |
| **Learning Value** |
| Windows Admin | ✅✅✅ | ⚠️ |
| Linux Admin | ⚠️ | ✅✅✅ |
| Docker/Containers | ❌ | ✅✅✅ |
| DevOps | ⚠️ | ✅✅✅ |
| Cloud Native | ⚠️ | ✅✅✅ |
| **Job Market** |
| Windows Sysadmin | ✅✅✅ | ⚠️ |
| DevOps Engineer | ⚠️ | ✅✅✅ |
| Cloud Engineer | ✅✅ | ✅✅✅ |
| Site Reliability Engineer | ⚠️ | ✅✅✅ |

---

## 💡 Decision Guide

### Choose **MASTER** if:
1. ✅ You're studying for Windows Server certifications (MCSA equivalent, MCSE equivalent)
2. ✅ Your job requires deep Windows Server knowledge
3. ✅ You need to practice Group Policy extensively
4. ✅ You're working in traditional enterprise IT
5. ✅ You need Windows-specific features (Exchange, SharePoint labs)
6. ✅ Cost is not a primary concern
7. ✅ You want the most realistic Windows production simulation

### Choose **HYBRID-DOCKER** if:
1. ✅ You want to learn modern DevOps practices
2. ✅ Cost is a concern (save $200/month)
3. ✅ You're interested in containers and microservices
4. ✅ You want to learn Docker, GitLab, Jenkins
5. ✅ You're studying for cloud certifications (Azure, AWS, Docker, K8s)
6. ✅ You prefer cloud-native development
7. ✅ You want the most job-relevant modern skills

### Can't Decide? Deploy BOTH!

You can deploy both architectures simultaneously in different environments:

```bash
# Create separate workspaces
terraform workspace new windows-lab
terraform workspace new docker-lab

# Deploy Windows architecture
terraform workspace select windows-lab
git checkout master
terraform apply

# Deploy Docker architecture
terraform workspace select docker-lab
git checkout hybrid-docker
terraform apply

# Switch between them
terraform workspace select windows-lab  # Work with Windows
terraform workspace select docker-lab   # Work with Docker
```

Or deploy to different resource groups:

```bash
# Windows lab
cd ~/windows-lab
git clone <repo-url> .
git checkout master
terraform init
terraform apply

# Docker lab  
cd ~/docker-lab
git clone <repo-url> .
git checkout hybrid-docker
terraform init
terraform apply
```

---

## 🔄 Switching Between Branches

### Important: Destroy Before Switching

```bash
# If you have infrastructure deployed
terraform destroy  # Destroy current architecture

# Switch branches
git checkout <other-branch>

# Deploy new architecture
terraform init
terraform apply
```

### Or: Use Different State Files

```bash
# Use custom state file names
terraform init -backend-config="key=windows-lab.tfstate"  # Master
terraform init -backend-config="key=docker-lab.tfstate"   # Hybrid
```

---

## 📈 ROI Analysis

### Master Branch
**Investment**: $270/month  
**Skills Gained**: Windows Server, AD DS, Group Policy  
**Job Roles**: Windows Sysadmin, Traditional IT  
**Market Demand**: ⭐⭐⭐ Stable but declining

### Hybrid-Docker Branch
**Investment**: $70/month  
**Skills Gained**: Docker, DevOps, CI/CD, Containers  
**Job Roles**: DevOps Engineer, SRE, Cloud Engineer  
**Market Demand**: ⭐⭐⭐⭐⭐ High and growing

---

## 🎯 Recommended Path

### For Complete Learning (Budget: $340/month)
1. **Month 1-2**: Deploy `master` - Learn Windows Server fundamentals
2. **Month 3-4**: Deploy `hybrid-docker` - Learn Docker and DevOps
3. **Month 5+**: Keep `hybrid-docker` (cheaper) for ongoing practice

**Total Investment**: $1,020 for comprehensive Windows + Docker skills  
**Ongoing Cost**: $70/month (hybrid-docker only)

### For Budget-Conscious (Budget: $70/month)
1. **Deploy**: `hybrid-docker` branch only
2. **Focus**: Modern DevOps and cloud-native skills
3. **Result**: Best value for money

**Total Investment**: $70/month  
**Skills**: Docker, CI/CD, Modern databases, Some AD experience

### For Windows Career (Budget: $270/month)
1. **Deploy**: `master` branch only
2. **Focus**: Windows Server mastery
3. **Result**: Traditional IT skills

**Total Investment**: $270/month  
**Skills**: Windows Server, AD DS, Group Policy, SQL Server

---

## 🆘 Support

Both branches are fully supported with:
- ✅ Complete Terraform modules
- ✅ Detailed documentation
- ✅ Auto-shutdown for cost savings
- ✅ Azure Bastion for security
- ✅ Example configurations
- ✅ Troubleshooting guides

---

## 📞 Getting Help

- **Issues**: [GitHub Issues](https://github.com/yourusername/Azure-Win-Lab/issues)
- **Questions**: [GitHub Discussions](https://github.com/yourusername/Azure-Win-Lab/discussions)
- **Documentation**: 
  - Master: `README.md`
  - Hybrid: `README_HYBRID.md`

---

## 🚀 Quick Start Commands

### Master (Windows Focus)
```bash
git clone <repo-url>
cd Azure-Win-Lab
git checkout master
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars
terraform init
terraform apply
```

### Hybrid-Docker (DevOps Focus)
```bash
git clone <repo-url>
cd Azure-Win-Lab
git checkout hybrid-docker
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars
terraform init
terraform apply
```

---

**Bottom Line**:  
- 🪟 **Windows career** → `master`  
- 🐳 **DevOps career** → `hybrid-docker`  
- 💰 **Save money** → `hybrid-docker`  
- 📚 **Learn everything** → Start with `master`, switch to `hybrid-docker`

Choose your path and start learning! 🎓

