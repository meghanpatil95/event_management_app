import '../../domain/domain.dart';
import '../datasources/chat_remote_data_source.dart';

/// Implementation of [ChatRepository] with DTO to domain mapping.
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remote;

  ChatRepositoryImpl(this._remote);

  @override
  Future<List<ChatMessage>> getChatHistory(String eventId, {int limit = 50}) async {
    final dtos = await _remote.getChatHistory(eventId, limit: limit);
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
