# Socket.IO Integration

The app uses **Socket.IO** for real-time event status updates and in-event group chat. The client connects with the same Bearer token used for REST APIs.

## Mock mode (no backend)

When `ApiConfig.useMockApi` is `true` (default for this assignment):

- **Socket**: [MockSocketService] is used. It does not connect to a server. After you log in, about **3–5 seconds** later it emits a mock `event:status_updated` for `event_1` with status `ongoing`, so the event list and event details refetch and you see the status chip change (e.g. from "Upcoming" to "Ongoing").
- **Chat**: [MockChatRemoteDataSource] provides mock chat history (a few sample messages) and accepts sends in memory. In the Group Chat screen, sending a message shows **Sending… → Sent → Delivered → Read** via the mock socket.
- No real network connection is required for Socket or chat.

## Configuration

- **Socket URL**: Set `ApiConfig.socketUrl` in `lib/core/config/api_config.dart`, or leave null to derive from `baseUrl` (scheme + host + port).
- **Transport**: WebSocket only (required for Flutter).

## Connection & Lifecycle

- The client connects when the user is authenticated and disconnects on logout.
- **App lifecycle**: When the app goes to background (paused/inactive), the socket disconnects; when the app resumes, it reconnects with the current token. This is handled by `SocketLifecycleHandler` in `lib/core/socket/socket_lifecycle.dart`.
- **Reconnection**: Socket.IO client options enable automatic reconnection. After reconnect, the client re-joins any chat rooms it had joined.

## Server Events (server → client)

### `event:status_updated`

Emitted when an event’s status changes.

**Payload (object):**

- `eventId` (string, required)
- `status` (string, e.g. `upcoming`, `ongoing`, `completed`, `cancelled`, `expired`)
- Any other event fields (optional)

### `chat:message`

Emitted when a new message is sent in an event’s chat room.

**Payload (object):**

- `id` (string)
- `eventId` (string)
- `senderId` (string)
- `senderName` (string)
- `content` (string)
- `sentAt` (string, ISO 8601)

### `chat:delivery_status`

Emitted when a message’s delivery status changes.

**Payload (object):**

- `messageId` (string)
- `status` (string: `sending`, `sent`, `delivered`, `read`)

## Client Events (client → server)

### `chat:join`

Join an event’s chat room. Argument: `eventId` (string).

### `chat:leave`

Leave an event’s chat room. Argument: `eventId` (string).

### `chat:send_message`

Send a message. Payload (object):

- `eventId` (string)
- `content` (string)

The server may acknowledge with an object containing e.g. `id` (message id) and `status` so the client can update the optimistic message.

## REST APIs Used Alongside Socket

- **Chat history**: `GET /chat/history?eventId=...&limit=50` — used to load past messages when opening the chat.
- **Optional send**: `POST /chat/send` with body `{ "eventId": "...", "content": "..." }` — app primarily sends via Socket; this can be used for persistence or fallback if your backend requires it.
