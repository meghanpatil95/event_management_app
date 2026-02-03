import '../../domain/entities/chat_message.dart';

/// DTO for chat message from REST API.
class ChatMessageDto {
  final String id;
  final String eventId;
  final String senderId;
  final String senderName;
  final String content;
  final String sentAt;

  const ChatMessageDto({
    required this.id,
    required this.eventId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String? ?? json['name'] as String? ?? '',
      content: json['content'] as String,
      sentAt: json['sentAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'sentAt': sentAt,
    };
  }

  /// DTO to domain model mapping.
  ChatMessage toDomain() {
    return ChatMessage(
      id: id,
      eventId: eventId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      sentAt: DateTime.parse(sentAt),
    );
  }
}
