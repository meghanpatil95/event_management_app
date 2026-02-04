import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../network/api_client_provider.dart';
import '../../features/auth/presentation/providers/providers.dart';
import '../../features/auth/presentation/state/auth_state.dart';
import 'mock_socket_service.dart';
import 'socket_service.dart';

/// Current access token when authenticated; null otherwise.
final authTokenProvider = Provider<String?>((ref) {
  final auth = ref.watch(authProvider);
  return auth is AuthAuthenticated ? auth.session.accessToken : null;
});

/// Singleton Socket.IO service. Connected when user is authenticated;
/// null when not. Handles reconnection via socket_io options; app lifecycle
/// (disconnect on pause, connect on resume) is handled by [SocketLifecycleMixin].
final socketServiceProvider =
    NotifierProvider<SocketServiceNotifier, SocketService?>(SocketServiceNotifier.new);

class SocketServiceNotifier extends Notifier<SocketService?> {
  SocketService? _current;

  @override
  SocketService? build() {
    final config = ref.watch(apiConfigProvider);
    final auth = ref.watch(authProvider);
    final token = auth is AuthAuthenticated ? auth.session.accessToken : null;

    if (token == null || token.isEmpty) {
      _current?.dispose();
      _current = null;
      return null;
    }

    if (_current != null) return _current;

    _current = ApiConfig.useMockApi
        ? MockSocketService(socketUrl: config.effectiveSocketUrl)
        : RealSocketService(socketUrl: config.effectiveSocketUrl);
    _current!.connect(token);
    ref.onDispose(() {
      _current?.dispose();
      _current = null;
    });
    return _current;
  }
}
