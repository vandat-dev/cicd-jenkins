from fastapi import FastAPI
import uvicorn
import os
from dotenv import load_dotenv

# Load biến môi trường từ file .env
load_dotenv()

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Hello Jenkins"}

def main():
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8000"))

    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=True
    )

if __name__ == "__main__":
    main()
