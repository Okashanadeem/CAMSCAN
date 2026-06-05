from fastapi import FastAPI, HTTPException, Security, Depends
from fastapi.security.api_key import APIKeyHeader
from typing import List
from models import Course, AttendanceSession
import database
import os

app = FastAPI(title="CAMSCAN Backend")

API_KEY = os.getenv("API_KEY", "CAMSCAN_v1_Secret_Key_2026")
API_KEY_NAME = "X-API-KEY"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=False)

async def get_api_key(header_key: str = Security(api_key_header)):
    if header_key == API_KEY:
        return header_key
    raise HTTPException(status_code=403, detail="Could not validate credentials")

@app.on_event("startup")
def startup_event():
    database.init_db()

@app.get("/api/courses", response_model=List[Course])
def read_courses(api_key: str = Depends(get_api_key)):
    return database.get_courses()

@app.post("/api/sessions/bulk-upload")
def upload_sessions(sessions: List[AttendanceSession], api_key: str = Depends(get_api_key)):
    try:
        for session in sessions:
            database.save_session(session)
        return {"status": "success", "message": f"Uploaded {len(sessions)} sessions"}
    except Exception as e:
        print(f"Error uploading sessions: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", reload=True)
