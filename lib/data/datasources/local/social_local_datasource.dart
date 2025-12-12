import 'package:mobx/mobx.dart';
import 'package:prac13/core/models/friend_model.dart';

class SocialLocalDataSource {
  final ObservableList<Friend> _friends = ObservableList<Friend>();

  Future<List<Friend>> getFriends() async {
    return _friends.toList();
  }

  Future<void> addFriend(Friend friend) async {
    _friends.add(friend);
  }

  Future<void> removeFriend(String id) async {
    _friends.removeWhere((f) => f.id == id);
  }

  Future<void> initializeMockData() async {
    _friends.addAll([
      Friend(
        id: '1',
        name: 'Анна Петрова',
        phoneNumber: '+7 (912) 345-67-89',
        status: FriendStatus.usingApp,
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Friend(
        id: '2',
        name: 'Михаил Сидоров',
        phoneNumber: '+7 (923) 456-78-90',
        status: FriendStatus.usingApp,
        lastActive: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }
}

