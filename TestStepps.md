
## Test Steps

1. Start Azure Storage Emulator (if using local storage)
2. Start the Function App locally
3. Test each endpoint:
   - Chat endpoint
   - Document upload
   - Document retrieval

## Expected Results

1. Chat Endpoint:
   - Status: 200
   - Response: JSON with AI-generated answer

2. Document Upload:
   - Status: 200
   - Response: JSON with document processing details

3. Document Retrieval:
   - Status: 200
   - Response: JSON list of processed documents


   ----------------------------

   # refactor conda

   # Create new conda environment
conda create -n azure-functions-env python=3.9

# Activate environment
conda activate azure-functions-env

# Install dependencies
pip install -r requirements.txt 
   

func start --verbose

127.0.0.1:59891 

# Test chat endpoint
curl -X POST http://localhost:59891/api/chat-post \
  -H "Content-Type: application/json" \
  -d '{"message":"test question"}'

# frontend 
 npm i 
npm install lit @microsoft/fast-foundation
npm install -D typescript vite @types/node


##########################
# infrastructure  -> serverless-chat-langchainpython
##########################
azd env set AZURE_LOCATION westeurope

# Clean up existing resources
azd down --purge

# Redeploy with debug logging
azd up --debug


azd env list
