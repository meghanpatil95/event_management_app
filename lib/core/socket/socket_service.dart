import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'socket_events.dart';

/// Contract for live event updates and group chat over Socket.IO.
/// Implemented by [RealSocketService] (real server) and [MockSocketService] (demo).
abstract class SocketService {
  String get socketUrl;
  Stream<Map<String, dynamic>> get eventStatusUpdates;
  Stream<Map<String, dynamic>> get chatMessages;
  Stream<Map<String, dynamic>> get chatDeliveryStatusUpdates;
  bool get isConnected;
  void connect(String? token);
  void disconnect();
  void joinChatRoom(String eventId);
  void leaveChatRoom(String eventId);
  void sendChatMessage(String eventId, String content, {void Function(dynamic)? ack});
  void dispose();
}

/// Real Socket.IO connection for live event updates and group chat.
class RealSocketService extends SocketService {
  RealSocketService({required this.socketUrl});

  @override
  final String socketUrl;
  IO.Socket? _socket;
  String? _token;
  final Set<String> _joinedRooms = {};
  bool _disposed = false;

  final StreamController<Map<String, dynamic>> _eventStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _chatMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _deliveryStatusController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get eventStatusUpdates =>
      _eventStatusController.stream;

  @override
  Stream<Map<String, dynamic>> get chatMessages => _chatMessageController.stream;

  @override
  Stream<Map<String, dynamic>> get chatDeliveryStatusUpdates =>
      _deliveryStatusController.stream;

  @override
  bool get isConnected => _socket?.connected ?? false;

  @override
  void connect(String? token) {
    if (_disposed) return;
    disconnect();
    _token = token;
    if (token == null || token.isEmpty) return;

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket!
      ..onConnect((_) => _onConnect())
      ..onDisconnect((_) {})
      ..onConnectError((data) => _onError('connect_error', data))
      ..on(eventStatusUpdated, _onEventStatusUpdated)
      ..on(chatMessage, _onChatMessage)
      ..on(chatDeliveryStatus, _onChatDeliveryStatus);
  }

  void _onConnect() {
    for (final room in _joinedRooms.toList()) {
      _socket?.emit(chatJoin, room);
    }
  }

  void _onError(String event, dynamic data) {
    if (_disposed) return;
    // Could add an error stream if needed.
  }

  void _onEventStatusUpdated(dynamic data) {
    if (_disposed) return;
    final map = _toMap(data);
    if (map != null) _eventStatusController.add(map);
  }

  void _onChatMessage(dynamic data) {
    if (_disposed) return;
    final map = _toMap(data);
    if (map != null) _chatMessageController.add(map);
  }

  void _onChatDeliveryStatus(dynamic data) {
    if (_disposed) return;
    final map = _toMap(data);
    if (map != null) _deliveryStatusController.add(map);
  }

  static Map<String, dynamic>? _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data as Map);
    return null;
  }

  @override
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  @override
  void joinChatRoom(String eventId) {
    _joinedRooms.add(eventId);
    _socket?.emit(chatJoin, eventId);
  }

  @override
  void leaveChatRoom(String eventId) {
    _joinedRooms.remove(eventId);
    _socket?.emit(chatLeave, eventId);
  }

  @override
  void sendChatMessage(
    String eventId,
    String content, {
    void Function(dynamic)? ack,
  }) {
    final payload = {'eventId': eventId, 'content': content};
    if (ack != null) {
      _socket?.emitWithAck(chatSendMessage, payload, ack: ack);
    } else {
      _socket?.emit(chatSendMessage, payload);
    }
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
