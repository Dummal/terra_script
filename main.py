"""This module is the REST API server that serves the mediguru AI web application"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn

from src.pydantic_models.request import InferenceBody
from src.pydantic_models.response import Response
from src.routes.inference import generate_ai

from src.github_push import push_to_github

app = FastAPI()

origins = [
    "http://localhost",
    "http://localhost:8000",
    "http://localhost:4200"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/api/fastapi/generate", response_model=Response)
async def generate_terraform(body: InferenceBody):
    """This handler function calls the Terraform generation function and pushes to GitHub."""
    response = generate_ai(body)

    if response.status == "error":
        raise HTTPException(status_code=response.status_code, detail=response.data)

    # Push the generated file to GitHub
    try:
        push_to_github()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"GitHub push failed: {str(e)}")

    return JSONResponse(content=response.dict())

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=5008)