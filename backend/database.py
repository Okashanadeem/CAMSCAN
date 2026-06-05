import os
from pymongo import MongoClient
from dotenv import load_dotenv

load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI")
DB_NAME = os.getenv("DB_NAME", "camscan")

# Initialize client as None for lazy loading
_client = None

def get_db():
    global _client
    if _client is None:
        # Explicitly add TLS and Timeout parameters for Serverless stability
        _client = MongoClient(
            MONGODB_URI,
            tls=True,
            serverSelectionTimeoutMS=5000,
            connectTimeoutMS=10000
        )
    return _client[DB_NAME]

def init_db():
    db = get_db()
    try:
        if db.courses.count_documents({}, maxTimeMS=2000) == 0:
            courses = [
                {"id": "BSE-101", "name": "Object Oriented Programming"},
                {"id": "BSE-102", "name": "Digital Logic Design"},
                {"id": "BSE-201", "name": "Data Structures & Algorithms"},
                {"id": "BSE-301", "name": "Computer Networks"},
                {"id": "BSE-401", "name": "Artificial Intelligence"},
                {"id": "BSE-402", "name": "Software Engineering"},
                {"id": "HUM-101", "name": "English Composition"},
                {"id": "MTH-101", "name": "Calculus & Analytical Geometry"},
            ]
            db.courses.insert_many(courses)
    except Exception as e:
        print(f"Database init warning: {e}")

def get_courses():
    db = get_db()
    return list(db.courses.find({}, {"_id": 0}))

def save_session(session_data):
    db = get_db()
    session_dict = session_data.dict()
    db.sessions.update_one(
        {"session_id": session_dict["session_id"]},
        {"$set": session_dict},
        upsert=True
    )
