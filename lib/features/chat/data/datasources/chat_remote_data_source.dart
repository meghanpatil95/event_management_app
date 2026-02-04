import 'dart:math';

import 'package:event_management_app/core/network/network.dart';

import '../dto/chat_message_dto.dart';

/// Remote data source for chat (REST API): history and optional send.
abstract class ChatRemoteDataSource {
  Future<List<ChatMessageDto>> getChatHistory(String eventId, {int limit = 50});
  Future<ChatMessageDto?> sendMessage(String eventId, String content);
}

/// REST implementation using centralized [ApiClient].
class ChatRestRemoteDataSource implements ChatRemoteDataSource {
  final ApiClient _client;

  ChatRestRemoteDataSource(this._client);

  @override
  Future<List<ChatMessageDto>> getChatHistory(String eventId, {int limit = 50}) async {
    final response = await _client.get(
      'chat/history',
      queryParameters: {'eventId': eventId, 'limit': '$limit'},
    );

    final list = response is List
        ? response
        : (response is Map && response['data'] is List)
            ? response['data'] as List
            : (response is Map && response['messages'] is List)
                ? response['messages'] as List
                : <dynamic>[];

    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => ChatMessageDto.fromJson(e))
        .toList();
  }

  @override
  Future<ChatMessageDto?> sendMessage(String eventId, String content) async {
    final response = await _client.post(
      'chat/send',
      body: {'eventId': eventId, 'content': content},
    );
    if (response == null) return null;
    final map = response is Map<String, dynamic>
        ? response
        : (response is Map ? Map<String, dynamic>.from(response as Map) : null);
    return map != null ? ChatMessageDto.fromJson(map) : null;
  }
}

/// Mock implementation: in-memory chat history and send for demo without backend.
class MockChatRemoteDataSource implements ChatRemoteDataSource {
  final Map<String, List<ChatMessageDto>> _messagesByEvent = {};
  final Random _random = Random();
  static const _mockNames = [
    'Alex',
    'Sam',
    'Jordan',
    'Casey',
    'Morgan',
    'Riley',
    'Taylor',
  ];

  @override
  Future<List<ChatMessageDto>> getChatHistory(String eventId, {int limit = 50}) async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));
    final list = _messagesByEvent[eventId] ?? _seedMockHistory(eventId);
    _messagesByEvent[eventId] = list;
    final end = list.length > limit ? list.length - limit : 0;
    return list.length > limit ? list.sublist(end) : List.from(list);
  }

  List<ChatMessageDto> _seedMockHistory(String eventId) {
    final now = DateTime.now();
    final messages = <ChatMessageDto>[
      ChatMessageDto(
        id: 'mock_msg_1',
        eventId: eventId,
        senderId: 'user_1',
        senderName: _mockNames[0],
        content: 'Is this event still happening?',
        sentAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
      ),
      ChatMessageDto(
        id: 'mock_msg_2',
        eventId: eventId,
        senderId: 'user_2',
        senderName: _mockNames[1],
        content: 'Yes! Looking forward to it.',
        sentAt: now.subtract(const Duration(hours: 1, minutes: 45)).toIso8601String(),
      ),
      ChatMessageDto(
        id: 'mock_msg_3',
        eventId: eventId,
        senderId: 'user_1',
        senderName: _mockNames[0],
        content: 'See you there.',
        sentAt: now.subtract(const Duration(minutes: 30)).toIso8601String(),
      ),
    ];
    return messages;
  }

  @override
  Future<ChatMessageDto?> sendMessage(String eventId, String content) async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(150)));
    final list = _messagesByEvent[eventId] ?? _seedMockHistory(eventId);
    _messagesByEvent[eventId] = list;
    final msg = ChatMessageDto(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      eventId: eventId,
      senderId: 'current_user',
      senderName: 'You',
      content: content,
      sentAt: DateTime.now().toIso8601String(),
    );
    list.add(msg);
    return msg;
  }
}
