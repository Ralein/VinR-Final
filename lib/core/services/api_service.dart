import 'package:dio/dio.dart';
import 'storage_service.dart';

/// HTTP API Client for optional remote connectivity.
///
/// Designed to gracefully handle offline/standalone environments
/// where no remote backend is active.
class ApiService {
  static String get defaultBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl.endsWith('/') ? envUrl : '$envUrl/';
    return 'https://api.vinr.app/api/v1/';
  }

  static bool get isCustomConfigured {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    return envUrl.isNotEmpty;
  }

  late final Dio dio;

  ApiService([String? customBaseUrl]) {
    final baseUrl = customBaseUrl ?? defaultBaseUrl;
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await StorageService.deleteToken();
          }
          return handler.next(error);
        },
      ),
    );
  }
}
