import 'dart:async';

import 'package:event_management_app/core/socket/socket_events.dart';
import 'package:event_management_app/core/socket/socket_provider.dart';
import 'package:event_management_app/features/auth/presentation/providers/providers.dart';
import 'package:event_management_app/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dto/chat_message_dto.dart';
import '../../domain/entities/chat_message.dart';
import 'chat_repository_provider.dart';

/// State for a single event's chat: messages list and loading/error.
class EventChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  const EventChatState({
    this.messages = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  EventChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return EventChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for one event's chat: loads history (REST), subscribes to Socket
/// for new messages and delivery status, sends via Socket.
class EventChatNotifier extends AutoDisposeNotifier<EventChatState> {
  StreamSubscription<Map<String, dynamic>>? _messageSub;
  StreamSubscription<Map<String, dynamic>>? _deliverySub;
  String? _currentEventId;

  @override
  EventChatState build() {
    ref.onDispose(() {
      _messageSub?.cancel();
      _deliverySub?.cancel();
      _leaveRoom();
    });
    return const EventChatState();
  }

  /// Call when entering an event's chat (e.g. open chat screen with [eventId]).
  Future<void> enterRoom(String eventId) async {
    if (_currentEventId == eventId) return;
    _leaveRoom();
    _currentEventId = eventId;
    state = state.copyWith(isLoading: true, errorMessage: null);

    final repo = ref.read(chatRepositoryProvider);
    final socket = ref.read(socketServiceProvider);

    // Load from Hive first so sent messages appear immediately
    try {
      final cached = await repo.getCachedChatHistory(eventId);
      print('[EventChatProvider] enterRoom($eventId): loaded ${cached.length} cached message(s) from Hive');
      if (cached.isNotEmpty) {
        state = state.copyWith(messages: cached);
      }
    } catch (e) {
      print('[EventChatProvider] enterRoom($eventId): getCachedChatHistory error: $e');
    }

    try {
      final history = await repo.getChatHistory(eventId);
      print('[EventChatProvider] enterRoom($eventId): got ${history.length} message(s) from remote, setting state');
      state = state.copyWith(messages: history, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      print('[EventChatProvider] enterRoom($eventId): getChatHistory error: $e');
    }

    socket?.joinChatRoom(eventId);

    _messageSub?.cancel();
    _messageSub = socket?.chatMessages.listen((map) {
      final msgEventId = map['eventId'] as String?;
      if (msgEventId != eventId) return;
      final dto = ChatMessageDto.fromJson(Map<String, dynamic>.from(map));
      final msg = dto.toDomain();
      _appendMessageIfNew(msg);
    });

    _deliverySub?.cancel();
    _deliverySub = socket?.chatDeliveryStatusUpdates.listen((map) {
      final messageId = map['messageId'] as String?;
      final statusStr = map['status'] as String?;
      if (messageId == null || statusStr == null) return;
      final status = _parseStatus(statusStr);
      if (status != null) _updateMessageStatus(messageId, status);
    });
  }

  void _leaveRoom() {
    if (_currentEventId != null) {
      ref.read(socketServiceProvider)?.leaveChatRoom(_currentEventId!);
      _currentEventId = null;
    }
  }

  static MessageDeliveryStatus? _parseStatus(String s) {
    switch (s.toLowerCase()) {
      case 'sending':
        return MessageDeliveryStatus.sending;
      case 'sent':
        return MessageDeliveryStatus.sent;
      case 'delivered':
        return MessageDeliveryStatus.delivered;
      case 'read':
        return MessageDeliveryStatus.read;
      default:
        return null;
    }
  }

  void _appendMessageIfNew(ChatMessage msg) {
    if (state.messages.any((m) => m.id == msg.id)) return;
    state = state.copyWith(messages: [...state.messages, msg]);
    // Persist to Hive so messages survive app restarts
    ref.read(chatRepositoryProvider).saveMessageToLocal(msg.eventId, msg);
    print('[EventChatProvider] _appendMessageIfNew: saved to Hive id=${msg.id} eventId=${msg.eventId}');
  }

  void _updateMessageStatus(String messageId, MessageDeliveryStatus status) {
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx < 0) return;
    final updated = state.messages[idx].copyWith(deliveryStatus: status);
    final list = List<ChatMessage>.from(state.messages)..[idx] = updated;
    state = state.copyWith(messages: list);
    final eventId = _currentEventId;
    if (eventId != null) {
      ref.read(chatRepositoryProvider).saveMessageToLocal(eventId, updated);
    }
  }

  /// Sends a message via Socket. Optimistically adds a local "sending" message
  /// then replaces with server message or updates status on ack.
  Future<void> sendMessage(String content) async {
    final eventId = _currentEventId;
    if (eventId == null || content.trim().isEmpty) return;

    final auth = ref.read(authProvider);
    final user = auth is AuthAuthenticated ? auth.session.user : null;
    if (user == null) return;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = ChatMessage(
      id: tempId,
      eventId: eventId,
      senderId: user.id,
      senderName: user.displayName.isNotEmpty ? user.displayName : user.email,
      content: content.trim(),
      sentAt: DateTime.now(),
      deliveryStatus: MessageDeliveryStatus.sending,
    );
    state = state.copyWith(messages: [...state.messages, optimistic]);
    ref.read(chatRepositoryProvider).saveMessageToLocal(eventId, optimistic);
    print('[EventChatProvider] sendMessage: saved optimistic to Hive tempId=$tempId eventId=$eventId');

    final socket = ref.read(socketServiceProvider);
    socket?.sendChatMessage(
      eventId,
      content.trim(),
      ack: (data) {
        final map = data is Map ? Map<String, dynamic>.from(data as Map) : null;
        if (map != null) {
          final id = map['id'] as String?;
          final status = map['status'] as String?;
          if (id != null) {
            final idx = state.messages.indexWhere((m) => m.id == tempId);
            if (idx >= 0) {
              final updated = state.messages[idx].copyWith(
                id: id,
                deliveryStatus: status != null
                    ? _parseStatus(status)
                    : MessageDeliveryStatus.sent,
              );
              final list = List<ChatMessage>.from(state.messages)
                ..[idx] = updated;
              state = state.copyWith(messages: list);
              ref.read(chatRepositoryProvider).saveMessageToLocal(eventId, updated);
              print('[EventChatProvider] sendMessage ack: saved to Hive with id=$id (was $tempId)');
            }
          }
        }
      },
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

/// Single notifier for the currently open event chat. Call [EventChatNotifier.enterRoom]
/// with the event ID when opening the chat screen.
final eventChatProvider =
    NotifierProvider.autoDispose<EventChatNotifier, EventChatState>(
      EventChatNotifier.new,
    );
