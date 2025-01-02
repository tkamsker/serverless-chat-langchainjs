import azure.functions as func
import json
from ...lib.langchain_utils import generate_response

def main(req: func.HttpRequest) -> func.HttpResponse:
    try:
        req_body = req.get_json()
        message = req_body.get('message')
        
        if not message:
            return func.HttpResponse(
                "Please pass a message in the request body",
                status_code=400
            )
        
        response = generate_response(message)
        
        return func.HttpResponse(
            json.dumps({"response": response}),
            mimetype="application/json",
            status_code=200
        )
    except Exception as e:
        return func.HttpResponse(
            f"An error occurred: {str(e)}",
            status_code=500
        ) 