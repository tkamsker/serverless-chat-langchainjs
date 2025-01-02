#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Environment name
ENV_NAME="azure-functions-env"

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
        exit 1
    fi
}

# Function to check if conda is available
check_conda() {
    if ! command -v conda &> /dev/null; then
        echo -e "${RED}Error: conda is not installed or not in PATH${NC}"
        exit 1
    fi
}

# Function to setup conda environment
setup_conda_env() {
    echo -e "${BLUE}Setting up conda environment...${NC}"
    
    # Check if environment exists
    if conda env list | grep -q "^${ENV_NAME}"; then
        echo -e "${BLUE}Conda environment ${ENV_NAME} exists, activating...${NC}"
        eval "$(conda shell.bash hook)"
        conda activate ${ENV_NAME}
    else
        echo -e "${BLUE}Creating new conda environment ${ENV_NAME}...${NC}"
        conda create -n ${ENV_NAME} python=3.9 -y
        eval "$(conda shell.bash hook)"
        conda activate ${ENV_NAME}
        
        # Install dependencies
        echo -e "${BLUE}Installing dependencies...${NC}"
        pip install -r requirements.txt
    fi
    print_status $? "Conda environment setup"
}

# Check if local.settings.json exists
check_settings() {
    echo -e "${BLUE}Checking configuration...${NC}"
    if [ ! -f "local.settings.json" ]; then
        echo -e "${RED}Error: local.settings.json not found${NC}"
        exit 1
    fi
    print_status $? "Configuration check"
}

# Main testing function
run_tests() {
    echo -e "${BLUE}Starting Azure Functions...${NC}"
    func start &
    FUNC_PID=$!

    # Wait for Functions to start
    echo -e "${BLUE}Waiting for Functions to initialize...${NC}"
    sleep 10

    # Test chat endpoint
    echo -e "${BLUE}Testing chat endpoint...${NC}"
    CHAT_RESPONSE=$(curl -s -X POST http://localhost:7071/api/chat-post \
        -H "Content-Type: application/json" \
        -d '{"message":"What are the terms of service?"}')
    print_status $? "Chat endpoint test"
    echo "Response: $CHAT_RESPONSE"

    # Test document upload
    echo -e "${BLUE}Testing document upload...${NC}"
    if [ ! -f "../data/sample.pdf" ]; then
        echo -e "${RED}Error: sample.pdf not found in data directory${NC}"
        kill $FUNC_PID
        exit 1
    fi
    
    UPLOAD_RESPONSE=$(curl -s -X POST http://localhost:7071/api/documents-post \
        -F "file=@../data/sample.pdf")
    print_status $? "Document upload test"
    echo "Response: $UPLOAD_RESPONSE"

    # Test document retrieval
    echo -e "${BLUE}Testing document retrieval...${NC}"
    GET_RESPONSE=$(curl -s -X GET http://localhost:7071/api/documents-get)
    print_status $? "Document retrieval test"
    echo "Response: $GET_RESPONSE"

    # Kill Azure Functions process
    echo -e "${BLUE}Stopping Azure Functions...${NC}"
    kill $FUNC_PID
    print_status $? "Azure Functions stopped"
}

# Cleanup function
cleanup() {
    # Kill any remaining func processes
    pkill -f "func start"
    
    # Deactivate conda environment
    conda deactivate
}

# Main execution
main() {
    echo -e "${BLUE}Starting local testing...${NC}"
    
    # Setup trap for cleanup on script exit
    trap cleanup EXIT
    
    # Run all checks and tests
    check_conda
    setup_conda_env
    check_settings
    run_tests
    
    echo -e "${GREEN}All tests completed successfully!${NC}"
}

# Run main function
main 