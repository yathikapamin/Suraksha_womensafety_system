# 🛡️ SafeNet AI – Women Safety System

> AI-powered Women Safety Mobile Application using Multi-Agent MCP Architecture

---

## 📱 Overview

SafeNet AI is an intelligent women safety system built using **Flutter, Firebase, and Python ML services**.  
It provides real-time threat detection, location tracking, emergency alerts, and a tiered responder system powered by a multi-agent AI pipeline.

---

## 🏗️ Architecture


                     ┌──────────────────────────────┐
                     │        Flutter App           │
                     │                              │
                     │  ┌────────────────────────┐  │
                     │  │       UI Layer         │  │
                     │  │ Screens / Widgets      │  │
                     │  └────────────────────────┘  │
                     │                              │
                     │  ┌────────────────────────┐  │
                     │  │   State Management     │  │
                     │  │     Providers          │  │
                     │  └────────────────────────┘  │
                     │                              │
                     │  ┌────────────────────────┐  │
                     │  │      Services          │  │
                     │  │ Auth / Location / SMS  │  │
                     │  └────────────────────────┘  │
                     │                              │
                     │  ┌────────────────────────┐  │
                     │  │   AI Agent System      │  │
                     │  │ Detection → Context    │  │
                     │  │ Decision → Response    │  │
                     │  │ → Nearby Responder     │  │
                     │  └────────────────────────┘  │
                     └──────────────┬───────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
### Backend Services

- 🔥 Firebase → Authentication, Database, Storage, FCM  
- 📩 Twilio → SMS alert system  
- 🧠 Flask ML → Risk prediction engine


---

## 🚀 Setup Guide

### 🔧 Prerequisites

- Flutter SDK (3.0+)
- Android Studio / VS Code
- Firebase CLI
- Python 3.8+
- Node.js (optional for admin panel)

---

## 🔥 Firebase Setup

1. Create project → **SafeNet AI**
2. Enable:
   - Authentication (Email/Phone)
   - Firestore Database
   - Firebase Storage
   - Cloud Messaging

3. Add Android app:
   - Package: `com.safenetai.safenet_ai`
   - Download `google-services.json`
   - Place in:
     ```
     android/app/
     ```

4. Setup FlutterFire:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
🗄️ Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null;
    }

    match /alerts/{alertId} {
      allow read, write: if request.auth != null;
    }

    match /context/{userId} {
      allow read, write: if request.auth != null;
    }

    match /verification_requests/{userId} {
      allow read, write: if request.auth != null;
    }

    match /emergency_contacts/{contactId} {
      allow read, write: if request.auth != null;
    }

    match /notifications/{notifId} {
      allow read, write: if request.auth != null;
    }
  }
}
📦 Installation
cd safenet_ai
flutter pub get
🔑 Configuration

Edit:

lib/config/constants.dart

Add:

Twilio API credentials
ML API URL
🤖 Run ML Backend
cd ml_api
pip install -r requirements.txt
python app.py
📱 Run App
flutter run
🌐 Run Admin Panel
cd admin_panel
npx serve .

OR open:

index.html
📂 Project Structure
safenet_ai/
├── lib/
│   ├── config/
│   ├── models/
│   ├── services/
│   ├── agents/
│   ├── providers/
│   ├── screens/
│   └── widgets/
│
├── ml_api/
├── admin_panel/
└── README.md
🧠 Multi-Agent System
Agent	Role
Detection Agent	Collects sensor data
Context Agent	Builds context
Decision Agent	Calculates risk score
Response Agent	Sends alerts
Nearby Agent	Finds helpers
📊 Risk Calculation
finalRisk =
  (motionScore × 0.3) +
  (audioScore × 0.4) +
  (locationRisk × 0.3)
Risk Levels:
🟢 Safe → < 0.3
🟡 Caution → 0.3 – 0.6
🔴 Emergency → ≥ 0.6
📱 Features
Authentication (Firebase)
Live Location Tracking
Emergency Alert Button
AI Threat Detection
Multi-Agent Processing System
OpenStreetMap Integration
SMS + Push Notifications
Nearby Responder System
Alert History Tracking
🔔 Alert System
Tier 1 – Verified Responders
Instant notification
Exact location shared
SMS with map link
Tier 2 – Nearby Users
Approximate location
Accept/Reject alert
First responders get full access
🛠️ Tech Stack
Layer	Technology
Frontend	Flutter
Backend	Firebase
ML API	Python Flask
Maps	OpenStreetMap
Messaging	Twilio
Admin Panel	HTML/CSS/JS
State Mgmt	Provider
