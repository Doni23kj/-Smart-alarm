import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_storage.dart';

class ProfileService {
  ProfileService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Сессия истекла. Войдите снова.');
    }
    return {'Authorization': 'Bearer $token'};
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.dio.get(
      '/api/profile/',
      options: Options(headers: await _authHeaders()),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateProfile({
    required String username,
    required String email,
    String? phone,
    String? avatar,
  }) async {
    final response = await _apiClient.dio.patch(
      '/api/profile/',
      data: {
        'username': username,
        'email': email,
        'phone': phone ?? '',
        'avatar': avatar ?? '',
      },
      options: Options(headers: await _authHeaders()),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
