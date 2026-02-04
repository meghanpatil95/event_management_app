import '../entities/chat_message.dart';

/// Repository for chat: history via REST, optional send via REST, local cache via Hive.
abstract class ChatRepository {
  /// Fetches chat history for an event (from remote and persists to local).
  Future<List<ChatMessage>> getChatHistory(String eventId, {int limit = 50});

  /// Returns cached messages for an event from local storage (Hive).
  Future<List<ChatMessage>> getCachedChatHistory(String eventId);

  /// Persists a single message to local storage (e.g. after send or socket receive).
  Future<void> saveMessageToLocal(String eventId, ChatMessage message);

  /// Sends a message (REST). Real-time send is done via Socket in the app.
  Future<ChatMessage?> sendMessage(String eventId, String content);
}
