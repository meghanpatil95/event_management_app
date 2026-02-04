/// Delivery status for chat messages (for UI display).
enum MessageDeliveryStatus {
  sending,
  sent,
  delivered,
  read,
}

/// Chat message entity in the domain layer.
class ChatMessage {
  final String id;
  final String eventId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final MessageDeliveryStatus? deliveryStatus;

  const ChatMessage({
    required this.id,
    required this.eventId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    this.deliveryStatus,
  });

  ChatMessage copyWith({
    String? id,
    String? eventId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? sentAt,
    MessageDeliveryStatus? deliveryStatus,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
}
