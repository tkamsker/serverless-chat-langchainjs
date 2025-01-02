from langchain.llms import AzureOpenAI
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import Cosmos
from langchain.chains import RetrievalQA
from langchain.prompts import PromptTemplate
import os
from dotenv import load_dotenv

load_dotenv()

# Initialize Azure OpenAI
llm = AzureOpenAI(
    deployment_name=os.getenv("AZURE_OPENAI_API_DEPLOYMENT_NAME"),
    model_name="gpt-4",
    temperature=0,
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
    api_version=os.getenv("AZURE_OPENAI_API_VERSION"),
    api_base=os.getenv("AZURE_OPENAI_API_ENDPOINT")
)

# Initialize embeddings
embeddings = OpenAIEmbeddings(
    deployment=os.getenv("AZURE_OPENAI_API_EMBEDDINGS_DEPLOYMENT_NAME"),
    model=os.getenv("AZURE_OPENAI_API_EMBEDDINGS_MODEL"),
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
    api_base=os.getenv("AZURE_OPENAI_API_ENDPOINT"),
    api_version=os.getenv("AZURE_OPENAI_API_VERSION"),
    chunk_size=1
)

# Initialize Cosmos DB vector store
vectorstore = Cosmos(
    collection_name="vectorstore",
    connection_string=os.getenv("AZURE_COSMOSDB_NOSQL_ENDPOINT"),
    embedding_function=embeddings
)

# Create custom prompt template
prompt_template = """Use the following pieces of context to answer the question at the end. 
If you don't know the answer, just say that you don't know, don't try to make up an answer.

{context}

Question: {question}
Answer:"""

PROMPT = PromptTemplate(
    template=prompt_template, input_variables=["context", "question"]
)

# Initialize QA chain
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vectorstore.as_retriever(search_kwargs={"k": 3}),
    chain_type_kwargs={"prompt": PROMPT}
)

def generate_response(query: str) -> str:
    try:
        response = qa_chain.run(query)
        return response
    except Exception as e:
        print(f"Error generating response: {str(e)}")
        return "I apologize, but I encountered an error processing your request." 