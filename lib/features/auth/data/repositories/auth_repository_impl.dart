import '../../domain/domain.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implementation of [AuthRepository].
///
/// Uses remote data source for login/logout and local (secure) storage
/// for token handling and session persistence.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<AuthSession> login(String email, String password) async {
    try {
      final response = await _remote.login(email, password);
      final session = response.toDomain();
      await _local.saveSession(session);
      return session;
    } on InvalidCredentialsException catch (e) {
      throw Exception(e.message);
    } on AuthNetworkException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<void> logout() async {
    final session = await _local.getStoredSession();
    if (session != null) {
      try {
        await _remote.logout(session.accessToken);
      } catch (_) {
        // Best-effort: clear local session even if server logout fails
      }
    }
    await _local.clearSession();
  }

  @override
  Future<AuthSession?> getStoredSession() async {
    return _local.getStoredSession();
  }
}
