# Flutter Assignment – Task Breakdown

## Core Objectives
- Demonstrate clean architecture
- Use scalable state management (Riverpod)
- Integrate mock REST APIs
- Simulate real-time updates (Socket.IO)
- Maintain production-quality code

---

## Functional Tasks

### 1. User Authentication
- Mock login/logout
- Token persistence
- Session restoration

### 2. Event Discovery
- Paginated event list
- Event details screen
- Loading & error states

### 3. Event Registration
- Register / unregister
- Registration status UI
- Edge cases (expired / duplicate)

### 4. Live Event Updates
- Real-time status updates
- Socket lifecycle handling

### 5. Group Chat
- Load chat history (REST)
- Live messages (Socket)
- Message delivery status

### 6. Notifications
- Event reminders
- Foreground / background handling

### 7. Maps Integration
- Display event location (Google Maps SDK)
- Marker support  
- **Implementation:** `lib/features/maps/` — see [MAPS.md](../lib/features/maps/MAPS.md)

---

## Non-Functional Tasks
- Clean Architecture (Presentation / Domain / Data)
- Riverpod state management
- Local caching (Hive)
- Error handling & performance
- Documentation
