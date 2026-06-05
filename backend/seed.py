import os
from pymongo import MongoClient
from dotenv import load_dotenv

load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI")
DB_NAME = os.getenv("DB_NAME", "camscan")

def seed_database():
    if not MONGODB_URI:
        print("Error: MONGODB_URI not found in .env file")
        return

    print(f"Connecting to MongoDB Atlas...")
    client = MongoClient(MONGODB_URI)
    db = client[DB_NAME]

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

    print(f"Seeding {len(courses)} courses into '{DB_NAME}.courses' collection...")
    
    # Use upsert logic to avoid duplicates if run multiple times
    for course in courses:
        db.courses.update_one(
            {"id": course["id"]},
            {"$set": course},
            upsert=True
        )

    print("✅ Seeding completed successfully!")
    client.close()

if __name__ == "__main__":
    seed_database()
