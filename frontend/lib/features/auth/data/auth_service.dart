import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_storage.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Dio get _dio => ApiClient.instance.dio;

  Future<void> register({
    required String username,
    required String email,
    String? phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      await _dio.post(
        '/api/register/',
        data: {
          'username': username,
          'email': email,
          'phone': phone,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      final tokenResponse = await _dio.post(
        '/api/token/',
        data: {'username': email, 'password': password},
      );

      final accessToken = tokenResponse.data['access'] as String;
      final refreshToken = tokenResponse.data['refresh'] as String?;
      final user = Map<String, dynamic>.from(
        (tokenResponse.data['user'] as Map?) ??
            {'username': username, 'email': email},
      );

      await AuthStorage.saveSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  Future<void> login({required String login, required String password}) async {
    try {
      final tokenResponse = await _dio.post(
        '/api/token/',
        data: {'username': login, 'password': password},
      );

      final accessToken = tokenResponse.data['access'] as String;
      final refreshToken = tokenResponse.data['refresh'] as String?;
      Map<String, dynamic>? user = Map<String, dynamic>.from(
        (tokenResponse.data['user'] as Map?) ?? {'username': login},
      );

      await AuthStorage.saveSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  String _extractMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      for (final value in data.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    if (error.type == DioExceptionType.connectionError) {
      final host = defaultTargetPlatform == TargetPlatform.android
          ? '10.0.2.2:8000'
          : '127.0.0.1:8000';
      return 'Сервер недоступен. Запустите backend на `$host`.';
    }

    return 'Произошла ошибка. Проверьте введённые данные.';
  }
}
