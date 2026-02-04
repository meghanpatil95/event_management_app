import 'dart:async';

import '../mock/mock_event_status_overrides.dart';
import 'socket_service.dart';

/// Mock Socket.IO service for demo without a backend.
///
/// - [connect] simulates connection and, after a delay, emits a mock
///   event status update so the UI shows a live event status change.
/// - [sendChatMessage] echoes the message on [chatMessages] and triggers
///   delivery status (sent → delivered → read) after short delays.
class MockSocketService implements SocketService {
  MockSocketService({this.socketUrl = 'mock://localhost'});

  @override
  final String socketUrl;

  final StreamController<Map<String, dynamic>> _eventStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _chatMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _deliveryStatusController =
      StreamController<Map<String, dynamic>>.broadcast();

  Timer? _statusUpdateTimer;
  bool _connected = false;
  bool _disposed = false;

  @override
  Stream<Map<String, dynamic>> get eventStatusUpdates =>
      _eventStatusController.stream;

  @override
  Stream<Map<String, dynamic>> get chatMessages => _chatMessageController.stream;

  @override
  Stream<Map<String, dynamic>> get chatDeliveryStatusUpdates =>
      _deliveryStatusController.stream;

  @override
  bool get isConnected => _connected;

  @override
  void connect(String? token) {
    if (_disposed) return;
    if (token == null || token.isEmpty) return;
    disconnect();
    _connected = true;

    // After 3–5 seconds, emit a mock event status update so the list/details refetch.
    final delay = Duration(seconds: 3 + (DateTime.now().second % 3));
    _statusUpdateTimer = Timer(delay, () {
      if (!_connected || _disposed) return;
      const eventId = 'event_1';
      const status = 'ongoing';
      mockEventStatusOverrides[eventId] = status;
      _eventStatusController.add({'eventId': eventId, 'status': status});
    });
  }

  @override
  void disconnect() {
    _connected = false;
    _statusUpdateTimer?.cancel();
    _statusUpdateTimer = null;
  }

  @override
  void joinChatRoom(String eventId) {}

  @override
  void leaveChatRoom(String eventId) {}

  @override
  void sendChatMessage(
    String eventId,
    String content, {
    void Function(dynamic)? ack,
  }) {
    if (!_connected || _disposed) return;

    final id = 'mock_${DateTime.now().millisecondsSinceEpoch}';
    final sentAt = DateTime.now().toIso8601String();

    ack?.call({'id': id, 'status': 'sent'});

    Future.microtask(() {
      if (_disposed) return;
      _chatMessageController.add({
        'id': id,
        'eventId': eventId,
        'senderId': 'current_user',
        'senderName': 'You',
        'content': content,
        'sentAt': sentAt,
      });
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!_connected || _disposed) return;
      _deliveryStatusController.add({
        'messageId': id,
        'status': 'delivered',
      });
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!_connected || _disposed) return;
      _deliveryStatusController.add({
        'messageId': id,
        'status': 'read',
      });
    });
  }

  @override
  void dispose() {
    _disposed = true;
    disconnect();
    _eventStatusController.close();
    _chatMessageController.close();
    _deliveryStatusController.close();
  }
}
