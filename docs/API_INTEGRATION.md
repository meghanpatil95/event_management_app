# API Integration

This app uses **REST APIs** for authentication, events, registrations, and chat history, with a **centralized API client** (Dio) and **DTO-to-domain mapping**.

## Centralized API Client

- **Library:** Dio
- **Location:** `lib/core/network/api_client.dart`
- **Provider:** `lib/core/network/api_client_provider.dart`
- **Config:** `lib/core/config/api_config.dart` — set `baseUrl` (default `https://api.example.com/v1`).

**Behavior:**

- Single shared `ApiClient` for all features (auth, events, chat).
- Automatic `Authorization: Bearer <token>` after login; token cleared on logout.
- Timeout (default 30s), JSON headers, and error handling that maps HTTP status to exceptions.

**Error handling:** `lib/core/network/api_exceptions.dart`

- `BadRequestException` (400), `UnauthorizedException` (401), `ForbiddenException` (403), `NotFoundException` (404), `ServerException` (5xx), `NetworkException` (timeout/connectivity).

## REST APIs and DTO Mapping

### Authentication

- **Login:** `POST /auth/login`  
  Body: `{ "email": string, "password": string }`  
  Response: `{ "user": {...}, "accessToken": string, "refreshToken"?: string, "expiresAt"?: string }`  
  DTO: `AuthResponseDto` → domain: `AuthSession` (in repository).

- **Logout:** `POST /auth/logout`  
  Headers: `Authorization: Bearer <token>`  
  No body required.

### Events

- **List:** `GET /events?page=1&pageSize=20`  
  Response: JSON array of events, or `{ "data": [...] }` / `{ "events": [...] }`.  
  DTO: `EventDto.fromJson()` → repository maps to domain `Event` via `EventDto.toDomain()`.

- **Details:** `GET /events/:id`  
  DTO → domain in `EventRepositoryImpl`.

- **Register:** `POST /events/:id/register`  
  Returns updated event JSON.  
  DTO → domain in repository.

- **Unregister:** `DELETE /events/:id/register` (or `POST /events/:id/unregister` if your backend uses that).  
  Returns updated event or 204 (app refetches event if needed).  
  DTO → domain in repository.

### Chat history

- **History:** `GET /chat/history?eventId=...&limit=50`  
  Response: array of messages or `{ "data": [...] }` / `{ "messages": [...] }`.  
  DTO: `ChatMessageDto.fromJson()` → `ChatMessageDto.toDomain()` in `ChatRepositoryImpl`.

## DTO to domain mapping

- **Auth:** `AuthResponseDto.fromJson()` → `AuthResponseDto.toDomain()` → `AuthSession` (in `AuthRepositoryImpl`).
- **User:** `UserDto.fromJson()` → `UserDto.toDomain()` → `User`.
- **Event:** `EventDto.fromJson()` → `EventDto.toDomain()` → `Event` (in `EventRepositoryImpl`).
- **Chat:** `ChatMessageDto.fromJson()` → `ChatMessageDto.toDomain()` → `ChatMessage` (in `ChatRepositoryImpl`).

## Switching to your backend

1. Set `ApiConfig.baseUrl` (e.g. in `api_config.dart` or via `apiConfigProvider`) to your base URL.
2. Ensure your API matches the paths and JSON shapes above (or adjust paths/parsing in the REST data sources).
3. Run the app; login will store the token and set it on the shared client for events and chat.
