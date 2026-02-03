/// Central API configuration.
///
/// Set [baseUrl] to your backend (e.g. from env or build config).
class ApiConfig {
  static const String defaultBaseUrl = 'https://api.example.com/v1';

  /// Base URL for REST APIs (no trailing slash).
  final String baseUrl;

  static bool useMockApi = true;

  const ApiConfig({this.baseUrl = defaultBaseUrl});
}
