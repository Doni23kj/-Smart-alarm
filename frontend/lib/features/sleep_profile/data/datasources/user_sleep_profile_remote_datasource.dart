import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_sleep_profile_model.dart';

class UserSleepProfileRemoteDataSource {
  UserSleepProfileRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> syncProfile(UserSleepProfileModel profile) async {
    await _client.from('user_sleep_profiles').upsert(profile.toSupabaseMap());
  }
}
