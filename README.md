# LocalScan Attendance Management System

An offline-first Flutter Android application for tracking student attendance using QR codes.

## Features

- **Offline-First:** All data is stored locally using SQLite. Syncing with the server is done manually or when internet is available.
- **Course Management:** Fetch and cache courses from a remote API.
- **Session-Based Tracking:** Attendance is organized into sessions (one per course/event).
- **QR Scanning:** Real-time student ID capture with validation and duplicate prevention.
- **Admin Panel:** Administrative tools for syncing data and clearing local storage.
- **CI/CD:** Automated Android APK builds via GitHub Actions.

## Tech Stack

- **Framework:** Flutter (Material 3)
- **State Management:** Riverpod
- **Local Database:** SQLite (sqflite)
- **Scanner:** mobile_scanner
- **HTTP Client:** http
- **ID Generation:** Uuid

## Where are the APIs?

The API integration is split into two parts for better maintainability:

1.  **Network Logic (`lib/services/api_service.dart`):**
    - This is where the actual HTTP calls are defined.
    - `fetchCourses()`: Pulls the list of courses from the server.
    - `uploadSessions()`: Sends the local attendance data to the server in bulk.
    - **Note:** Update the `baseUrl` in this file to point to your live backend.

2.  **State Logic (`lib/presentation/providers/providers.dart`):**
    - These providers (using Riverpod) call the API services and handle the data flow (e.g., saving fetched courses to SQLite).
    - `CourseNotifier.syncCourses()`: Triggers the fetch and updates the local DB.
    - `SessionNotifier.syncSessions()`: Gathers all unsynced sessions and sends them to the API.

## How to generate the APK Perfectly

Since this is a Flutter project, the platform-specific folders (like `android/`) are generated based on your local Flutter SDK environment. 

### Step 1: Initialize Platform Folders
If the `android/` folder is missing, run this command in the project root:
```bash
flutter create .
```
This will generate the necessary Gradle and manifest files.

### Step 2: Add Camera Permissions
For the QR scanner to work, you must add the camera permission to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### Step 3: Build the APK
Run the following command to generate a release-ready APK:
```bash
flutter build apk --release
```
The resulting file will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

### Step 4: GitHub Actions (Automated)
I have already set up a GitHub Actions workflow in `.github/workflows/android.yml`. 
1. Push this code to a GitHub repository.
2. Go to the **Actions** tab.
3. The "Android Build" job will run automatically.
4. Once finished, you can download the **perfectly built APK** directly from the build artifacts.


## Project Structure

```text
lib/
├── db/              # SQLite Database Helper
├── models/          # Data Models (Course, Session, Record)
├── presentation/
│   ├── providers/   # Riverpod Notifiers & Providers
│   └── screens/     # UI Screens (Home, Scan, Session, etc.)
├── services/        # API & Business Logic Services
└── main.dart        # Entry point
```

## QR Code Format

The app validates student IDs against the following regex:
`^[A-Z]{2,5}-[0-9]{2}[A-Z]-[0-9]{3}$`

Example: `BSE-25F-086`

## CI/CD Pipeline

The project includes a GitHub Actions workflow located at `.github/workflows/android.yml`.
On every push to the `main` branch, it automatically:
1.  Sets up the Flutter environment.
2.  Installs dependencies.
3.  Builds a release APK.
4.  Uploads the APK as a build artifact.

## API Configuration

### Bulk Upload Endpoint
`POST /api/sessions/bulk-upload`

**Payload Format:**
```json
[
  {
    "session_id": "uuid",
    "course_id": "CS-101",
    "students": [
      {
        "student_id": "BSE-25F-086",
        "time": "2026-06-04T10:30:00"
      }
    ]
  }
]
```

---
Built with ❤️ for SMIU.
