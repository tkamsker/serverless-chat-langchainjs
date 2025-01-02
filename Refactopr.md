I'll help you create instructions for rewriting the backend in Python while maintaining the same functionality. Let's break this down systematically.
Python Backend Migration Instructions
1. Project Structure Update
Create a new Python backend structure while keeping the existing frontend:

packages/
├── api_python/              # New Python backend
│   ├── src/
│   │   ├── functions/      # Azure Functions
│   │   └── lib/           # Shared utilities
│   ├── requirements.txt
│   └── host.json
└── webapp/                 # Existing frontend (unchanged)

2. Dependencies Setup
Create requirements.txt:
azure-functions
langchain
azure-identity
azure-storage-blob
python-dotenv
pypdf
azure-cosmos

3. Core Functions Implementation
Chat Function
The chat function implementation should mirror the existing TypeScript functionality:

LangChain Integration
The key part is setting up LangChain with Azure OpenAI and Cosmos DB:

4. Azure Configuration Update
Update azure.yaml to point to the Python backend:

**5. Migration Steps**
1. Keep Frontend Unchanged
Reference the existing frontend structure:

2. Update GitHub Actions
Add Python-specific steps:

**6. Testing Instructions**
1. Local Testing:

# Navigate to Python API directory
cd packages/api_python

# Install dependencies
pip install -r requirements.txt

# Start Functions locally
func start

2. Verify API endpoints:

# Test chat endpoint
curl -X POST http://localhost:7071/api/chat-post \
  -H "Content-Type: application/json" \
  -d '{"message":"test question"}'

**7. Deployment Process**
The deployment process remains the same:
azd auth login
azd up

--------------------------------

Key Considerations
1. Environment Variables: Ensure all required environment variables are properly set in your local.settings.json and Azure Function App settings.

2. API Compatibility: The Python backend must maintain the same API contract as the TypeScript version. Reference the existing API structure:

3.Error Handling: Implement consistent error handling across all endpoints to maintain compatibility with the frontend.

4.Testing: Verify that all existing functionality works with the new Python backend, especially the RAG implementation and document processing.

This migration maintains the same functionality while leveraging Python's strong AI/ML ecosystem and LangChain's Python implementation.