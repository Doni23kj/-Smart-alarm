import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../models/alarm_model.dart';

class AlarmRemoteDataSource {
  AlarmRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Сессия истекла. Войдите снова.');
    }

    return {'Authorization': 'Bearer $token'};
  }

  Future<List<AlarmModel>> getAlarms() async {
    final response = await _apiClient.dio.get(
      '/api/alarms/',
      options: Options(headers: await _authHeaders()),
    );

    final alarms = List<Map<String, dynamic>>.from(response.data as List);
    return alarms.map(AlarmModel.fromJson).toList();
  }

  Future<AlarmModel> createAlarm(AlarmModel alarm) async {
    final response = await _apiClient.dio.post(
      '/api/alarms/',
      data: alarm.toJson(),
      options: Options(headers: await _authHeaders()),
    );

    return AlarmModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<AlarmModel> updateAlarm(AlarmModel alarm) async {
    final response = await _apiClient.dio.put(
      '/api/alarms/${alarm.id}/',
      data: alarm.toJson(),
      options: Options(headers: await _authHeaders()),
    );

    return AlarmModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> deleteAlarm(int id) async {
    await _apiClient.dio.delete(
      '/api/alarms/$id/',
      options: Options(headers: await _authHeaders()),
    );
  }
}
