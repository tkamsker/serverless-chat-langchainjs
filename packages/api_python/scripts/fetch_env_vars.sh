#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Output file
ENV_FILE=".env"

echo -e "${BLUE}Fetching Azure environment variables...${NC}"

# Get Azure OpenAI details
echo -e "${YELLOW}Fetching Azure OpenAI resources...${NC}"
OPENAI_RESOURCES=$(az cognitiveservices account list --query "[?kind=='OpenAI']")

if [ -z "$OPENAI_RESOURCES" ]; then
    echo "No Azure OpenAI resources found. Please create one first."
    exit 1
fi

# Get the first OpenAI resource details
RESOURCE_NAME=$(echo $OPENAI_RESOURCES | jq -r '.[0].name')
RESOURCE_GROUP=$(echo $OPENAI_RESOURCES | jq -r '.[0].resourceGroup')

# Get endpoint and key
ENDPOINT=$(az cognitiveservices account show --name $RESOURCE_NAME --resource-group $RESOURCE_GROUP --query "properties.endpoint" -o tsv)
KEY=$(az cognitiveservices account keys list --name $RESOURCE_NAME --resource-group $RESOURCE_GROUP --query "key1" -o tsv)

# Get deployment names
DEPLOYMENTS=$(az cognitiveservices account deployment list --name $RESOURCE_NAME --resource-group $RESOURCE_GROUP -o json)
COMPLETION_DEPLOYMENT=$(echo $DEPLOYMENTS | jq -r '.[0].name')
EMBEDDING_DEPLOYMENT=$(echo $DEPLOYMENTS | jq -r '[.[] | select(.model.name | contains("embedding"))][0].name')

# Get Cosmos DB details
echo -e "${YELLOW}Fetching Cosmos DB details...${NC}"
COSMOS_ACCOUNT=$(az cosmosdb list --query "[0]")
COSMOS_ENDPOINT=$(echo $COSMOS_ACCOUNT | jq -r '.documentEndpoint')
COSMOS_KEY=$(az cosmosdb keys list --name $(echo $COSMOS_ACCOUNT | jq -r '.name') --resource-group $(echo $COSMOS_ACCOUNT | jq -r '.resourceGroup') --query "primaryMasterKey" -o tsv)

# Get Storage Account details
echo -e "${YELLOW}Fetching Storage Account details...${NC}"
STORAGE_ACCOUNT=$(az storage account list --query "[0]")
STORAGE_NAME=$(echo $STORAGE_ACCOUNT | jq -r '.name')
STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_NAME --query "[0].value" -o tsv)

# Create .env file
cat > $ENV_FILE << EOL
# Azure OpenAI Configuration
AZURE_OPENAI_API_KEY="${KEY}"
AZURE_OPENAI_API_ENDPOINT="${ENDPOINT}"
AZURE_OPENAI_API_VERSION="2023-05-15"
AZURE_OPENAI_API_DEPLOYMENT_NAME="${COMPLETION_DEPLOYMENT}"
AZURE_OPENAI_API_EMBEDDINGS_DEPLOYMENT_NAME="${EMBEDDING_DEPLOYMENT}"
AZURE_OPENAI_API_EMBEDDINGS_MODEL="text-embedding-ada-002"

# Azure Cosmos DB Configuration
AZURE_COSMOSDB_ENDPOINT="${COSMOS_ENDPOINT}"
AZURE_COSMOSDB_KEY="${COSMOS_KEY}"

# Azure Storage Configuration
AZURE_STORAGE_ACCOUNT="${STORAGE_NAME}"
AZURE_STORAGE_KEY="${STORAGE_KEY}"
AZURE_STORAGE_CONTAINER="documents"

# Function App Configuration
AzureWebJobsStorage="DefaultEndpointsProtocol=https;AccountName=${STORAGE_NAME};AccountKey=${STORAGE_KEY}"
FUNCTIONS_WORKER_RUNTIME="python"
EOL

echo -e "${GREEN}Environment variables have been written to ${ENV_FILE}${NC}"
echo -e "${YELLOW}Please verify the values in the .env file before using them.${NC}"

# Display instructions
echo -e "\n${BLUE}Next steps:${NC}"
echo "1. Copy .env file to your function app directory:"
echo "   cp .env packages/api_python/local.settings.json"
echo "2. Update Azure Function App settings:"
echo "   az functionapp config appsettings set --name <function-app-name> --resource-group <resource-group> --settings @local.settings.json" 