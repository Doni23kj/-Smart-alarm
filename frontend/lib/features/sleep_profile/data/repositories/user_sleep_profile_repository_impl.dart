import '../../domain/entities/user_sleep_profile.dart';
import '../../domain/repositories/user_sleep_profile_repository.dart';
import '../datasources/user_sleep_profile_local_datasource.dart';
import '../datasources/user_sleep_profile_remote_datasource.dart';
import '../models/user_sleep_profile_model.dart';

class UserSleepProfileRepositoryImpl implements UserSleepProfileRepository {
  UserSleepProfileRepositoryImpl({
    required UserSleepProfileLocalDataSource localDataSource,
    required UserSleepProfileRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  final UserSleepProfileLocalDataSource _localDataSource;
  final UserSleepProfileRemoteDataSource _remoteDataSource;

  @override
  Future<UserSleepProfile?> getCurrentProfile(String userId) async {
    final model = await _localDataSource.getCurrentProfile(userId);
    return model?.toEntity();
  }

  @override
  Future<List<UserSleepProfile>> getProfiles() async {
    final models = await _localDataSource.getProfiles();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveProfile(UserSleepProfile profile) async {
    await _localDataSource.saveProfile(
      UserSleepProfileModel.fromEntity(profile),
    );
  }

  @override
  Future<void> syncProfile(UserSleepProfile profile) async {
    await _remoteDataSource.syncProfile(
      UserSleepProfileModel.fromEntity(profile),
    );
  }
}
