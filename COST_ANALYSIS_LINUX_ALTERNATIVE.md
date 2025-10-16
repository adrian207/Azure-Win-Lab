# Cost Analysis: Linux + Docker vs. Windows Server Architecture

## The Question

**"What about using Docker instead of Windows for hosts?"**

**Translation**: Replace Windows Servers entirely with Linux hosts running Docker containers

---

## Executive Summary

**TL;DR**: Using **Linux + Docker instead of Windows Server** is **massively cheaper**:

| Architecture | Monthly Cost (12hr/day) | Savings |
|--------------|-------------------------|---------|
| **Current (Windows+Linux)** | $270 | Baseline |
| **Linux-only + Docker** | **$51** | **81% cheaper** |
| **Linux + Docker + Windows 11 only** | **$86** | **68% cheaper** |

**BUT**: You lose Windows Server capabilities (AD DS, Windows-specific features)

---

## Cost Breakdown: Linux + Docker Architecture

### Proposed Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Single Linux VM (Standard_D4s_v3)                      │
│  4 vCPU, 16 GB RAM                                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Docker Host (Ubuntu/Debian)                            │
│  ┌────────────────────────────────────────────────┐   │
│  │  Docker Containers:                             │   │
│  │  ├─ Samba AD DC (Active Directory replacement) │   │
│  │  ├─ PostgreSQL (Database)                       │   │
│  │  ├─ Nginx/Apache (Web server)                   │   │
│  │  ├─ Redis (Caching)                             │   │
│  │  ├─ GitLab/Jenkins (DevOps)                     │   │
│  │  ├─ Portainer (Container management GUI)        │   │
│  │  └─ Multiple application containers             │   │
│  └────────────────────────────────────────────────┘   │
│                                                          │
└─────────────────────────────────────────────────────────┘

Optional: Windows 11 VM (for client testing)
```

### Cost Calculation

| Component | Type | Monthly Cost (12hr) |
|-----------|------|---------------------|
| **1x Linux VM** (D4s_v3) | Host | $35 |
| Azure Bastion | Service | $0* (can use SSH) |
| Storage | Premium SSD | $15 |
| **Total (Linux-only)** | | **$50** |
| | | |
| **+ Windows 11 (optional)** | VM | $35 |
| **Total (Hybrid)** | | **$85** |

*SSH directly to Linux VM (no Bastion needed)

### vs. Current Architecture

```
Current: $270/month (5 Windows VMs + 2 Linux VMs + Bastion)
Linux + Docker: $50/month (1 Linux VM)
Windows 11 + Linux + Docker: $85/month (2 VMs total)

Savings: $220/month (81%) or $185/month (68%)
Annual savings: $2,640 or $2,220
```

---

## Detailed Comparison

### 1. Active Directory → Samba AD DC

#### Current: 3x Windows Server 2025 (for AD DS)
- **Cost**: $105/month
- **Features**: Full Active Directory Domain Services
- **Capabilities**:
  - User/computer authentication
  - Group Policy
  - LDAP
  - Kerberos
  - DNS integration
  - Domain join

#### Alternative: Samba AD DC (Docker container)
- **Cost**: $0 (runs on Linux host)
- **Features**: 90% compatible with Windows AD
- **Capabilities**:
  - ✅ User/computer authentication
  - ✅ LDAP
  - ✅ Kerberos
  - ✅ DNS integration
  - ✅ Domain join (Windows clients can join)
  - ⚠️ Limited Group Policy support
  - ⚠️ Some schema limitations

**Docker Compose:**
```yaml
version: '3.8'
services:
  samba-ad:
    image: nowsci/samba-domain
    container_name: samba-ad-dc
    hostname: dc1
    environment:
      - DOMAIN=LAB
      - DOMAINPASS=YourAdminPassword123!
      - DNSFORWARDER=8.8.8.8
      - HOSTIP=10.0.2.10
    ports:
      - "53:53"
      - "53:53/udp"
      - "88:88"
      - "88:88/udp"
      - "135:135"
      - "137-138:137-138/udp"
      - "139:139"
      - "389:389"
      - "389:389/udp"
      - "445:445"
      - "464:464"
      - "464:464/udp"
      - "636:636"
      - "3268-3269:3268-3269"
    volumes:
      - samba-data:/var/lib/samba
      - samba-config:/etc/samba
    networks:
      - lab-network
    restart: unless-stopped

volumes:
  samba-data:
  samba-config:

networks:
  lab-network:
    driver: bridge
```

**Savings**: $105/month → $0

---

### 2. SQL Server → PostgreSQL or MySQL

#### Current: SQL Server 2022 (D4s_v3 VM)
- **Cost**: $70/month
- **License**: Developer (free) or Standard ($730/month)

#### Alternative: PostgreSQL (Docker container)
- **Cost**: $0 (runs on Linux host)
- **License**: Free, open-source
- **Features**: 95% feature parity with SQL Server

**Docker Compose:**
```yaml
services:
  postgres:
    image: postgres:16
    container_name: postgres-db
    environment:
      POSTGRES_USER: sqladmin
      POSTGRES_PASSWORD: YourPassword123!
      POSTGRES_DB: labdb
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./backups:/backups
    networks:
      - lab-network
    restart: unless-stopped
  
  # SQL Server on Linux (if you need SQL Server specifically)
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: mssql
    environment:
      ACCEPT_EULA: "Y"
      SA_PASSWORD: "YourSQLPassword123!"
      MSSQL_PID: "Developer"
    ports:
      - "1433:1433"
    volumes:
      - mssql-data:/var/opt/mssql
    networks:
      - lab-network
    restart: unless-stopped

volumes:
  postgres-data:
  mssql-data:
```

**Savings**: $70/month → $0

---

### 3. Linux Workloads → Native Docker

#### Current: 2x RHEL VMs
- **Cost**: $70/month
- **Purpose**: Web servers, app servers

#### Alternative: Docker containers (native)
- **Cost**: $0 (runs on Linux host)
- **Better**: Container-native, faster, more efficient

**Docker Compose:**
```yaml
services:
  nginx:
    image: nginx:alpine
    container_name: web-server
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf:/etc/nginx/conf.d
      - ./web:/usr/share/nginx/html
    networks:
      - lab-network
    restart: unless-stopped
  
  redis:
    image: redis:7-alpine
    container_name: redis-cache
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - lab-network
    restart: unless-stopped
  
  mongodb:
    image: mongo:7
    container_name: mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db
    networks:
      - lab-network
    restart: unless-stopped

volumes:
  redis-data:
  mongo-data:
```

**Savings**: $70/month → $0

---

### 4. Windows 11 Workstation

#### Current: Windows 11 VM
- **Cost**: $35/month
- **Purpose**: Client testing, RDP access

#### Alternative Options:

**Option A**: Keep Windows 11 VM
- **Cost**: $35/month
- **Reason**: Cannot containerize desktop OS

**Option B**: Remove entirely
- **Cost**: $0/month
- **Alternative**: Use local Windows machine for testing

**Option C**: Use RDP container to Linux desktop
- **Cost**: $0
- **Desktop**: XFCE/KDE in container with noVNC

```yaml
services:
  linux-desktop:
    image: linuxserver/webtop:ubuntu-xfce
    container_name: linux-desktop
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
    ports:
      - "3000:3000"  # Web-based desktop
    volumes:
      - desktop-config:/config
    networks:
      - lab-network
    restart: unless-stopped
```

**Savings**: $35/month → $0 (if using Option B or C)

---

## Complete Linux + Docker Solution

### Single Docker Compose File

```yaml
# docker-compose.yml - Complete Lab Environment

version: '3.8'

services:
  # Active Directory (Samba)
  samba-ad:
    image: nowsci/samba-domain
    container_name: ad-dc
    hostname: dc1
    environment:
      DOMAIN: LAB
      DOMAINPASS: AdminPass123!
      DNSFORWARDER: 8.8.8.8
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "88:88/tcp"
      - "389:389/tcp"
      - "445:445"
      - "636:636"
    volumes:
      - samba-data:/var/lib/samba
    networks:
      lab-network:
        ipv4_address: 10.0.2.10
    restart: unless-stopped

  # SQL Server (Linux)
  mssql:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: sql-server
    environment:
      ACCEPT_EULA: "Y"
      SA_PASSWORD: "SQLPass123!"
      MSSQL_PID: "Developer"
    ports:
      - "1433:1433"
    volumes:
      - mssql-data:/var/opt/mssql
    networks:
      lab-network:
        ipv4_address: 10.0.2.20
    restart: unless-stopped

  # PostgreSQL (alternative)
  postgres:
    image: postgres:16
    container_name: postgres
    environment:
      POSTGRES_PASSWORD: PostgresPass123!
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      lab-network:
        ipv4_address: 10.0.2.21
    restart: unless-stopped

  # Web Server (Nginx)
  nginx:
    image: nginx:alpine
    container_name: web-server
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx:/etc/nginx/conf.d
      - ./web:/usr/share/nginx/html
    networks:
      lab-network:
        ipv4_address: 10.0.2.30
    restart: unless-stopped

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      lab-network:
        ipv4_address: 10.0.2.40
    restart: unless-stopped

  # MongoDB
  mongodb:
    image: mongo:7
    container_name: mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: MongoPass123!
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db
    networks:
      lab-network:
        ipv4_address: 10.0.2.50
    restart: unless-stopped

  # Portainer (Docker GUI)
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    ports:
      - "9000:9000"
      - "8000:8000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer-data:/data
    networks:
      - lab-network
    restart: unless-stopped

  # GitLab (DevOps)
  gitlab:
    image: gitlab/gitlab-ce:latest
    container_name: gitlab
    hostname: gitlab.lab.local
    ports:
      - "8080:80"
      - "8443:443"
      - "2222:22"
    volumes:
      - gitlab-config:/etc/gitlab
      - gitlab-logs:/var/log/gitlab
      - gitlab-data:/var/opt/gitlab
    networks:
      - lab-network
    restart: unless-stopped

volumes:
  samba-data:
  mssql-data:
  postgres-data:
  redis-data:
  mongo-data:
  portainer-data:
  gitlab-config:
  gitlab-logs:
  gitlab-data:

networks:
  lab-network:
    driver: bridge
    ipam:
      config:
        - subnet: 10.0.2.0/24
```

### Deployment

```bash
# On your Linux VM
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Scale services
docker-compose up -d --scale nginx=3

# Stop all
docker-compose down

# Stop and remove data
docker-compose down -v
```

---

## Terraform Implementation

### Linux Docker Host Module

```hcl
# modules/docker-host/main.tf

resource "azurerm_network_interface" "docker_host" {
  name                = "${var.environment_name}-docker-host-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "docker_host" {
  name                = "${var.environment_name}-docker-host"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  network_interface_ids = [azurerm_network_interface.docker_host.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Install Docker via cloud-init
  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
    docker_compose_file = file("${path.module}/docker-compose.yml")
  }))
}
```

### Cloud-init Configuration

```yaml
# modules/docker-host/cloud-init.yaml
#cloud-config

package_update: true
package_upgrade: true

packages:
  - docker.io
  - docker-compose
  - git
  - vim
  - htop

runcmd:
  # Enable Docker
  - systemctl enable docker
  - systemctl start docker
  
  # Add user to docker group
  - usermod -aG docker azureuser
  
  # Create lab directory
  - mkdir -p /opt/lab
  
  # Deploy docker-compose
  - |
    cat > /opt/lab/docker-compose.yml <<'EOF'
    ${docker_compose_file}
    EOF
  
  # Start containers
  - cd /opt/lab && docker-compose up -d
  
  # Install Portainer
  - docker volume create portainer_data
  - docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

write_files:
  - path: /etc/motd
    content: |
      ╔═══════════════════════════════════════════╗
      ║   Azure Docker Lab Environment            ║
      ║                                           ║
      ║   Portainer:    http://IP:9000           ║
      ║   Samba AD:     dc1.lab.local            ║
      ║   SQL Server:   IP:1433                  ║
      ║   PostgreSQL:   IP:5432                  ║
      ║   Web Server:   http://IP                ║
      ║                                           ║
      ║   Commands:                               ║
      ║   cd /opt/lab                            ║
      ║   docker-compose ps                      ║
      ║   docker-compose logs -f                 ║
      ╚═══════════════════════════════════════════╝
```

---

## Feature Comparison

### What You Gain

| Feature | Windows Server | Linux + Docker | Winner |
|---------|----------------|----------------|--------|
| **Cost** | $270/month | $50/month | ✅ Docker (81% cheaper) |
| **Startup Time** | 2-5 minutes | 5-10 seconds | ✅ Docker |
| **Resource Efficiency** | High overhead | Minimal overhead | ✅ Docker |
| **Scalability** | Manual | `docker-compose scale` | ✅ Docker |
| **Portability** | VM-bound | Container images | ✅ Docker |
| **Updates** | Windows Update (slow) | `docker-compose pull` | ✅ Docker |
| **Backup** | VM snapshots (GB) | Docker volumes (MB) | ✅ Docker |
| **Learning Value** | Windows Admin | DevOps/Containers | ✅ Docker (modern) |

### What You Lose

| Feature | Windows Server | Linux + Docker | Impact |
|---------|----------------|----------------|--------|
| **Active Directory** | Full AD DS | Samba AD (90%) | ⚠️ Minor |
| **Group Policy** | Complete | Limited | ⚠️ Moderate |
| **Windows Apps** | Native | Not supported | ❌ Major (if needed) |
| **GUI Management** | Full Desktop | CLI/Web UI | ⚠️ Minor |
| **Windows Testing** | Native | Requires Windows 11 VM | ⚠️ Minor |

---

## Use Case Recommendations

### ✅ Use Linux + Docker If:

1. **Cost is primary concern** (81% savings)
2. **Learning modern DevOps** (Docker, containers, microservices)
3. **Don't need Windows-specific features** (AD DS, Group Policy)
4. **Focus on application development** (web apps, APIs, databases)
5. **Want portability** (move containers anywhere)
6. **Need fast iteration** (spin up/down in seconds)

### ❌ Keep Windows Server If:

1. **Learning Windows Server administration** (MCSA, MCSE equivalent)
2. **Need full Active Directory** (complex Group Policies, schemas)
3. **Testing Windows applications** (.NET Framework apps, legacy)
4. **Simulating production Windows environments**
5. **PowerShell DSC, SCCM, WSUS** testing
6. **Windows-specific certifications**

---

## Hybrid Approach: Best of Both Worlds

### Recommended Architecture

```
Cost-Optimized Hybrid Lab:
├── 1x Linux VM (D4s_v3) - $35/month
│   ├── Docker containers (all Linux workloads)
│   ├── Samba AD DC
│   ├── SQL Server on Linux
│   ├── Web servers
│   ├── Databases
│   └── DevOps tools
│
└── 1x Windows 11 VM (D2s_v3) - $35/month (optional)
    └── Client testing, domain join, Windows apps

Total: $35-70/month (74-87% savings vs. current)
```

### Terraform for Hybrid

```hcl
# main.tf

# Linux Docker Host
module "docker_host" {
  source = "./modules/docker-host"
  
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  environment_name    = var.environment_name
  subnet_id           = module.networking.server_subnet_id
  
  vm_size         = "Standard_D4s_v3"
  admin_username  = "azureuser"
  ssh_public_key  = var.ssh_public_key
  
  tags = azurerm_resource_group.lab.tags
}

# Windows 11 (optional - only if you need Windows client)
module "windows11_workstation" {
  count = var.include_windows_client ? 1 : 0
  source = "./modules/windows11-workstation"
  
  # ... existing configuration
}

# NO MORE:
# - Windows Server VMs (replaced by Samba in Docker)
# - SQL Server VM (replaced by SQL container)
# - RHEL VMs (replaced by containers)
```

---

## Migration Path

### Phase 1: Parallel Deployment (Week 1)

```bash
# 1. Deploy Linux Docker host
terraform apply -target=module.docker_host

# 2. SSH to Linux host
ssh azureuser@<linux-vm-ip>

# 3. Verify containers
cd /opt/lab
docker-compose ps

# 4. Test services
curl http://localhost        # Nginx
psql -h localhost -U postgres  # PostgreSQL
```

### Phase 2: Migrate Data (Week 2)

```bash
# Migrate SQL Server database
# From Windows SQL VM
sqlcmd -S <windows-sql-vm> -U sa -Q "BACKUP DATABASE..."

# To Linux SQL container
docker exec -it mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U sa
> RESTORE DATABASE...
```

### Phase 3: Decommission Windows (Week 3)

```bash
# Once verified working
terraform destroy -target=module.windows_servers
terraform destroy -target=module.sql_server
terraform destroy -target=module.redhat_linux

# Keep only:
# - Linux Docker host
# - Windows 11 (optional)
```

---

## Real-World Cost Comparison

### Scenario 1: Pure Learning Environment

**Goal**: Learn DevOps, containers, microservices

| Component | Cost/month |
|-----------|------------|
| 1x Linux VM (D4s_v3, 12hr/day) | $35 |
| Storage | $15 |
| **Total** | **$50** |

**Containers included**:
- Samba AD DC
- SQL Server
- PostgreSQL
- MySQL
- MongoDB
- Redis
- Nginx
- Apache
- Node.js apps
- Python apps
- GitLab
- Jenkins
- Portainer

**Value**: $50 for entire DevOps lab

---

### Scenario 2: Windows + Linux Hybrid

**Goal**: Need Windows client for testing

| Component | Cost/month |
|-----------|------------|
| 1x Linux VM (D4s_v3, 12hr/day) | $35 |
| 1x Windows 11 (D2s_v3, 12hr/day) | $35 |
| Storage | $15 |
| **Total** | **$85** |

**Includes everything from Scenario 1 + Windows client**

---

### Scenario 3: Current Architecture

**Goal**: Full Windows Server lab

| Component | Cost/month |
|-----------|------------|
| 3x Windows Server | $105 |
| 1x Windows 11 | $35 |
| 1x SQL Server | $70 |
| 2x RHEL | $70 |
| Bastion | $0 (SSH) |
| Storage | $60 |
| **Total** | **$270** |

---

## Final Recommendation

### For Your Situation:

**Question**: What's your primary goal?

#### If **Learning Windows Server Administration**:
✅ **Keep current architecture** ($270/month)
- Or enable Dev/Test pricing ($161/month, 40% savings)

#### If **Learning Modern DevOps/Containers**:
✅ **Switch to Linux + Docker** ($50/month, 81% savings)
- Optionally keep Windows 11 ($85/month, 68% savings)

#### If **Both**:
✅ **Hybrid approach**:
- 1x Linux Docker host (most workloads)
- 1x Windows Server (AD DS only)
- 1x Windows 11 (client)
- **Total**: $105/month (61% savings)

---

## My Recommendation

**For maximum value**: **Linux + Docker + Windows 11**

**Architecture**:
```
$35/month: Linux VM with Docker (all server workloads)
$35/month: Windows 11 VM (client testing, domain join)
Total: $70/month (74% savings)
```

**Why**:
- ✅ Massive cost savings (74%)
- ✅ Learn modern container technology
- ✅ Still test Windows client scenarios
- ✅ Samba AD works for domain join
- ✅ SQL Server on Linux (same features)
- ✅ More relevant to current job market

**Ready to implement?** I can help you:
1. Create the Docker Compose configuration
2. Update Terraform to deploy Linux host
3. Migrate your existing setup
4. Set up Portainer for GUI management

Let me know! 🚀

