import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'socket_provider.dart';

/// Wraps [child] and observes app lifecycle to disconnect Socket.IO when
/// the app goes to background and reconnect when it resumes.
class SocketLifecycleHandler extends ConsumerStatefulWidget {
  const SocketLifecycleHandler({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<SocketLifecycleHandler> createState() =>
      _SocketLifecycleHandlerState();
}

class _SocketLifecycleHandlerState extends ConsumerState<SocketLifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final service = ref.read(socketServiceProvider);
    if (service == null) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        service.disconnect();
        break;
      case AppLifecycleState.resumed:
        service.connect(ref.read(authTokenProvider));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
