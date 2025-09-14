#!/bin/bash

# Azure SQL Database Setup for HolmesGPT
# This script helps configure Azure SQL Database monitoring

echo "🔧 Azure SQL Database Setup for HolmesGPT"
echo "========================================="

# Check if user is logged into Azure CLI
if ! az account show > /dev/null 2>&1; then
    echo "❌ Not logged into Azure CLI. Please run: az login"
    exit 1
fi

echo "✅ Azure CLI is authenticated"

# List available subscriptions
echo "📋 Available Azure subscriptions:"
az account list --query "[].{Name:name, SubscriptionId:id, State:state}" --output table

echo ""
read -p "Enter the subscription ID to use (or press Enter for current): " SUBSCRIPTION_ID

if [ -n "$SUBSCRIPTION_ID" ]; then
    az account set --subscription "$SUBSCRIPTION_ID"
    echo "✅ Set subscription to: $SUBSCRIPTION_ID"
fi

# List SQL servers
echo ""
echo "🗄️ Looking for Azure SQL servers..."
SQL_SERVERS=$(az sql server list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location}" --output table)

if [ -z "$SQL_SERVERS" ]; then
    echo "⚠️ No Azure SQL servers found in current subscription."
    echo ""
    echo "To create an Azure SQL server, you can:"
    echo "1. Use Azure Portal: https://portal.azure.com"
    echo "2. Use Azure CLI:"
    echo "   az group create --name myResourceGroup --location eastus"
    echo "   az sql server create --name myserver --resource-group myResourceGroup --location eastus --admin-user myadmin --admin-password MyPassword123!"
    echo ""
    read -p "Do you want to continue with configuration anyway? (y/N): " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        exit 0
    fi
else
    echo "$SQL_SERVERS"
    echo ""
    read -p "Enter the SQL server name to monitor: " SQL_SERVER_NAME
    read -p "Enter the resource group name: " RESOURCE_GROUP
fi

# Create Azure SQL configuration
echo ""
echo "📝 Creating Azure SQL configuration..."

# Update HolmesGPT config with Azure SQL settings
cat >> ~/.holmes/config.yaml << EOF

# Azure SQL Database configuration
azure/sql:
  enabled: true
EOF

if [ -n "$SQL_SERVER_NAME" ] && [ -n "$RESOURCE_GROUP" ]; then
    cat >> ~/.holmes/config.yaml << EOF
  server_name: "$SQL_SERVER_NAME"
  resource_group: "$RESOURCE_GROUP"
EOF
fi

echo "✅ Updated HolmesGPT configuration"

# Create environment variables for Azure SQL
cat >> ~/.holmes/.env << EOF

# Azure SQL Database Configuration
AZURE_SQL_SERVER_NAME=${SQL_SERVER_NAME:-your-sql-server-name}
AZURE_SQL_RESOURCE_GROUP=${RESOURCE_GROUP:-your-resource-group}
EOF

echo "✅ Added Azure SQL environment variables"

# Refresh toolsets
echo ""
echo "🔄 Refreshing HolmesGPT toolsets..."
holmes toolset refresh

echo ""
echo "🎉 Azure SQL Database setup complete!"
echo ""
echo "📊 Available Azure capabilities:"
echo "  • AKS Core - Azure Kubernetes Service management"
echo "  • AKS Node Health - Monitor AKS node health"
echo "  • Azure SQL Database - Database monitoring and management"
echo ""
echo "🧪 Test your Azure integration:"
echo "  holmes ask 'show me my AKS clusters'"
echo "  holmes ask 'what is the health of my AKS nodes?'"
echo "  holmes ask 'show me Azure SQL database status'"
