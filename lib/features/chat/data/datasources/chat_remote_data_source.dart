import 'package:event_management_app/core/network/network.dart';

import '../dto/chat_message_dto.dart';

/// Remote data source for chat history (REST API).
abstract class ChatRemoteDataSource {
  Future<List<ChatMessageDto>> getChatHistory(String eventId, {int limit = 50});
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
}
