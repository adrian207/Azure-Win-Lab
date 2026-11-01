# Azure-Win-Lab

Terraform for a low-cost hybrid lab in Azure: one Ubuntu Docker host that runs the "server" side (a Samba Active Directory domain controller, SQL Server, PostgreSQL, MongoDB, Redis, GitLab, Jenkins and more as containers) and one Windows 11 workstation to join to the domain and test from. Nothing has a public IP; you reach both machines through Azure Bastion.

## What it builds

| Resource | Details |
|---|---|
| Network | One VNet with Bastion, servers, workstations, database and Linux subnets; NSGs allow RDP, SSH, SQL, web and AD ports only from inside the VNet |
| Azure Bastion | Standard SKU, the only public endpoint |
| **Docker host** | Ubuntu 22.04, `Standard_D4s_v3`, static IP `10.0.2.10`, data disk for container volumes, configured by cloud-init |
| **Windows 11 workstation** | Windows 11 Enterprise 23H2, `Standard_D2s_v3` |
| Auto-shutdown | Both VMs at 19:00 by default |

Containers on the Docker host (`modules/docker-host/scripts/docker-compose.yml`):

| Container | Image | Ports |
|---|---|---|
| Samba AD DC | `nowsci/samba-domain` | 53, 88, 135, 389, 445, 464, 636, 3268, 3269 |
| SQL Server 2022 | `mcr.microsoft.com/mssql/server:2022-latest` | 1433 |
| PostgreSQL 16 | `postgres:16-alpine` | 5432 |
| MongoDB 7 | `mongo:7` | 27017 |
| Redis 7 | `redis:7-alpine` | 6379 |
| NGINX | `nginx:alpine` | 80, 443 |
| Portainer | `portainer/portainer-ce` | 9000, 9443 |
| GitLab CE | `gitlab/gitlab-ce` | 8080, 8443, 2222 |
| Jenkins | `jenkins/jenkins:lts` | 8081, 50000 |
| Adminer | `adminer` | 8082 |

The Samba container provides the `lab.local` domain (change with `domain_name`), so the Windows 11 VM can be joined to a domain without running Windows Server.

## Requirements

- Terraform 1.0 or later and the Azure CLI, signed in (`az login`)
- An SSH public key for the Docker host (optional; without one it uses password sign-in)
- Quota for 6 vCPUs of the Dsv3 family in your region with the default sizes

## Quick start

```bash
git clone https://github.com/adrian207/Azure-Win-Lab.git
cd Azure-Win-Lab

cp terraform.tfvars.example terraform.tfvars
# Set admin_password (Windows and the AD domain), sql_admin_password, ssh_public_key,
# and optionally location, domain_name and VM sizes

./scripts/deploy.sh          # terraform init, plan, then apply after you confirm
terraform output connection_instructions
```

Then, in the Azure portal, open the Docker host or the Windows 11 VM and choose **Connect → Bastion**. From the Windows VM, Portainer is at `https://10.0.2.10:9443` and the other services at `10.0.2.10` on the ports above.

`./scripts/destroy.sh` removes everything. The `Makefile` wraps the same steps (`make plan`, `make apply`, `make destroy`, `make validate`, `make security`).

### Options

- **Remote state:** `bootstrap/` creates an Azure Storage account for Terraform state; copy `backend.tf.example` to `backend.tf` to use it. See [bootstrap/README.md](bootstrap/README.md).
- **Sizes:** `environments/demo`, `dev` and `standard` have example variable files. See [environments/README.md](environments/README.md).

## Repository layout

```
main.tf, variables.tf, outputs.tf    Root configuration: network, Bastion, Docker host, Windows 11
modules/
  networking/  bastion/  docker-host/  windows11-workstation/    Used by main.tf
  windows-server/  sql-server/  redhat-linux/  keyvault/  monitoring/
                                     From the earlier all-VM design; not used by main.tf
bootstrap/                           Remote state storage
environments/                        Example variable files
scripts/deploy.sh, destroy.sh
```

## Status and limitations

- This is a lab. The default database passwords for PostgreSQL and MongoDB are fixed in `modules/docker-host/scripts/cloud-init.yaml`; change them before using the lab for anything you care about.
- `enable_auto_shutdown` and `auto_shutdown_time` in `terraform.tfvars` apply to the Docker host; the Windows 11 VM always uses the module default (shutdown at 19:00).
- Samba provides AD authentication, DNS and Kerberos, not every Windows Server feature (no Group Policy management console on the server side, no AD CS).
- The `windows-server`, `sql-server`, `redhat-linux`, `keyvault` and `monitoring` modules validate but are not wired into `main.tf`. The cost documents compare that all-VM design with the Docker design used here. [BRANCH_GUIDE.md](BRANCH_GUIDE.md) describes the two as separate branches; the Docker design has since been merged into `master`.

## License

MIT. See [LICENSE](LICENSE).

## Author

Adrian Johnson · [github.com/adrian207](https://github.com/adrian207)
