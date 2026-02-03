/// Chat message entity in the domain layer.
class ChatMessage {
  final String id;
  final String eventId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.eventId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
  });
}
