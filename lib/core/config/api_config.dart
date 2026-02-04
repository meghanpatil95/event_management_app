/// Central API configuration.
///
/// Set [baseUrl] to your backend (e.g. from env or build config).
class ApiConfig {
  static const String defaultBaseUrl = 'https://api.example.com/v1';
  static const String defaultSocketUrl = 'https://api.example.com';

  /// Base URL for REST APIs (no trailing slash).
  final String baseUrl;

  /// Base URL for Socket.IO server (no path; e.g. https://api.example.com).
  /// If null, derived from [baseUrl] by stripping /v1 or similar path.
  final String? socketUrl;

  static bool useMockApi = true;

  const ApiConfig({this.baseUrl = defaultBaseUrl, this.socketUrl});

  /// Effective Socket.IO URL (explicit [socketUrl] or derived from [baseUrl]).
  String get effectiveSocketUrl {
    if (socketUrl != null && socketUrl!.isNotEmpty) return socketUrl!;
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
  }
}
