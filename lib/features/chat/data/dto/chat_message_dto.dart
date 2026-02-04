import '../../domain/entities/chat_message.dart';

/// DTO for chat message from REST API or Socket.IO.
class ChatMessageDto {
  final String id;
  final String eventId;
  final String senderId;
  final String senderName;
  final String content;
  final String sentAt;
  final String? deliveryStatus;

  const ChatMessageDto({
    required this.id,
    required this.eventId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    this.deliveryStatus,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? json['name'] as String? ?? '',
      content: json['content'] as String? ?? '',
      sentAt: json['sentAt'] as String? ?? DateTime.now().toIso8601String(),
      deliveryStatus: json['deliveryStatus'] as String?,
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
      if (deliveryStatus != null) 'deliveryStatus': deliveryStatus,
    };
  }

  static MessageDeliveryStatus? _parseDeliveryStatus(String? s) {
    if (s == null) return null;
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

  /// DTO to domain model mapping.
  ChatMessage toDomain() {
    return ChatMessage(
      id: id,
      eventId: eventId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      sentAt: DateTime.tryParse(sentAt) ?? DateTime.now(),
      deliveryStatus: _parseDeliveryStatus(deliveryStatus),
    );
  }

  /// Create DTO from domain (e.g. for local persistence).
  static ChatMessageDto fromDomain(ChatMessage m) {
    return ChatMessageDto(
      id: m.id,
      eventId: m.eventId,
      senderId: m.senderId,
      senderName: m.senderName,
      content: m.content,
      sentAt: m.sentAt.toIso8601String(),
      deliveryStatus: m.deliveryStatus?.name,
    );
  }
}
