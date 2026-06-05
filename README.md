# 📱 CAMSCAN - Offline-First Attendance Ecosystem

CAMSCAN is a professional-grade, full-stack attendance management system designed for environments where internet connectivity is unreliable. It utilizes an **Offline-First** architecture, allowing teachers to scan student QR codes in real-time without a connection, and synchronize data to a cloud-based **MongoDB Atlas** database when they are back online.

---

## 🏗️ System Architecture

The ecosystem consists of three main components:

1.  **Mobile App (Flutter):** The frontend for scanning and local data management.
2.  **Backend API (FastAPI):** The serverless bridge between the mobile app and the cloud.
3.  **Cloud Storage (MongoDB Atlas):** The central repository for all attendance records.

### End-to-End Data Flow
1.  **Mobile:** Scans QR ➔ Validates Regex ➔ Checks for duplicates ➔ Stores in **Local SQLite**.
2.  **Sync:** Admin triggers "Push" ➔ Mobile sends bulk JSON to **Vercel API** (Secured with X-API-KEY).
3.  **Cloud:** Backend receives JSON ➔ Upserts records into **MongoDB Atlas**.

---

## 📱 Mobile App (Flutter)

### Key Features
*   **Offline Tracking:** Full functionality without internet.
*   **Real-time QR Validation:** Validates IDs against: `^[A-Z]{2,5}-[0-9]{2}[A-Z]-[0-9]{3}$`.
*   **Haptic Feedback:** Professional vibration patterns (Success, Duplicate, Error).
*   **Duplicate Prevention:** Prevents the same student from being scanned twice in one session.
*   **Admin Tools:** Manual triggers for pulling courses and pushing data.

### Tech Stack
*   **Framework:** Flutter (Material 3)
*   **State Management:** Riverpod
*   **Local DB:** SQLite (sqflite)
*   **Scanning:** mobile_scanner

---

## 🌐 Backend API (FastAPI)

Deployed on **Vercel**, the backend is optimized for serverless execution.

### Key Features
*   **Serverless Optimized:** Uses lazy-loading for database connections to prevent cold-start crashes.
*   **Security:** Protected by an `X-API-KEY` header requirement.
*   **Auto-Seeding:** Automatically populates the master course list in MongoDB if it's empty.
*   **Health Checks:** Dedicated routes for monitoring system status.

### Endpoints
*   `GET /`: API Status & Welcome message.
*   `GET /api/health`: Comprehensive system health report.
*   `GET /api/courses`: Fetch master course list (Requires API Key).
*   `POST /api/sessions/bulk-upload`: Upload attendance data (Requires API Key).

---

## 🛠️ Setup & Deployment

### 1. MongoDB Atlas Setup
1.  Create a cluster at [MongoDB Atlas](https://www.mongodb.com/).
2.  Whitelist `0.0.0.0/0` in Network Access (required for Vercel's dynamic IPs).
3.  Copy your Connection String.

### 2. Backend Deployment (Vercel)
1.  Navigate to `backend/`.
2.  Install Vercel CLI: `npm i -g vercel`.
3.  Run `vercel` and configure your environment variables:
    *   `MONGODB_URI`: Your Atlas string.
    *   `API_KEY`: A secret key for your app.
    *   `DB_NAME`: `camscan`.

### 3. Mobile App Configuration
1.  Open `lib/services/api_service.dart`.
2.  Update `baseUrl` with your Vercel URL.
3.  Update `apiKey` with the key you set in Vercel.

---

## 🚀 CI/CD Pipeline (GitHub Actions)

The project includes a sophisticated `.github/workflows/android.yml` that:
1.  **Caches** dependencies to speed up builds.
2.  **Generates Icons** automatically from `assets/icon.png`.
3.  **Configures Android SDK** (V34) and permissions on-the-fly.
4.  **Builds & Uploads** a release-ready APK to the GitHub "Actions" tab.

---

## 📂 Project Structure

```text
/
├── assets/             # App Icons & Images
├── backend/            # FastAPI Project
│   ├── main.py         # Entry point & Routes
│   ├── database.py     # MongoDB Connection Logic
│   ├── models.py       # Pydantic Schemas
│   ├── seed.py         # Standalone Database Seeder
│   └── vercel.json     # Vercel Deployment Config
├── lib/                # Flutter Project
│   ├── db/             # Local SQLite Logic
│   ├── models/         # Data Classes
│   ├── presentation/   # UI Screens & Riverpod Providers
│   └── services/       # Network & API logic
└── README.md           # This Documentation
```

---

## 🧪 Seeding Data
To manually populate your cloud database with the default course list:
```bash
cd backend
python seed.py
```

---
Built with ❤️ for **SMIU** | **CAMSCAN Ecosystem** v1.0.0
