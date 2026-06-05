from pymongo import MongoClient
import os
from dotenv import load_dotenv

load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI")
DB_NAME = os.getenv("DB_NAME", "camscan")

client = MongoClient(MONGODB_URI)
db = client[DB_NAME]

def init_db():
    # MongoDB doesn't need explicit table creation, 
    # but we can seed courses if the collection is empty
    if db.courses.count_documents({}) == 0:
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

def get_courses():
    courses = list(db.courses.find({}, {"_id": 0}))
    return courses

def save_session(session_data):
    # Convert Pydantic model to dict for MongoDB
    session_dict = session_data.dict()
    
    # We use update_one with upsert=True for sessions to handle duplicates
    db.sessions.update_one(
        {"session_id": session_dict["session_id"]},
        {"$set": session_dict},
        upsert=True
    )
    
    # Attendance is usually part of the session object in this payload
    # but we could also store it in a separate collection if needed.
    # For now, keeping it inside the session document as per the payload structure.
