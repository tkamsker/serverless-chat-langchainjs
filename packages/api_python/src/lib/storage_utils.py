from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential
import os
from typing import Optional

class StorageManager:
    def __init__(self):
        self.account_url = f"https://{os.getenv('AZURE_STORAGE_ACCOUNT')}.blob.core.windows.net"
        self.container_name = os.getenv('AZURE_STORAGE_CONTAINER')
        self.credential = DefaultAzureCredential()
        self.blob_service_client = BlobServiceClient(
            account_url=self.account_url,
            credential=self.credential
        )
        
    async def upload_blob(self, file_content: bytes, filename: str) -> Optional[str]:
        try:
            container_client = self.blob_service_client.get_container_client(self.container_name)
            blob_client = container_client.get_blob_client(filename)
            await blob_client.upload_blob(file_content, overwrite=True)
            return blob_client.url
        except Exception as e:
            print(f"Error uploading blob: {str(e)}")
            return None

    async def get_blob_list(self):
        try:
            container_client = self.blob_service_client.get_container_client(self.container_name)
            return [blob.name for blob in container_client.list_blobs()]
        except Exception as e:
            print(f"Error listing blobs: {str(e)}")
            return [] 