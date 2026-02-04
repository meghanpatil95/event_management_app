import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

import '../../features/events/domain/domain.dart';
import '../../firebase_options.dart';
import 'notification_ids.dart';

/// Handles push notifications: FCM (remote) and local scheduled reminders.
///
/// - **Foreground**: FCM messages are shown via [flutter_local_notifications]
///   so the user always sees a visible notification.
/// - **Background / Terminated**: FCM shows the notification (or we show via
///   [onBackgroundMessage] for data-only messages). Tap opens app with payload.
/// - **Event reminders**: Scheduled locally when user registers; cancelled when
///   they unregister.
class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'event_reminders',
    'Event reminders & updates',
    description: 'Reminders for registered events and status updates',
    importance: Importance.high,
    playSound: true,
  );

  /// Callback when user taps a notification (e.g. open event details).
  static void Function(String? eventId)? onNotificationTap;

  /// Initialize Firebase (if available), local notifications, FCM, and request permission.
/*  static Future<void> initialize() async {
    try {
      // await Firebase.initializeApp();
      Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

    } catch (_) {
      if (kDebugMode) {
        // Firebase not configured (no google-services.json / GoogleService-Info.plist)
        debugPrint('Firebase not initialized; remote push will be disabled.');
      }
    }

    await _instance._initLocal();
    await _instance._initFcm();
  }*/

  static Future<void> initialize() async {
    await _instance._initLocal();
    await _instance._initFcm();
  }


  Future<void> _initLocal() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    if (Platform.isIOS) {
      await _local
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      onNotificationTap?.call(payload);
    }
  }

  Future<void> _initFcm() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {}

    // Foreground: show via local notification so user always sees it
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // User tapped notification that opened the app (from background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // App opened from terminated state via notification tap
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? 'Event update';
    final body = notification?.body ?? message.data['body'] ?? '';
    final eventId = message.data['eventId'] as String?;

    showLocalNotification(
      title: title,
      body: body,
      payload: eventId,
      id: NotificationIds.fcmForegroundId,
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final eventId = message.data['eventId'] as String?;
    if (eventId != null) {
      onNotificationTap?.call(eventId);
    }
  }

  /// Show a local notification (e.g. for FCM in foreground).
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = NotificationIds.fcmForegroundId,
  }) async {
     var android = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
     var details = NotificationDetails(android: android, iOS: ios);
    await _local.show(id, title, body, details, payload: payload);
  }

  /// Schedule local reminders for a registered event (1 day and 1 hour before).
  Future<void> scheduleEventReminders(Event event) async {
    await cancelEventReminders(event.id);

    final eventId = event.id;
    final title = event.title;
    final at = event.dateTime;
    if (at.isBefore(DateTime.now())) return;

    final tzLocation = tz.local;
    final atTz = tz.TZDateTime.from(at, tzLocation);

    // 1 day before
    final oneDayBefore = atTz.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(tz.TZDateTime.now(tzLocation))) {
      await _local.zonedSchedule(
        NotificationIds.eventReminderId(eventId, 0),
        'Tomorrow: $title',
        'Your event is in 1 day. ${event.location}',
        oneDayBefore,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: eventId,
      );
    }

    // 1 hour before
    final oneHourBefore = atTz.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(tz.TZDateTime.now(tzLocation))) {
      await _local.zonedSchedule(
        NotificationIds.eventReminderId(eventId, 1),
        'Starting soon: $title',
        'Your event starts in 1 hour. ${event.location}',
        oneHourBefore,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: eventId,
      );
    }
  }

  /// Cancel all scheduled reminders for an event (e.g. after unregister).
  Future<void> cancelEventReminders(String eventId) async {
    for (var slot = 0; slot < NotificationIds.reminderSlotsPerEvent; slot++) {
      await _local.cancel(NotificationIds.eventReminderId(eventId, slot));
    }
  }

  /// FCM token for sending from your backend (optional).
  Future<String?> getToken() => FirebaseMessaging.instance.getToken();
}

/// Top-level handler for FCM background messages (required by Firebase).
/// Keep minimal; no UI or plugin state. FCM shows notification automatically
/// when message has notification payload; use data payload for deep link (eventId).
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

