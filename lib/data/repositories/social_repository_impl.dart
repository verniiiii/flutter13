import '../../domain/repositories/social_repository.dart';
import '../../domain/entities/friend_entity.dart';
import '../datasources/local/social_local_datasource.dart';
import '../../core/models/friend_model.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SocialLocalDataSource localDataSource;

  SocialRepositoryImpl(this.localDataSource);

  FriendEntity _modelToEntity(Friend model) {
    return FriendEntity(
      id: model.id,
      name: model.name,
      phoneNumber: model.phoneNumber,
      email: model.email,
      photoUrl: model.photoUrl,
      status: model.status,
      lastActive: model.lastActive,
      totalBalance: model.totalBalance,
      commonGoals: model.commonGoals,
    );
  }

  Friend _entityToModel(FriendEntity entity) {
    return Friend(
      id: entity.id,
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      email: entity.email,
      photoUrl: entity.photoUrl,
      status: entity.status,
      lastActive: entity.lastActive,
      totalBalance: entity.totalBalance,
      commonGoals: entity.commonGoals,
    );
  }

  @override
  Future<List<FriendEntity>> getFriends() async {
    final models = await localDataSource.getFriends();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<void> addFriend(FriendEntity friend) async {
    await localDataSource.addFriend(_entityToModel(friend));
  }

  @override
  Future<void> removeFriend(String id) async {
    await localDataSource.removeFriend(id);
  }

  @override
  Future<void> inviteFriend(String email) async {
    // Implementation for inviting friend
  }
}

