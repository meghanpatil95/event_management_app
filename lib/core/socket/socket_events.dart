/// Socket.IO event names and payload conventions.
///
/// Server is expected to:
/// - Emit [eventStatusUpdated] when an event's status changes.
/// - Emit [chatMessage] when a new message is sent in a room.
/// - Emit [chatDeliveryStatus] when a message's delivery status changes.
/// - Accept [chatJoin], [chatLeave], [chatSendMessage] from client.
library;

/// Live event: status updated (server -> client).
const String eventStatusUpdated = 'event:status_updated';

/// Chat: new message in room (server -> client).
const String chatMessage = 'chat:message';

/// Chat: delivery status update (server -> client).
const String chatDeliveryStatus = 'chat:delivery_status';

/// Chat: join event room (client -> server).
const String chatJoin = 'chat:join';

/// Chat: leave event room (client -> server).
const String chatLeave = 'chat:leave';

/// Chat: send message (client -> server). Server may reply with ack and/or broadcast via [chatMessage].
const String chatSendMessage = 'chat:send_message';
