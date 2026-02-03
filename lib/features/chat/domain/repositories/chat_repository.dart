import '../entities/chat_message.dart';

/// Repository for chat history (REST API).
abstract class ChatRepository {
  /// Fetches chat history for an event.
  Future<List<ChatMessage>> getChatHistory(String eventId, {int limit = 50});
}
