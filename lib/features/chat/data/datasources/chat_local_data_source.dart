import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../dto/chat_message_dto.dart';

/// Hive box name for caching chat messages per event.
const String chatCacheBoxName = 'chat_cache';

/// Key prefix for storing messages per event. Full key: [_eventKeyPrefix][eventId].
const String _eventKeyPrefix = 'event_';

/// Local data source for persisting chat messages using Hive.
///
/// Stores messages as JSON per event for offline access and so sent messages persist.
abstract class ChatLocalDataSource {
  /// Returns cached messages for [eventId], or empty list if none.
  Future<List<ChatMessageDto>> getCachedMessages(String eventId);

  /// Replaces cached messages for [eventId] with [messages].
  Future<void> saveMessages(String eventId, List<ChatMessageDto> messages);

  /// Adds or updates a single message for [eventId] (by id).
  Future<void> addOrUpdateMessage(String eventId, ChatMessageDto message);
}

/// Hive-backed implementation of [ChatLocalDataSource].
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  Box<String> get _box => Hive.box<String>(chatCacheBoxName);

  static String _key(String eventId) => '$_eventKeyPrefix$eventId';

  @override
  Future<List<ChatMessageDto>> getCachedMessages(String eventId) async {
    final key = _key(eventId);
    final jsonStr = _box.get(key);
    if (jsonStr == null || jsonStr.isEmpty) {
      print('[ChatLocalDataSource] getCachedMessages($eventId): no data in Hive, key=$key');
      return [];
    }

    final list = jsonDecode(jsonStr) as List<dynamic>;
    final messages = list
        .map((e) => ChatMessageDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    print('[ChatLocalDataSource] getCachedMessages($eventId): read ${messages.length} message(s) from Hive. ids=${messages.map((m) => m.id).toList()}');
    return messages;
  }

  @override
  Future<void> saveMessages(String eventId, List<ChatMessageDto> messages) async {
    final key = _key(eventId);
    final list = messages.map((e) => e.toJson()).toList();
    await _box.put(key, jsonEncode(list));
    print('[ChatLocalDataSource] saveMessages($eventId): wrote ${messages.length} message(s) to Hive. ids=${messages.map((m) => m.id).toList()}');
  }

  @override
  Future<void> addOrUpdateMessage(String eventId, ChatMessageDto message) async {
    final messages = await getCachedMessages(eventId);
    final index = messages.indexWhere((m) => m.id == message.id);
    final updated = List<ChatMessageDto>.from(messages);
    if (index >= 0) {
      updated[index] = message;
      print('[ChatLocalDataSource] addOrUpdateMessage($eventId): updated message id=${message.id}');
    } else {
      updated.add(message);
      print('[ChatLocalDataSource] addOrUpdateMessage($eventId): added message id=${message.id}, content="${message.content}"');
    }
    await saveMessages(eventId, updated);
  }
}
