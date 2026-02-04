# Firebase Setup with FlutterFire CLI

This document provides step-by-step instructions for setting up Firebase Cloud Messaging (FCM) for push notifications using the **FlutterFire CLI** exclusively from the command line.

---

##  Prerequisites

Before starting, ensure you have:
-  Flutter SDK installed and configured
-  Firebase CLI installed
-  A Google account for Firebase Console
-  Internet connection

---

##  Step 1: Install FlutterFire CLI

The FlutterFire CLI is a tool that automates Firebase configuration for Flutter projects.

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli
```

**Verify installation:**
```bash
flutterfire --version
```

You should see output like: `FlutterFire CLI version X.X.X`

---

##  Step 2: Login to Firebase

Login to your Google account that has access to Firebase:

```bash
firebase login
```

This will:
1. Open a browser window
2. Ask you to select your Google account
3. Request permissions for Firebase CLI
4. Show "Success! Logged in as [your-email]"

**To verify login:**
```bash
firebase projects:list
```

You should see a list of your Firebase projects (or an empty list if you don't have any yet).

---

## 📱 Step 3: Create Firebase Project (via Console or CLI)

### Option A: Using Firebase Console (Recommended for first-time setup)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `event-management-app` (or your preferred name)
4. Click **Continue**
5. Choose whether to enable Google Analytics (optional)
6. Click **Create project**
7. Wait for project creation to complete
8. Click **Continue** to go to project dashboard

### Option B: Using Firebase CLI

```bash
# Create a new Firebase project
firebase projects:create event-management-app

# Set the project ID when prompted
# Enter display name: Event Management App
```

---

## ⚙️ Step 4: Configure Flutter App with FlutterFire CLI

This is the **most important step** - it automatically generates all necessary configuration files.

Navigate to your Flutter project directory:

```bash
cd event_management_app
```

Run FlutterFire configure:

```bash
flutterfire configure
```

### What happens during configuration?

1. **Select Firebase project**
   ```
   ? Select a Firebase project to configure your Flutter application with:
   > event-management-app (recommended)
     Create a new project
     [other projects if you have any]
   ```
   Use arrow keys to select your project and press Enter.

2. **Select platforms**
   ```
   ? Which platforms should your configuration support?
   > [x] android
   > [x] ios
   > [ ] macos
   > [ ] web
   > [ ] windows
   > [ ] linux
   ```
   Use Space to select Android and iOS, then press Enter.

3. **Enter package name (Android)**
   ```
   ? What is the package name for your Android app? 
   > com.webwork.event_management_app
   ```
   Press Enter (should auto-detect from `android/app/build.gradle.kts`)

4. **Enter bundle identifier (iOS)**
   ```
   ? What is the bundle identifier for your iOS app?
   > com.webwork.eventManagementApp
   ```
   Press Enter (should auto-detect from `ios/Runner.xcodeproj`)

### Output

FlutterFire CLI will:
-  Create/update Firebase apps in your project
-  Download `google-services.json` → `android/app/google-services.json`
-  Download `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`
-  Generate `lib/firebase_options.dart` with platform-specific configuration
-  Show success message

**Expected output:**
```
✔ Firebase configuration file lib/firebase_options.dart generated successfully with the following Firebase apps:

Platform  Firebase App Id
android   1:123456789:android:abc123def456
ios       1:123456789:ios:xyz789abc123

Learn more about using this file in the FlutterFire documentation:
https://firebase.google.com/docs/flutter/setup
```

---

##  Step 5: Verify Generated Files

Check that the following files were created:

### 1. `lib/firebase_options.dart`
```bash
ls lib/firebase_options.dart
```

This file contains:
```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // ...
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // ...
    }
  }
  
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIza...',
    appId: '1:123...',
    messagingSenderId: '123...',
    projectId: 'event-management-app',
    storageBucket: '...',
  );
  
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIza...',
    appId: '1:123...',
    messagingSenderId: '123...',
    projectId: 'event-management-app',
    storageBucket: '...',
    iosBundleId: 'com.webwork.eventManagementApp',
  );
}
```

### 2. `android/app/google-services.json`
```bash
ls android/app/google-services.json
```

Should contain:
```json
{
  "project_info": {
    "project_number": "123456789",
    "project_id": "event-management-app",
    "storage_bucket": "..."
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123...:android:abc...",
        "android_client_info": {
          "package_name": "com.webwork.event_management_app"
        }
      }
    }
  ]
}
```

### 3. `ios/Runner/GoogleService-Info.plist`
```bash
ls ios/Runner/GoogleService-Info.plist
```

Should contain:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CLIENT_ID</key>
	<string>123...apps.googleusercontent.com</string>
	<key>REVERSED_CLIENT_ID</key>
	<string>com.googleusercontent.apps.123...</string>
	<key>API_KEY</key>
	<string>AIza...</string>
	<key>GCM_SENDER_ID</key>
	<string>123...</string>
	<key>PLIST_VERSION</key>
	<string>1</string>
	<key>BUNDLE_ID</key>
	<string>com.webwork.eventManagementApp</string>
	<key>PROJECT_ID</key>
	<string>event-management-app</string>
</dict>
</plist>
```

---

##  Step 6: Add Firebase Dependencies

The project already has these dependencies in `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_messaging: ^15.1.5
  flutter_local_notifications: ^18.0.1
```

If not already added, run:
```bash
flutter pub add firebase_core firebase_messaging flutter_local_notifications
```

Then get dependencies:
```bash
flutter pub get
```

---

## 🔨 Step 7: Verify Android Configuration

Check that `android/app/build.gradle.kts` has the Google Services plugin:

```bash
cat android/app/build.gradle.kts | grep "google-services"
```

Should show:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  //  This line
}
```

And in `android/build.gradle.kts`:
```bash
cat android/build.gradle.kts | grep "google-services"
```

Should show:
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.0")  //  This line
}
```

---

##  Step 8: Verify iOS Configuration

### 1. Check that `GoogleService-Info.plist` is in Xcode project:

```bash
# Open Xcode project
open ios/Runner.xcworkspace
```

In Xcode:
1. Select **Runner** in the project navigator
2. Look for `GoogleService-Info.plist` under **Runner** folder
3. If it's there but greyed out, you need to add it to the target:
    - Right-click on **Runner** folder → **Add Files to "Runner"**
    - Navigate to `ios/Runner/GoogleService-Info.plist`
    - Check **"Copy items if needed"** and **"Add to targets: Runner"**
    - Click **Add**

### 2. Verify capabilities:

In Xcode:
1. Select **Runner** project
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Ensure these capabilities are enabled:
    -  **Push Notifications**
    -  **Background Modes** (with "Remote notifications" checked)

### 3. Verify `Info.plist` has background modes:

```bash
cat ios/Runner/Info.plist | grep -A 2 "UIBackgroundModes"
```

Should show:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

##  Step 9: Initialize Firebase in Flutter App

Your `main.dart` should have Firebase initialization (already done in your project):

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set background message handler BEFORE Firebase initialization
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notification service
  await NotificationService.initialize();

  // Get FCM token
  final token = await NotificationService.instance.getToken();
  debugPrint('FCM TOKEN: $token');

  runApp(MyApp());
}
```

---

##  Step 10: Test Firebase Setup

### 1. Run the app:

```bash
flutter run
```

### 2. Check console output:

Look for successful Firebase initialization:
```
[firebase_core] Initialized Firebase
[firebase_messaging] FCM TOKEN: fG7X9k...
```

### 3. Get FCM token from logs:

The token will be printed in the console when the app starts. Copy it for testing.

**Example token:**
```
fG7X9kH2S8mP4nQ6jL1dK3vB5zN7wR9tY2xC4aE6gI8oU0pM1sQ3h
```

---

## 📨 Step 11: Test Push Notifications

### Option A: Using Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **event-management-app**
3. Navigate to **Engage** → **Cloud Messaging** in the left sidebar
4. Click **"Send your first message"** or **"New campaign"** → **"Firebase Notification messages"**
5. Fill in:
    - **Notification title**: "Test Notification"
    - **Notification text**: "This is a test from Firebase Console"
6. Click **Next**
7. Under **Target**:
    - Select **"User segment"** → **"All users"**
    - OR select **"Single device"** and paste your FCM token
8. Click **Next**
9. Schedule: **Now**
10. Click **Next** → **Review** → **Publish**

### Option B: Using cURL (Command Line)

First, get your **Server Key** from Firebase Console:
1. Go to **Project Settings** (gear icon) → **Cloud Messaging** tab
2. Under **Cloud Messaging API (Legacy)**, copy the **Server key**

Then send a test notification:

```bash
# Replace <SERVER_KEY> with your actual server key
# Replace <FCM_TOKEN> with the token from your app logs

curl -X POST \
  https://fcm.googleapis.com/fcm/send \
  -H 'Authorization: key=<SERVER_KEY>' \
  -H 'Content-Type: application/json' \
  -d '{
    "to": "<FCM_TOKEN>",
    "notification": {
      "title": "Test from cURL",
      "body": "This is a command-line test"
    },
    "data": {
      "eventId": "event_1",
      "title": "Event Update",
      "body": "Your event is starting soon"
    }
  }'
```

**Example:**
```bash
curl -X POST \
  https://fcm.googleapis.com/fcm/send \
  -H 'Authorization: key=AAAA1234567890abcdefghijklmnopqrstuvwxyz' \
  -H 'Content-Type: application/json' \
  -d '{
    "to": "fG7X9kH2S8mP4nQ6jL1dK3vB5zN7wR9tY2xC4aE6gI8oU0pM1sQ3h",
    "notification": {
      "title": "Event Cancelled",
      "body": "The Flutter meetup has been cancelled"
    },
    "data": {
      "eventId": "event_1"
    }
  }'
```

### Expected Response:
```json
{
  "multicast_id": 123456789,
  "success": 1,
  "failure": 0,
  "canonical_ids": 0,
  "results": [
    {
      "message_id": "0:1234567890%abc123def456"
    }
  ]
}
```

### Option C: Using Postman

1. Create a new POST request to:
   ```
   https://fcm.googleapis.com/fcm/send
   ```

2. Add headers:
    - `Authorization`: `key=<YOUR_SERVER_KEY>`
    - `Content-Type`: `application/json`

3. Add JSON body:
   ```json
   {
     "to": "<FCM_TOKEN>",
     "notification": {
       "title": "Test from Postman",
       "body": "FCM is working!"
     },
     "data": {
       "eventId": "event_1"
     }
   }
   ```

4. Click **Send**

---

##  Testing Different Scenarios

### 1. Foreground (App Open)
- Run the app
- Send notification (using any method above)
-  Should show in-app local notification
-  Tapping opens event details

### 2. Background (App Minimized)
- Run the app, then minimize it (press Home button)
- Send notification
-  Should show system notification
-  Tapping opens app and navigates to event details

### 3. Terminated (App Closed)
- Run the app, then close it completely (swipe away)
- Send notification
-  Should show system notification
-  Tapping opens app and navigates to event details

---

##  Reconfiguring Firebase (If Needed)

If you need to change projects or update configuration:

```bash
# Run configure again
flutterfire configure

# Select a different project or create new one
# Follow the same prompts
```

This will update all configuration files automatically.

---

##  Troubleshooting

### Issue 1: `firebase` command not found

**Solution:**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Or using cURL (macOS/Linux)
curl -sL https://firebase.tools | bash
```

### Issue 2: `flutterfire` command not found

**Solution:**
```bash
# Activate FlutterFire CLI
dart pub global activate flutterfire_cli

# Add to PATH if needed (macOS/Linux)
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc

# Or for bash
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Issue 3: `google-services.json` not found during build

**Solution:**
```bash
# Ensure file exists
ls android/app/google-services.json

# If missing, run flutterfire configure again
flutterfire configure

# Or download manually from Firebase Console:
# Project Settings → Your apps → Download google-services.json
```

### Issue 4: iOS build fails with GoogleService-Info.plist error

**Solution:**
```bash
# 1. Ensure file exists
ls ios/Runner/GoogleService-Info.plist

# 2. Open Xcode
open ios/Runner.xcworkspace

# 3. Right-click Runner folder → Add Files to "Runner"
# 4. Select GoogleService-Info.plist
# 5. Check "Copy items if needed" and "Add to targets: Runner"
# 6. Clean build folder: Product → Clean Build Folder
# 7. Rebuild
```

### Issue 5: No FCM token in logs

**Solution:**
```dart
// Add this in main.dart after Firebase initialization
final messaging = FirebaseMessaging.instance;

// Request permission (iOS)
final settings = await messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);

print('Permission status: ${settings.authorizationStatus}');

// Get token
final token = await messaging.getToken();
print('FCM Token: $token');

// Listen for token refresh
messaging.onTokenRefresh.listen((newToken) {
  print('New FCM Token: $newToken');
});
```

### Issue 6: Notifications not received

**Check:**
1.  FCM token is valid (not null)
2.  Firebase project is correct
3.  Server key is correct (in cURL/Postman)
4.  App is connected to internet
5.  Notification permissions granted (iOS Settings → App → Notifications)
6.  Background message handler is registered BEFORE Firebase init
7.  Google Services plugin applied (Android)

**Test connection:**
```dart
// In your app
FirebaseMessaging.instance.getAPNSToken().then((apnsToken) {
  print('APNs Token (iOS): $apnsToken');
});

FirebaseMessaging.instance.getToken().then((fcmToken) {
  print('FCM Token: $fcmToken');
});
```

### Issue 7: Android build fails with Google Services plugin error

**Solution:**

Check `android/build.gradle.kts` has the classpath:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

Check `android/app/build.gradle.kts` applies the plugin:
```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

If still fails, try:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 📚 Additional Resources

### Official Documentation
- [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup?platform=android)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [FCM HTTP v1 API](https://firebase.google.com/docs/cloud-messaging/migrate-v1)

### Useful Commands

```bash
# List Firebase projects
firebase projects:list

# Get current project
firebase projects:current

# Switch project
firebase use <project-id>

# Deploy security rules (if using Firestore/Storage)
firebase deploy --only firestore:rules
firebase deploy --only storage

# View logs
firebase functions:log

# Run local emulator (for testing)
firebase emulators:start
```

---

## 🎯 Summary

You've successfully set up Firebase Cloud Messaging using **FlutterFire CLI exclusively from the command line**:

 **Step 1:** Installed FlutterFire CLI  
 **Step 2:** Logged into Firebase  
 **Step 3:** Created/selected Firebase project  
 **Step 4:** Configured Flutter app with `flutterfire configure`  
 **Step 5:** Verified generated configuration files  
 **Step 6:** Added Firebase dependencies  
 **Step 7:** Verified Android configuration  
 **Step 8:** Verified iOS configuration  
 **Step 9:** Initialized Firebase in Flutter app  
 **Step 10:** Tested Firebase setup  
 **Step 11:** Tested push notifications

Your app is now ready to receive push notifications for event updates! 🎉

---

##  Notes

- The **FlutterFire CLI** automatically handles all platform-specific configuration
- The **`firebase_options.dart`** file is generated and should **not be edited manually**
- If you change Firebase project or add new platforms, just run `flutterfire configure` again
- The **Server Key** (for sending notifications) is found in Firebase Console under **Project Settings → Cloud Messaging**
- For production, consider using **Firebase Cloud Functions** to send notifications instead of exposing the Server Key

---

**End of Firebase Setup Guide** - Your FCM integration is complete! 