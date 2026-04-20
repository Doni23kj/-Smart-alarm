import '../models/user_sleep_profile_model.dart';

class UserSleepProfileLocalDataSource {
  UserSleepProfileLocalDataSource([List<UserSleepProfileModel>? seed])
    : _profiles = seed ?? <UserSleepProfileModel>[];

  final List<UserSleepProfileModel> _profiles;

  Future<UserSleepProfileModel?> getCurrentProfile(String userId) async {
    final items =
        _profiles.where((profile) => profile.userId == userId).toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items.isEmpty ? null : items.first;
  }

  Future<List<UserSleepProfileModel>> getProfiles() async {
    return List<UserSleepProfileModel>.from(_profiles);
  }

  Future<void> saveProfile(UserSleepProfileModel profile) async {
    final index = _profiles.indexWhere(
      (item) => item.userId == profile.userId && item.id == profile.id,
    );

    if (index >= 0) {
      _profiles[index] = profile;
      return;
    }

    profile.id ??= DateTime.now().millisecondsSinceEpoch;
    _profiles.add(profile);
  }
}
