import '../entities/user_sleep_profile.dart';

abstract class UserSleepProfileRepository {
  Future<UserSleepProfile?> getCurrentProfile(String userId);
  Future<List<UserSleepProfile>> getProfiles();
  Future<void> saveProfile(UserSleepProfile profile);
  Future<void> syncProfile(UserSleepProfile profile);
}
