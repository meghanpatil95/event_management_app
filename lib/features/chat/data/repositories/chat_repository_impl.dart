import '../../domain/domain.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../dto/chat_message_dto.dart';

/// Implementation of [ChatRepository] with DTO to domain mapping and Hive persistence.
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remote;
  final ChatLocalDataSource _local;

  ChatRepositoryImpl(this._remote, this._local);

  @override
  Future<List<ChatMessage>> getChatHistory(String eventId, {int limit = 50}) async {
    final remoteDtos = await _remote.getChatHistory(eventId, limit: limit);
    final cachedDtos = await _local.getCachedMessages(eventId);
    final remoteIds = remoteDtos.map((d) => d.id).toSet();
    // Keep cached messages that are not in remote (e.g. just sent, not yet on server)
    final localOnly = cachedDtos.where((c) => !remoteIds.contains(c.id)).toList();
    final merged = [...remoteDtos];
    for (final dto in localOnly) {
      merged.add(dto);
    }
    merged.sort((a, b) {
      final at = DateTime.tryParse(a.sentAt) ?? DateTime(0);
      final bt = DateTime.tryParse(b.sentAt) ?? DateTime(0);
      return at.compareTo(bt);
    });
    print('[ChatRepositoryImpl] getChatHistory($eventId): remote=${remoteDtos.length}, cached=${cachedDtos.length}, localOnly=${localOnly.length}, merged=${merged.length}');
    await _local.saveMessages(eventId, merged);
    return merged.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<List<ChatMessage>> getCachedChatHistory(String eventId) async {
    final dtos = await _local.getCachedMessages(eventId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<void> saveMessageToLocal(String eventId, ChatMessage message) async {
    print('[ChatRepositoryImpl] saveMessageToLocal eventId=$eventId id=${message.id}');
    await _local.addOrUpdateMessage(eventId, ChatMessageDto.fromDomain(message));
  }

  @override
  Future<ChatMessage?> sendMessage(String eventId, String content) async {
    final dto = await _remote.sendMessage(eventId, content);
    return dto?.toDomain();
  }
}
