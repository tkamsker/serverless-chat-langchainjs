from langchain.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from .langchain_utils import vectorstore
import tempfile
import os
from typing import List, Dict
import hashlib

def process_document(file_content: bytes) -> Dict:
    try:
        # Create temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as temp_file:
            temp_file.write(file_content)
            temp_file_path = temp_file.name

        # Load and process document
        loader = PyPDFLoader(temp_file_path)
        documents = loader.load()

        # Split text into chunks
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=1000,
            chunk_overlap=200,
            length_function=len
        )
        splits = text_splitter.split_documents(documents)

        # Generate document ID
        doc_id = hashlib.md5(file_content).hexdigest()

        # Add metadata to chunks
        for split in splits:
            split.metadata["document_id"] = doc_id

        # Add to vector store
        vectorstore.add_documents(splits)

        # Cleanup
        os.unlink(temp_file_path)

        return {
            "status": "success",
            "document_id": doc_id,
            "chunks_processed": len(splits)
        }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e)
        } 