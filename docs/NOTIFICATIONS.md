# Push Notifications

This app supports **event reminders** (local) and **remote push** (Firebase Cloud Messaging) for status updates.

## Behaviour

| Scenario | Behaviour |
|----------|-----------|
| **Foreground** | When a remote message is received while the app is open, a local notification is shown so the user always sees it. Tapping opens event details. |
| **Background** | FCM shows the notification. Tapping opens the app and navigates to the event (if `eventId` is in the message data). |
| **Terminated** | Same as background: system notification, tap opens app and event details. |
| **Event reminders** | When the user **registers** for an event, local notifications are scheduled for **1 day before** and **1 hour before**. When they **unregister**, those reminders are cancelled. |

## Local reminders (no backend)

- **Scheduled** when the user taps "Register" on an event.
- **Cancelled** when the user taps "Unregister".
- Reminders use the **event_reminders** channel (Android) and standard alert/badge/sound (iOS).

No Firebase is required for local reminders. If Firebase is not configured, the app still runs; only remote push will be disabled.

**Note:** The Android build applies the Google Services plugin, which expects `google-services.json`. If you are not using Firebase yet, either add a minimal `google-services.json` from the Firebase Console, or temporarily remove/comment out the `com.google.gms.google-services` plugin from `android/settings.gradle.kts` and `android/app/build.gradle.kts` so the project builds.

## Remote push (Firebase Cloud Messaging)

To send **event status updates** (e.g. "Event cancelled", "Event starting soon") from your backend:

1. **Configure Firebase**
   - Create a project in [Firebase Console](https://console.firebase.google.com).
   - Add an Android app (package: `com.webwork.event_management_app`) and download `google-services.json` into `android/app/`.
   - Add an iOS app and download `GoogleService-Info.plist` into `ios/Runner/`.
   - Run `flutterfire configure` (optional; generates `lib/firebase_options.dart` for Flutter).

2. **Send messages with `eventId`**
   - Include `eventId` in the **data** payload so the app can open the correct event when the user taps the notification:
   ```json
   {
     "data": {
       "eventId": "<event-uuid>",
       "title": "Event cancelled",
       "body": "Your event 'Meetup' has been cancelled."
     }
   }
   ```
   - For **foreground** display, the app shows a local notification using `title`/`body` from the **notification** payload or from `data`.

3. **FCM token**
   - Use `NotificationService.instance.getToken()` (or inject `notificationServiceProvider`) to get the device token and send it to your backend so you can target this device.

## Android

- **Min SDK**: 21 (required by FCM).
- **Android 13+**: The app requests `POST_NOTIFICATIONS` at runtime; `NotificationService.initialize()` calls `FirebaseMessaging.instance.requestPermission()` (handled by the plugin).
- **Channels**: Notifications use the channel `event_reminders` (created at startup).

## iOS

- **Capabilities**: Enable **Push Notifications** and **Background Modes** (Remote notifications) in Xcode.
- **Info.plist**: `UIBackgroundModes` includes `remote-notification` and `fetch`.
- **Permission**: Requested in `NotificationService.initialize()`.

## Testing local reminders

1. Run the app and log in.
2. Open an event that is in the future (e.g. tomorrow or in 2 hours).
3. Tap **Register**.
4. Reminders are scheduled for 1 day and 1 hour before the event. To test quickly, temporarily change the schedule in `NotificationService.scheduleEventReminders()` (e.g. 1 minute before).
5. Background or close the app; you should see the reminder at the scheduled time.

## Testing remote push

1. Configure Firebase and add `google-services.json` / `GoogleService-Info.plist`.
2. Get the FCM token (e.g. log `NotificationService.instance.getToken()`).
3. Use Firebase Console → Cloud Messaging to send a test message, or your backend to send a message with `data.eventId` set.
4. Confirm behaviour in foreground (in-app notification), background (system notification), and after killing the app (tap opens event).
