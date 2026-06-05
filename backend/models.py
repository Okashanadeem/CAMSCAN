from pydantic import BaseModel
from typing import List, Optional

class Course(BaseModel):
    id: str
    name: str

class AttendanceRecord(BaseModel):
    student_id: str
    scanned_at: str

class AttendanceSession(BaseModel):
    session_id: str
    course_id: str
    course_name: str
    created_at: str
    students: List[AttendanceRecord]
