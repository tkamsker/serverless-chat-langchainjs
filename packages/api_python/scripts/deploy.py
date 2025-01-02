import os
import subprocess
import sys

def run_deployment():
    try:
        # Install dependencies
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        
        # Run Azure Functions deployment
        subprocess.check_call(["func", "azure", "functionapp", "publish", 
                             os.getenv("AZURE_FUNCTION_APP_NAME")])
        
        print("Deployment completed successfully")
    except Exception as e:
        print(f"Deployment failed: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    run_deployment() 