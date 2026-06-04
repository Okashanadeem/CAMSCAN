# MASTER BUILD PROMPT (Use this for code generation)

Build a full-stack **Offline-First Attendance Management System (Flutter Android App)** with course/session-based attendance tracking, local persistence, and server sync.

---

# 1. CORE SYSTEM OVERVIEW

The app has 3 main layers:

### 1. Course Layer (Fetched from AI/API once)

* On first launch OR admin trigger:

  * Pull list of courses from backend/API/AI endpoint.
* Store locally (cached).
* Courses are reused offline.

---

### 2. Session Layer (Attendance Container)

Each course contains multiple sessions.

A session represents one attendance event.

Each session contains:

* Course Name
* Course ID
* Session ID (auto-generated UUID)
* Date & Time
* List of scanned students
* Status: draft / saved / synced

---

### 3. Scan Layer (QR Attendance Input)

QR contains:

```text id="8r8v0f"
BSE-25F-086
```

Flow:

* Scan QR
* Validate format
* Add student to active session attendance list
* Prevent duplicates

---

# 2. APP FLOW

## A. Home Screen

Shows:

* List of Courses (pulled once and cached)
* Button: “Scan Attendance”
* Button: “Previous Sessions”
* Button: “Admin Panel”

---

## B. Course Selection → Session

When user taps a course:

### Session Screen opens:

Shows:

* Course name
* Course ID
* Button: “Start New Session”
* List of active/pending sessions

---

### Inside Session Screen:

Shows:

* Live scanned students list
* Student ID
* Timestamp
* Remove student option
* Save Session button

---

### Save Session:

When clicked:

```json id="7q6h3n"
{
  "session_id": "uuid",
  "course_id": "CS-101",
  "course_name": "Data Structures",
  "students": [
    {
      "student_id": "BSE-25F-086",
      "time": "2026-06-04T10:30:00"
    }
  ],
  "status": "saved"
}
```

Stored locally.

---

## C. Scan Screen

* Camera-based QR scanner
* Real-time detection
* Shows:

  * Last scanned ID
  * Success animation
* Auto-add to current session

Rules:

* No duplicates in same session
* Ignore scan if already added

---

## D. Previous Sessions

Show:

* List of all saved sessions
* Filter by course
* Open session details
* View student list
* Sync status (pending/synced)

---

## E. Admin Panel

Admin functions:

### 1. Pull Latest Courses

* Fetch from API/AI endpoint
* Replace local cache

### 2. Push Sessions to Server

* Upload all unsynced sessions

Endpoint:

```http id="1h2k9p"
POST /api/sessions/bulk-upload
```

Payload:

```json id="2k3m1x"
[
  {
    "session_id": "uuid",
    "course_id": "CS-101",
    "students": [...]
  }
]
```

After success:

* Mark session as synced

---

### 3. Clear Data Options

Two options:

* Clear sessions only
* Clear everything (sessions + cache)

Must show confirmation dialog.

---

# 3. LOCAL DATABASE DESIGN (SQLite)

### Table: courses

```sql id="c1"
id TEXT PRIMARY KEY,
name TEXT
```

---

### Table: sessions

```sql id="c2"
session_id TEXT PRIMARY KEY,
course_id TEXT,
course_name TEXT,
created_at TEXT,
status TEXT,
synced INTEGER DEFAULT 0
```

---

### Table: attendance

```sql id="c3"
id INTEGER PRIMARY KEY AUTOINCREMENT,
session_id TEXT,
student_id TEXT,
scanned_at TEXT
```

---

# 4. QR VALIDATION RULE

```regex id="r1"
^[A-Z]{2,5}-[0-9]{2}[A-Z]-[0-9]{3}$
```

Invalid scans must:

* Show error toast
* Not be stored

---

# 5. STATE MANAGEMENT

Use:

* Riverpod (preferred) OR Provider

Structure:

```text id="st1"
presentation/
data/
domain/
services/
db/
models/
```

---

# 6. OFFLINE-FIRST RULE

Everything must work without internet:

* Courses cached locally
* Sessions stored locally
* Scans stored instantly
* Sync happens later manually

---

# 7. SYNC SYSTEM

### Sync sessions button:

* Upload all `synced = 0` sessions
* Retry failed uploads
* Update status on success

---

# 8. UI REQUIREMENTS

Design style:

* Clean Material 3
* Minimal UI
* Large buttons for scanning
* Card-based layout

---

# 9. GITHUB ACTIONS (CI/CD)

Create workflow:

* Build Flutter release APK
* Run on push to main
* Upload artifact

Path:

```text id="gh1"
.github/workflows/android.yml
```

---

# 10. IMPORTANT LOGIC RULES

### Duplicate Prevention:

* No duplicate student in same session
* Time-based ignore window (30 sec optional)

### Session Integrity:

* Once saved → session becomes read-only

### Data Safety:

* Never delete synced sessions unless admin clears

---

# 11. FINAL OUTPUT REQUIREMENTS

The AI must generate:

* Full Flutter project
* Working QR scanner
* SQLite database
* Session system
* Course system
* Admin panel
* Sync system
* GitHub Actions build pipeline
* Clean folder architecture
* README with setup + API config
* Fully buildable APK from GitHub Actions artifacts

---

# CRITICAL PRODUCT NOTE (MENTOR FEEDBACK)

Your system is now essentially:

> A **modular offline-first attendance OS**

### Strong points:

* Scalable (courses → sessions → attendance)
* Offline-first (good for real classrooms)
* Clean separation of concerns

### Risk areas (important):

1. **AI course pulling dependency**

   * If AI endpoint fails → no course access
   * Fix: fallback static cache

2. **Session explosion problem**

   * Many sessions = large SQLite growth
   * Fix: archiving old sessions

3. **Sync conflicts**

   * Multiple devices scanning same student
   * Fix: server-side deduplication required

