import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/auth/presentation/providers/providers.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/state/auth_state.dart';
import 'features/events/data/datasources/event_local_data_source.dart';
import 'features/events/presentation/screens/event_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<String>(eventCacheBoxName);

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
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
