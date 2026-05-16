# 🔥 Firebase Setup Guide for SafeNet AI

## Step-by-Step Firebase Configuration

### 1. Create Firebase Project

1. Go to **https://console.firebase.google.com/**
2. Click **"Add Project"**
3. Enter project name: `SafeNet-AI`
4. Enable Google Analytics → Click **"Create Project"**
5. Wait for project creation → Click **"Continue"**

---

### 2. Add Android App to Firebase

1. In the Firebase console, click the **Android icon** (Add app)
2. Enter the package name: **`com.safenetai.safenet_ai`**
3. App nickname: `SafeNet AI`
4. Debug signing certificate (**SHA-1**): Get it by running:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Or on Windows:
   ```powershell
   cd android
   .\gradlew.bat signingReport
   ```
   Copy the **SHA-1** from the `debug` variant.

5. Click **"Register App"**
6. **Download `google-services.json`**
7. Place it in: `safenet_ai/android/app/google-services.json`

---

### 3. Enable Firebase Services

#### Authentication:
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Enable **Phone** (for OTP)

#### Cloud Firestore:
1. Go to **Firestore Database** → **Create Database**
2. Choose **"Start in test mode"** (for development)
3. Select your region → **Enable**

#### Firebase Storage:
1. Go to **Storage** → **Get Started**
2. Choose **test mode** → **Done**

#### Cloud Messaging:
1. Go to **Cloud Messaging** → It's enabled by default
2. Note down the **Server Key** if needed

---

### 4. Install FlutterFire CLI (Recommended)

Run these commands in your terminal:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (auto-generates firebase_options.dart)
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

This will:
- Auto-detect your Firebase project
- Generate `lib/firebase_options.dart`
- Update `android/app/build.gradle` with necessary plugins

---

### 5. Manual Configuration (If not using FlutterFire CLI)

#### android/build.gradle (project-level):
Make sure the Google Services plugin is added:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

#### android/app/build.gradle:
Add at the bottom:
```gradle
apply plugin: 'com.google.gms.google-services'
```

Also ensure:
```gradle
android {
    defaultConfig {
        minSdkVersion 23  // Required for Firebase
        multiDexEnabled true
    }
}
```

---

### 6. Update main.dart (if using FlutterFire CLI)

If you used `flutterfire configure`, update `lib/main.dart`:

```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SafeNetApp());
}
```

---

### 7. Firestore Security Rules

Go to **Firestore → Rules** and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

### 8. Twilio SMS Setup

1. Go to **https://www.twilio.com/try-twilio** → Create account
2. Get your **Account SID**, **Auth Token**, and **Phone Number**
3. Update `lib/config/constants.dart`:
   ```dart
   static const String twilioAccountSid = 'ACxxxxxxxxxx';
   static const String twilioAuthToken = 'your_auth_token';
   static const String twilioPhoneNumber = '+1234567890';
   ```

---

### 9. Admin Panel Firebase Config

Update `admin_panel/js/firebase-config.js` with your Firebase web config:

1. In Firebase Console → Project Settings → General → Your apps → Web app
2. If not added, click **Add app** → **Web** → Register
3. Copy the config object and paste into `firebase-config.js`

---

### 10. Run the App

```bash
# Start Android emulator first
# Then run:
flutter run

# For ML API (separate terminal):
cd ml_api
pip install -r requirements.txt
python app.py

# For admin panel (separate terminal):
cd admin_panel
npx serve .
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `google-services.json` not found | Place in `android/app/` directory |
| `minSdkVersion` too low | Set to 23 in `android/app/build.gradle` |
| Firebase init fails | Run `flutterfire configure` |
| No Android device | Start Android emulator from Android Studio |
| Twilio SMS fails | Verify credentials and phone number format |
