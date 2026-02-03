# Auth Feature

## Responsibilities
- User login and logout (via mock REST APIs)
- Secure token handling (access + optional refresh token)
- Session persistence across app restarts

## Architecture (same pattern as Events)
- **Domain:** `User`, `AuthSession`, `AuthRepository`
- **Data:** `AuthRemoteDataSource` (mock login/logout), `AuthLocalDataSource` (secure storage), `AuthRepositoryImpl`
- **Presentation:** `AuthState`, `AuthNotifier`, `LoginScreen`

## Secure Token Handling
- Tokens and user info are stored with `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences on Android).
- Session is restored on app start via `AuthNotifier.build()` → `getStoredSession()`.
- Logout clears all stored auth data and calls mock logout API.

## Mock API
- **Login:** `POST /auth/login` (mock) — accepts `user@example.com` / `password123`.
- **Logout:** `POST /auth/logout` (mock) — invalidates token server-side (no-op in mock).

## Demo credentials
- Email: `user@example.com`
- Password: `password123`
