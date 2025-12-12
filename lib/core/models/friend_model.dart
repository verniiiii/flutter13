enum FriendStatus {
  usingApp('Использует приложение'),
  invited('Приглашен'),
  notInvited('Не в приложении');

  const FriendStatus(this.displayName);
  final String displayName;
}

class Friend {
  final String id;
  String name;
  String? phoneNumber;
  String? email;
  String? photoUrl;
  FriendStatus status;
  DateTime? lastActive;
  double? totalBalance; // Для демонстрации - общий баланс друга
  int? commonGoals; // Общие цели (если будем делать)

  Friend({
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

  String get displayStatus {
    switch (status) {
      case FriendStatus.usingApp:
        return 'В приложении';
      case FriendStatus.invited:
        return 'Приглашен';
      case FriendStatus.notInvited:
        return 'Не в приложении';
    }
  }

  String get statusDisplayName => status.displayName;

  Friend copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? photoUrl,
    FriendStatus? status,
    DateTime? lastActive,
    double? totalBalance,
    int? commonGoals,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      lastActive: lastActive ?? this.lastActive,
      totalBalance: totalBalance ?? this.totalBalance,
      commonGoals: commonGoals ?? this.commonGoals,
    );
  }
}
