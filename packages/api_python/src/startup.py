import azure.functions as func
from .lib.langchain_utils import initialize_langchain
from .lib.storage_utils import StorageManager

storage_manager = StorageManager()

def initialize():
    try:
        initialize_langchain()
        print("LangChain services initialized successfully")
    except Exception as e:
        print(f"Error initializing services: {str(e)}") 