import '../../repositories/social_repository.dart';
import '../../entities/friend_entity.dart';

class GetFriendsUseCase {
  final SocialRepository repository;

  GetFriendsUseCase(this.repository);

  Future<List<FriendEntity>> call() {
    return repository.getFriends();
  }
}

