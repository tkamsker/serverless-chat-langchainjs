#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Get timestamp for log file
TIMESTAMP=$(date +%Y%m%d%H%M)
LOG_FILE="local_${TIMESTAMP}.log"

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
        exit 1
    fi
}

# Function to check environment
check_environment() {
    # Check if func command exists
    if ! command -v func &> /dev/null; then
        echo -e "${RED}Error: Azure Functions Core Tools not found${NC}"
        echo "Please install Azure Functions Core Tools:"
        echo "npm install -g azure-functions-core-tools@4"
        exit 1
    fi

    # Check if conda exists
    if ! command -v conda &> /dev/null; then
        echo -e "${RED}Error: conda is not installed or not in PATH${NC}"
        exit 1
    fi
}

# Main execution
main() {
    echo -e "${BLUE}Starting local Function App...${NC}"
    
    # Store original directory
    ORIGINAL_DIR=$(pwd)
    
    # Navigate to api_python directory
    echo -e "${BLUE}Navigating to packages/api_python...${NC}"
    cd packages/api_python || {
        echo -e "${RED}Error: Could not navigate to packages/api_python${NC}"
        exit 1
    }
    print_status $? "Changed directory to packages/api_python"

    # Check if .env exists
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}Warning: .env file not found${NC}"
        echo -e "${BLUE}Attempting to create .env from fetch_env_vars.sh...${NC}"
        
        if [ -f "./scripts/fetch_env_vars.sh" ]; then
            bash ./scripts/fetch_env_vars.sh
            print_status $? "Created .env file"
        else
            echo -e "${RED}Error: fetch_env_vars.sh not found${NC}"
            cd "$ORIGINAL_DIR"
            exit 1
        fi
    fi

    # Activate conda environment
    echo -e "${BLUE}Activating conda environment...${NC}"
    eval "$(conda shell.bash hook)"
    if conda activate azure-functions-env; then
        print_status $? "Activated conda environment azure-functions-env"
    else
        echo -e "${YELLOW}Creating new conda environment...${NC}"
        conda create -n azure-functions-env python=3.9 -y
        conda activate azure-functions-env
        pip install -r requirements.txt
        print_status $? "Created and activated new conda environment"
    fi

    # Start Function App with logging
    echo -e "${BLUE}Starting Function App with verbose logging...${NC}"
    echo -e "${BLUE}Log file: ${LOG_FILE}${NC}"
    
    # Start func with both console output and logging
    func start --verbose 2>&1 | tee "$LOG_FILE"
}

# Setup error handling
set -e
trap 'echo -e "${RED}An error occurred. Exiting...${NC}"; cd "$ORIGINAL_DIR"' ERR

# Check environment before starting
check_environment

# Run main function
main

# Return to original directory if script is interrupted
trap 'cd "$ORIGINAL_DIR"' EXIT 