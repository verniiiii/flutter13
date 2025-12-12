import '../entities/friend_entity.dart';

abstract class SocialRepository {
  Future<List<FriendEntity>> getFriends();
  Future<void> addFriend(FriendEntity friend);
  Future<void> removeFriend(String id);
  Future<void> inviteFriend(String email);
}

