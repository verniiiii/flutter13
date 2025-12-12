import 'package:prac13/core/models/friend_model.dart';

class FriendEntity {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final String? photoUrl;
  final FriendStatus status;
  final DateTime? lastActive;
  final double? totalBalance;
  final int? commonGoals;

  FriendEntity({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    this.photoUrl,
    required this.status,
    this.lastActive,
    this.totalBalance,
    this.commonGoals,
  });
}

