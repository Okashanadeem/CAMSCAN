# CAMSCAN

An offline-first Flutter Android application for tracking student attendance using QR codes.

## Features

- **Offline-First:** All data is stored locally using SQLite. Syncing with the server is done manually or when internet is available.
- **Backend Included:** A Python FastAPI backend is now part of the project.
- **Course Management:** Fetch and cache courses from the backend API.
- **Session-Based Tracking:** Attendance is organized into sessions (one per course/event).
- **QR Scanning:** Real-time student ID capture with validation and duplicate prevention.
- **Admin Panel:** Administrative tools for syncing data and clearing local storage.
- **CI/CD:** Automated Android APK builds via GitHub Actions.

## Tech Stack

- **Mobile:** Flutter (Material 3), Riverpod, SQLite (sqflite)
- **Backend:** Python (FastAPI), SQLite, Uvicorn

## Project Structure

```text
/
├── backend/         # FastAPI Backend
│   ├── main.py      # Entry point
│   ├── database.py  # SQLite Logic
│   └── models.py    # Pydantic Models
├── lib/             # Flutter Mobile App
│   ├── db/          # SQLite Database Helper
│   ├── models/      # Data Models
│   ├── presentation/
│   │   ├── providers/ # Riverpod State
│   │   └── screens/   # UI Screens
│   └── services/    # API Services
└── pubspec.yaml     # Flutter Config
```

## Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the server:
   ```bash
   python main.py
   ```
The backend will be available at `http://localhost:8000`.

## Mobile App Setup

### API Configuration
The mobile app is configured to hit the backend at `http://10.0.2.2:8000` (Android Emulator alias for localhost).
To change this, edit `lib/services/api_service.dart`.

### How to generate the APK
Since this is a Flutter project, the platform-specific folders (like `android/`) are generated based on your local Flutter SDK environment. 

1. **Initialize Platform Folders:**
   ```bash
   flutter create .
   ```
2. **Build the APK:**
   ```bash
   flutter build apk --release
   ```

### GitHub Actions (Automated)
A workflow is set up in `.github/workflows/android.yml`. On push to `main`, it builds and uploads the APK as an artifact.
