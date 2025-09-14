# Azure Integration for HolmesGPT

This guide covers the Azure toolsets now available in your HolmesGPT installation.

## ✅ Azure Toolsets Enabled

Your HolmesGPT now includes these Azure capabilities:

### 1. AKS Core (`aks/core`)
- **Status**: ✅ Enabled and Working
- **Capabilities**:
  - Manage Azure Kubernetes Service clusters
  - Query cluster information
  - Monitor cluster health
  - Access cluster resources

### 2. AKS Node Health (`aks/node-health`)
- **Status**: ✅ Enabled and Working  
- **Capabilities**:
  - Monitor AKS node health status
  - Check node resource utilization
  - Identify unhealthy nodes
  - Node troubleshooting

### 3. Azure SQL Database (`azure/sql`)
- **Status**: ❌ Needs Configuration
- **Capabilities** (when configured):
  - Monitor SQL database performance
  - Query database health metrics
  - Troubleshoot database issues
  - Check database connections

## 🚀 Usage Examples

### AKS Queries
```bash
# List AKS clusters
holmes ask "show me my AKS clusters"

# Check cluster health
holmes ask "what is the health status of my AKS clusters?"

# Node information
holmes ask "show me information about my AKS nodes"

# Node health monitoring
holmes ask "are there any unhealthy nodes in my AKS cluster?"

# Resource utilization
holmes ask "which AKS nodes are using the most resources?"

# Combined with Docker
holmes ask "what containers are running on my AKS nodes?"
```

### General Azure Queries
```bash
# Azure resource overview
holmes ask "show me my Azure resources"

# Subscription information
holmes ask "what Azure subscription am I using?"

# Resource groups
holmes ask "list my Azure resource groups"
```

## 🔧 Azure SQL Database Setup

To enable Azure SQL Database monitoring:

1. **Run the setup script**:
   ```bash
   ./setup-azure-sql.sh
   ```

2. **Manual configuration** (alternative):
   ```bash
   # List your SQL servers
   az sql server list --output table
   
   # Configure in HolmesGPT
   # Edit ~/.holmes/config.yaml and add your server details
   ```

## 🔑 Authentication

Your Azure authentication is already configured:
- ✅ Azure CLI is installed (`/usr/bin/az`)
- ✅ Logged into Azure account (`nasa.28apr@gmail.com`)
- ✅ Active subscription: "Microsoft Azure Sponsorship 2"
- ✅ Subscription ID: `bf0120dd-8803-4424-9568-033e34846e96`

## 📊 Current Toolset Status

| Toolset | Status | Description |
|---------|---------|-------------|
| `docker/core` | ✅ Working | Docker container management |
| `kubernetes/core` | ✅ Working | Kubernetes cluster management |
| `aks/core` | ✅ Working | Azure Kubernetes Service |
| `aks/node-health` | ✅ Working | AKS node health monitoring |
| `azure/sql` | ❌ Needs Config | Azure SQL Database monitoring |
| `aws/security` | ✅ Working | AWS security toolset |
| `aws/rds` | ✅ Working | AWS RDS monitoring |

## 🧪 Testing Your Azure Integration

Test the Azure functionality with these commands:

```bash
# Basic Azure connectivity
holmes ask "what Azure subscription am I using?"

# AKS specific
holmes ask "do I have any AKS clusters?"

# Combined Azure + Docker + Kubernetes
holmes ask "show me the relationship between my Docker containers, Kubernetes pods, and Azure resources"
```

## 🔄 Refreshing Toolsets

If you make configuration changes, refresh the toolsets:

```bash
holmes toolset refresh
```

## 📝 Configuration Files

Your Azure configuration is stored in:
- **Main config**: `~/.holmes/config.yaml`
- **Environment vars**: `~/.holmes/.env`
- **Toolset status**: `~/.holmes/toolsets_status.json`

## 🆘 Troubleshooting

### Azure SQL Database Issues
If Azure SQL toolset shows as failed:
1. Run `./setup-azure-sql.sh` to configure
2. Ensure you have SQL servers in your subscription
3. Check that your account has permissions to access SQL resources

### AKS Issues
If AKS toolsets fail:
1. Verify you have AKS clusters: `az aks list`
2. Check permissions: `az aks get-credentials --resource-group <rg> --name <cluster>`

### General Azure Issues
1. Check authentication: `az account show`
2. Verify subscription: `az account list`
3. Re-login if needed: `az login`

## 🎯 Next Steps

1. **Set up API key** (if not already done):
   ```bash
   ./quick-setup.sh openai your-api-key
   ```

2. **Test Azure integration**:
   ```bash
   holmes ask "show me my Azure resources and their health status"
   ```

3. **Configure Azure SQL** (optional):
   ```bash
   ./setup-azure-sql.sh
   ```

4. **Explore combined capabilities**:
   ```bash
   holmes ask "analyze my entire infrastructure: Docker, Kubernetes, Azure, and AWS"
   ```

Your HolmesGPT now has comprehensive Azure support alongside Docker and Kubernetes capabilities!
