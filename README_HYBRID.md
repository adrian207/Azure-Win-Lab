# Azure Hybrid Lab - Docker Edition 🐳

> **Cost-optimized hybrid architecture** combining Docker containers and Windows 11  
> **74% cost savings** compared to traditional VM-based approach

---

## 🎯 What Is This?

This is the **hybrid Docker** variant of the Azure Lab environment. Instead of deploying 7 separate VMs, we use:

- **1 Linux Docker Host** (runs all server workloads in containers)
- **1 Windows 11 VM** (for client testing)
- **1 Azure Bastion** (secure access)

**Result**: Same functionality, **$70/month instead of $270/month**

---

## 📊 Architecture Comparison

### Traditional (Master Branch)
```
3x Windows Server 2025  → $105/month
1x Windows 11          → $35/month
1x SQL Server VM       → $70/month
2x RHEL VMs            → $70/month
                         ─────────
Total:                   $270/month
```

### Hybrid Docker (This Branch)
```
1x Docker Host         → $35/month
  ├─ Samba AD DC       (container)
  ├─ SQL Server 2022   (container)
  ├─ PostgreSQL        (container)
  ├─ MongoDB           (container)
  ├─ Redis             (container)
  ├─ Nginx             (container)
  ├─ Portainer         (container)
  ├─ GitLab            (container)
  └─ Jenkins           (container)

1x Windows 11          → $35/month
                         ─────────
Total:                   $70/month

Savings: $200/month (74%)
```

---

## 🚀 What Gets Deployed

### Docker Host (Ubuntu 22.04)
**VM Size**: Standard_D4s_v3 (4 vCPU, 16 GB RAM)

**Containers Included**:
| Service | Purpose | Port |
|---------|---------|------|
| **Samba AD DC** | Active Directory (domain controller) | 445, 389, 636 |
| **SQL Server 2022** | Microsoft SQL Server on Linux | 1433 |
| **PostgreSQL 16** | Open-source database | 5432 |
| **MongoDB 7** | NoSQL database | 27017 |
| **Redis 7** | Cache & message broker | 6379 |
| **Nginx** | Web server | 80, 443 |
| **Portainer** | Docker GUI management | 9000 |
| **GitLab CE** | DevOps platform | 8080 |
| **Jenkins** | CI/CD automation | 8081 |
| **Adminer** | Database GUI | 8082 |

### Windows 11 Workstation
- Full desktop experience
- Can join Samba domain
- RDP access via Azure Bastion
- Client testing environment

### Azure Bastion
- Secure RDP/SSH access
- No public IP exposure
- PCI-DSS compliant

---

## ⚡ Quick Start

### Prerequisites
- Azure subscription
- Terraform installed
- Azure CLI installed
- SSH key pair (optional but recommended)

### Deploy

```bash
# Clone the repository
git clone https://github.com/yourusername/Azure-Win-Lab.git
cd Azure-Win-Lab

# Switch to hybrid-docker branch
git checkout hybrid-docker

# Copy example config
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your settings
vim terraform.tfvars

# Initialize Terraform
terraform init

# Preview deployment
terraform plan

# Deploy (takes ~15 minutes)
terraform apply

# Get connection info
terraform output connection_instructions
```

### Access Your Lab

**1. Docker Host (via SSH)**
```bash
# SSH to Docker host (via Bastion or direct)
ssh azureuser@<docker-host-ip>

# Check running containers
docker ps

# Or use the helper script
lab status
lab logs portainer
lab shell samba-ad
```

**2. Portainer Web UI**
- Open browser: `http://<docker-host-ip>:9000`
- Create admin account on first login
- Manage all containers visually

**3. Windows 11 (via Bastion RDP)**
- Azure Portal → VM → Connect → Bastion
- Username: `labadmin`
- Password: [from terraform.tfvars]

---

## 🔧 Managing Services

### Using the `lab` Command

```bash
lab start           # Start all containers
lab stop            # Stop all containers
lab restart         # Restart all containers
lab status          # Show container status
lab logs nginx      # View Nginx logs
lab shell postgres  # Open shell in PostgreSQL container
```

### Using Docker Compose

```bash
cd /opt/lab

# View all services
docker-compose ps

# View logs
docker-compose logs -f
docker-compose logs -f sql-server

# Restart specific service
docker-compose restart nginx

# Stop everything
docker-compose down

# Start everything
docker-compose up -d

# Scale a service
docker-compose up -d --scale nginx=3
```

### Using Portainer (Recommended)

1. Open `http://<docker-host-ip>:9000`
2. Click on "Containers"
3. Manage containers via web UI:
   - Start/Stop/Restart
   - View logs
   - Open console
   - Inspect
   - Monitor stats

---

## 🗄️ Database Access

### SQL Server

```bash
# From Docker host
docker exec -it sql-server /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourPassword'

# From Windows 11
SQL Server Management Studio:
  Server: <docker-host-ip>,1433
  Login: sa
  Password: [from terraform.tfvars]

# Via Adminer
http://<docker-host-ip>:8082
```

### PostgreSQL

```bash
# From Docker host
docker exec -it postgres psql -U postgres

# From any client
psql -h <docker-host-ip> -U postgres -d labdb
```

### MongoDB

```bash
# From Docker host
docker exec -it mongodb mongosh -u admin -p 'YourPassword'

# From any client
mongosh mongodb://admin:password@<docker-host-ip>:27017
```

---

## 🏢 Active Directory (Samba)

### Features
- ✅ Full AD DC functionality
- ✅ LDAP authentication
- ✅ Kerberos
- ✅ Windows domain join support
- ✅ User/Group management
- ⚠️ Limited Group Policy support

### Domain Join Windows 11

```powershell
# On Windows 11 VM
Add-Computer -DomainName lab.local -Credential LAB\Administrator
Restart-Computer
```

### Manage Users

```bash
# SSH to Docker host
docker exec -it samba-ad samba-tool user add jdoe Password123!
docker exec -it samba-ad samba-tool user list
docker exec -it samba-ad samba-tool group addmembers "Domain Admins" jdoe
```

---

## 💰 Cost Analysis

### Monthly Costs (12 hours/day usage)

| Resource | Type | Size | Cost |
|----------|------|------|------|
| Docker Host | Linux VM | D4s_v3 | $35 |
| Windows 11 | Windows VM | D2s_v3 | $35 |
| Bastion | Service | Standard | $0 (SSH) |
| Storage | Premium SSD | 384 GB | $15 |
| **Total** | | | **$85** |

**With auto-shutdown (12hr/day)**: ~$70/month

### Comparison

```
Traditional:  $270/month
Hybrid:       $70/month
Savings:      $200/month (74%)
Annual:       $2,400/year saved
```

---

## 📚 What You Can Learn

### Docker & Containers
- ✅ Docker Compose
- ✅ Container networking
- ✅ Volume management
- ✅ Multi-container applications
- ✅ Portainer administration

### DevOps
- ✅ GitLab (Git, CI/CD, container registry)
- ✅ Jenkins (build pipelines)
- ✅ Infrastructure as Code (Terraform)

### Databases
- ✅ SQL Server on Linux
- ✅ PostgreSQL
- ✅ MongoDB
- ✅ Redis

### Networking
- ✅ Samba AD DC
- ✅ DNS
- ✅ LDAP/Kerberos
- ✅ Azure networking

### Windows Integration
- ✅ Domain join
- ✅ Hybrid authentication
- ✅ Windows-Linux interop

---

## 🔄 Switching Between Architectures

### Switch to Docker (this branch)
```bash
git checkout hybrid-docker
terraform init
terraform apply
```

### Switch back to Traditional Windows
```bash
git checkout master
terraform init
terraform apply
```

### Deploy Both (different environments)
```bash
# Docker version
cd environments/docker-lab
terraform init
terraform apply

# Traditional version
cd environments/windows-lab
terraform init
terraform apply
```

---

## 🛠️ Customization

### Add More Containers

Edit `modules/docker-host/scripts/docker-compose.yml`:

```yaml
services:
  # Add your custom service
  myapp:
    image: myapp:latest
    container_name: myapp
    ports:
      - "8000:8000"
    networks:
      - lab-network
    restart: unless-stopped
```

Then restart:
```bash
cd /opt/lab
docker-compose up -d
```

### Change VM Sizes

In `terraform.tfvars`:
```hcl
docker_host_vm_size = "Standard_D8s_v3"  # More power
workstation_vm_size = "Standard_B2s"     # Save money
```

### Disable Auto-Shutdown

```hcl
enable_auto_shutdown = false
```

---

## 📖 Comparing to Master Branch

| Feature | Master (Windows) | Hybrid (Docker) |
|---------|-----------------|-----------------|
| **Cost** | $270/month | $70/month |
| **VMs** | 7 VMs | 2 VMs |
| **Active Directory** | Windows AD DS | Samba AD DC |
| **SQL Server** | Windows VM | Linux container |
| **Startup Time** | 3-5 min | 10-30 sec |
| **Scalability** | Manual | `docker-compose scale` |
| **Portability** | Low | High |
| **Windows Learning** | ✅ Full | ⚠️ Client only |
| **Docker Learning** | ❌ None | ✅ Full |
| **DevOps Focus** | ⚠️ Limited | ✅ High |
| **Job Market** | Windows Admin | DevOps/Cloud |

---

## 🎓 Use Cases

### ✅ Perfect For:
- Learning Docker and containers
- DevOps skill building
- Cost-conscious labs
- Modern application development
- CI/CD pipeline testing
- Microservices exploration
- Linux system administration
- Hybrid cloud scenarios

### ⚠️ Not Ideal For:
- Windows Server certification (MCSA/MCSE equivalent)
- Full Group Policy testing
- Windows-specific application testing
- Exchange/SharePoint labs
- Pure Windows administration practice

**For Windows Server learning**, use the `master` branch instead.

---

## 🆘 Troubleshooting

### Containers Won't Start

```bash
# Check Docker status
systemctl status docker

# View logs
docker-compose logs -f

# Restart Docker
systemctl restart docker
cd /opt/lab && docker-compose up -d
```

### Can't Access Services

```bash
# Check container status
docker ps

# Check networking
docker network ls
docker network inspect lab_lab-network

# Check firewall
sudo ufw status
```

### Windows Can't Join Domain

```bash
# Verify Samba AD is running
docker logs samba-ad-dc

# Check DNS
nslookup dc1.lab.local
ping dc1.lab.local

# Verify ports
netstat -tlnp | grep -E '(389|445|636)'
```

---

## 📞 Support

- **Issues**: Open GitHub issue
- **Discussions**: GitHub Discussions
- **Documentation**: See `/docs` folder

---

## 🔗 Related Documentation

- [Cost Analysis](COST_ANALYSIS_LINUX_ALTERNATIVE.md) - Detailed cost breakdown
- [Container Cost Analysis](COST_ANALYSIS_CONTAINERS.md) - VM vs Container comparison
- [Quick Start](QUICK_START.md) - Fast deployment guide
- [Master Branch](README.md) - Traditional Windows architecture

---

## 📜 License

MIT License - See LICENSE file

---

## ⭐ Acknowledgments

Built for IT professionals who want to learn modern DevOps practices while still maintaining Windows client testing capabilities.

**Choose your path**:
- 🐳 **This branch (hybrid-docker)**: Modern, cost-effective, container-focused
- 🪟 **Master branch**: Traditional, Windows Server-focused, full AD DS

Both are valid - pick what matches your learning goals! 🚀

