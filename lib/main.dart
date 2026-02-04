import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'core/notifications/notification_service.dart';
import 'core/socket/socket_lifecycle.dart';
import 'features/auth/presentation/providers/providers.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/state/auth_state.dart';
import 'features/chat/data/datasources/chat_local_data_source.dart';
import 'features/events/data/datasources/event_local_data_source.dart';
import 'features/events/presentation/screens/event_details_screen.dart';
import 'features/events/presentation/screens/event_list_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Must be set before runApp for background FCM handler
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  // await Hive.openBox<String>(eventCacheBoxName);
  await Hive.deleteBoxFromDisk(eventCacheBoxName);

  await Hive.openBox<Map>(eventCacheBoxName);
  await Hive.openBox<String>(chatCacheBoxName);

  await NotificationService.initialize();

  //used this token to send message from backend or FCM
  final token = await NotificationService.instance.getToken();
  debugPrint(' FCM TOKEN: $token');

  runApp(ProviderScope(child: SocketLifecycleHandler(child: MyApp())));
}

/// Navigator key so notification tap can open event details when app is already running.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // When user taps a notification (foreground/background/terminated), open event details
    NotificationService.onNotificationTap = (eventId) {
      if (eventId == null) return;
      navigatorKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (_) => EventDetailsScreen(eventId: eventId),
        ),
      );
    };

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Event Management App',
      home: switch (authState) {
        AuthInitial() || AuthLoading() => const _AuthLoadingScreen(),
        AuthAuthenticated() => const EventListScreen(),
        AuthUnauthenticated() || AuthError() => const LoginScreen(),
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
