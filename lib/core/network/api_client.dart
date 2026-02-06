import 'package:dio/dio.dart';

import 'api_exceptions.dart';

/// Centralized REST API client with error handling.
///
/// Uses Dio for HTTP. All feature data sources should use this client.
/// Handles timeouts, status codes, and maps errors to [ApiException] subtypes.
class ApiClient {
  late final Dio _dio;
  final String baseUrl;
  final Duration timeout;
  String? _accessToken;

  /// [baseUrl] - Base URL without trailing slash (e.g. https://api.example.com/v1).
  /// [timeout] - Request timeout. Default 30 seconds.
  ApiClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    Map<String, String>? defaultHeaders,
  }) {
    final url = baseUrl.endsWith('/') ? baseUrl : baseUrl;
    _dio = Dio(BaseOptions(
      baseUrl: url,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: defaultHeaders ?? {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null && _accessToken!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        _mapDioError(error);
      },
    ));
  }

  /// Sets the Bearer token for authenticated requests.
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  /// Performs GET and returns decoded JSON or throws [ApiException].
  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final response = await _dio.get<dynamic>(
      path.startsWith('/') ? path : '/$path',
      queryParameters: queryParameters,
    );
    return response.data;
  }

  /// Performs POST with optional [body] and returns decoded JSON or throws [ApiException].
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    final response = await _dio.post<dynamic>(
      path.startsWith('/') ? path : '/$path',
      data: body,
      queryParameters: queryParameters,
    );
    return response.data;
  }

  /// Performs PUT with optional [body] and returns decoded JSON or throws [ApiException].
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    final response = await _dio.put<dynamic>(
      path.startsWith('/') ? path : '/$path',
      data: body,
      queryParameters: queryParameters,
    );
    return response.data;
  }

  /// Performs DELETE and returns decoded JSON or throws [ApiException].
  Future<dynamic> delete(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final response = await _dio.delete<dynamic>(
      path.startsWith('/') ? path : '/$path',
      queryParameters: queryParameters,
    );
    return response.data;
  }

  Never _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      throw NetworkException(
        'Request timeout',
        body: error.response?.data,
      );
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      throw NetworkException(
        error.message ?? 'Network error',
        body: error.response?.data,
      );
    }

    final statusCode = error.response?.statusCode ?? 0;
    final data = error.response?.data;
    final message = _errorMessageFromBody(data) ?? _defaultMessageForStatus(statusCode);

    switch (statusCode) {
      case 400:
        throw BadRequestException(message, statusCode: statusCode, body: data);
      case 401:
        throw UnauthorizedException(message, statusCode: statusCode, body: data);
      case 403:
        throw ForbiddenException(message, statusCode: statusCode, body: data);
      case 404:
        throw NotFoundException(message, statusCode: statusCode, body: data);
      default:
        if (statusCode >= 500) {
          throw ServerException(message, statusCode: statusCode, body: data);
        }
        throw ApiException;
    }
  }

  String? _errorMessageFromBody(dynamic decoded) {
    if (decoded is Map) {
      return (decoded['message'] ?? decoded['error'] ?? decoded['msg']) as String?;
    }
    return null;
  }

  String _defaultMessageForStatus(int status) {
    switch (status) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 500:
        return 'Internal server error';
      default:
        return status > 0 ? 'Request failed with status $status' : 'Network error';
    }
  }
}
