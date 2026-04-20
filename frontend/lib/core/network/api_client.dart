import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/auth_storage.dart';

class ApiClient {
  ApiClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode != 401) {
            return handler.next(error);
          }

          final requestOptions = error.requestOptions;
          final alreadyRetried = requestOptions.extra['retried'] == true;
          if (alreadyRetried) {
            return handler.next(error);
          }

          final refreshed = await _refreshAccessToken();
          if (!refreshed) {
            return handler.next(error);
          }

          final token = await AuthStorage.getToken();
          if (token == null || token.isEmpty) {
            return handler.next(error);
          }

          requestOptions.extra['retried'] = true;
          requestOptions.headers['Authorization'] = 'Bearer $token';

          try {
            final response = await dio.fetch(requestOptions);
            return handler.resolve(response);
          } on DioException catch (retryError) {
            return handler.next(retryError);
          }
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio dio;

  Future<bool> _refreshAccessToken() async {
    final refreshToken = await AuthStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await refreshDio.post(
        '/api/token/refresh/',
        data: {'refresh': refreshToken},
      );

      final accessToken = response.data['access'] as String?;
      if (accessToken == null || accessToken.isEmpty) return false;

      final user = await AuthStorage.getUser();
      await AuthStorage.saveSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
      return true;
    } catch (_) {
      await AuthStorage.clear();
      return false;
    }
  }

  String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      default:
        return 'http://127.0.0.1:8000';
    }
  }
}
