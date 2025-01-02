from typing import List, Dict
from .langchain_utils import vectorstore

async def get_documents() -> List[Dict]:
    try:
        # Get all documents from the vector store
        documents = await vectorstore.get_all_documents()
        
        # Group by document_id and create summary
        doc_map = {}
        for doc in documents:
            doc_id = doc.metadata.get("document_id")
            if doc_id not in doc_map:
                doc_map[doc_id] = {
                    "id": doc_id,
                    "title": doc.metadata.get("title", "Untitled"),
                    "chunks": 1
                }
            else:
                doc_map[doc_id]["chunks"] += 1

        return list(doc_map.values())
    except Exception as e:
        print(f"Error retrieving documents: {str(e)}")
        return [] 