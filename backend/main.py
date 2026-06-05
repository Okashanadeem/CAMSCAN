from fastapi import FastAPI, HTTPException, Security, Depends
from fastapi.security.api_key import APIKeyHeader
from typing import List
from models import Course, AttendanceSession
import database
import os

import os
import logging

# Configure Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("CAMSCAN")

app = FastAPI(title="CAMSCAN Backend")

@app.get("/")
def root():
    logger.info("Root endpoint accessed")
    return {"message": "CAMSCAN API is Running", "status": "healthy"}

@app.get("/api/health")
def health_check():
    return {"status": "ok", "database": "connected"}

@app.get("/api/admin/summary")
def get_summary(api_key: str = Depends(get_api_key)):
    try:
        total_sessions = database.db.sessions.count_documents({})
        total_courses = database.db.courses.count_documents({})
        
        # Simple aggregation for total students across all sessions
        pipeline = [
            {"$project": {"count": {"$size": "$students"}}},
            {"$group": {"_id": None, "total": {"$sum": "$count"}}}
        ]
        result = list(database.db.sessions.aggregate(pipeline))
        total_students = result[0]["total"] if result else 0
        
        return {
            "total_sessions": total_sessions,
            "total_courses": total_courses,
            "total_attendance_records": total_students
        }
    except Exception as e:
        logger.error(f"Summary error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

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

@app.post("/api/admin/clear-all")
def clear_all_data(api_key: str = Depends(get_api_key)):
    try:
        database.db.sessions.delete_many({})
        database.db.courses.delete_many({})
        return {"status": "success", "message": "All cloud data cleared successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", reload=True)
