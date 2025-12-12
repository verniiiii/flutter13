import 'package:flutter/foundation.dart';
import 'package:prac13/core/models/friend_model.dart';

class SocialStore with ChangeNotifier {
  List<Friend> _allContacts = [];
  List<Friend> _appUsers = [];
  List<Friend> _invitedContacts = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  bool _showOnlyAppUsers = true;

  List<Friend> get allContacts => List.unmodifiable(_allContacts);
  List<Friend> get appUsers => List.unmodifiable(_appUsers);
  List<Friend> get invitedContacts => List.unmodifiable(_invitedContacts);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get showOnlyAppUsers => _showOnlyAppUsers;
  bool get hasError => _errorMessage.isNotEmpty;

  List<Friend> get filteredContacts {
    final contacts = _showOnlyAppUsers ? _appUsers : _allContacts;

    if (_searchQuery.isEmpty) {
      return contacts.toList();
    }

    final query = _searchQuery.toLowerCase();
    return contacts.where((friend) => friend.name.toLowerCase().contains(query)).toList();
  }

  int get totalAppUsers => _appUsers.length;
  int get totalInvited => _invitedContacts.length;
  int get totalContacts => _allContacts.length;

  SocialStore() {
    _loadDemoData();
  }

  Future<void> _loadDemoData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Демо данные - контакты, которые используют приложение
      final demoAppUsers = [
        Friend(
          id: '1',
          name: 'Анна Петрова',
          phoneNumber: '+7 (912) 345-67-89',
          photoUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
          status: FriendStatus.usingApp,
          lastActive: DateTime.now().subtract(const Duration(hours: 2)),
          totalBalance: 154320.50,
          commonGoals: 3,
        ),
        Friend(
          id: '2',
          name: 'Михаил Сидоров',
          phoneNumber: '+7 (923) 456-78-90',
          photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
          status: FriendStatus.usingApp,
          lastActive: DateTime.now().subtract(const Duration(days: 1)),
          totalBalance: 89210.75,
          commonGoals: 1,
        ),
        Friend(
          id: '3',
          name: 'Елена Козлова',
          phoneNumber: '+7 (934) 567-89-01',
          photoUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
          status: FriendStatus.usingApp,
          lastActive: DateTime.now().subtract(const Duration(hours: 5)),
          totalBalance: 234560.20,
          commonGoals: 2,
        ),
      ];

      // Демо данные - все контакты
      final demoAllContacts = [
        ...demoAppUsers,
        Friend(
          id: '4',
          name: 'Дмитрий Иванов',
          phoneNumber: '+7 (945) 678-90-12',
          status: FriendStatus.invited,
        ),
        Friend(
          id: '5',
          name: 'Ольга Смирнова',
          phoneNumber: '+7 (956) 789-01-23',
          status: FriendStatus.notInvited,
        ),
        Friend(
          id: '6',
          name: 'Сергей Кузнецов',
          phoneNumber: '+7 (967) 890-12-34',
          status: FriendStatus.notInvited,
        ),
        Friend(
          id: '7',
          name: 'Наталья Морозова',
          phoneNumber: '+7 (978) 901-23-45',
          status: FriendStatus.usingApp,
          lastActive: DateTime.now().subtract(const Duration(days: 3)),
          totalBalance: 56780.30,
          commonGoals: 0,
        ),
      ];

      // Приглашенные контакты
      final demoInvitedContacts = demoAllContacts.where((friend) =>
      friend.status == FriendStatus.invited).toList();

      // Устанавливаем данные
      _allContacts = List.from(demoAllContacts);
      _appUsers = List.from(demoAppUsers);
      _invitedContacts = List.from(demoInvitedContacts);

    } catch (e) {
      _errorMessage = 'Ошибка загрузки контактов';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> inviteFriend(Friend friend) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      final index = _allContacts.indexWhere((f) => f.id == friend.id);
      if (index != -1) {
        final updatedFriend = friend.copyWith(status: FriendStatus.invited);
        _allContacts[index] = updatedFriend;

        // Обновляем списки
        _updateFilteredLists();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Ошибка при отправке приглашения';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncContacts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 3));
      // В реальном приложении здесь будет синхронизация с контактами телефона
    } catch (e) {
      _errorMessage = 'Ошибка синхронизации контактов';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleShowOnlyAppUsers() {
    _showOnlyAppUsers = !_showOnlyAppUsers;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void _updateFilteredLists() {
    final usingAppContacts = _allContacts.where((friend) =>
    friend.status == FriendStatus.usingApp).toList();
    final invitedContactsList = _allContacts.where((friend) =>
    friend.status == FriendStatus.invited).toList();

    _appUsers = List.from(usingAppContacts);
    _invitedContacts = List.from(invitedContactsList);
  }

  // Дополнительные методы для управления контактами

  void addContact(Friend friend) {
    if (!_allContacts.any((f) => f.id == friend.id)) {
      _allContacts.add(friend);

      // Обновляем фильтрованные списки в зависимости от статуса
      if (friend.status == FriendStatus.usingApp) {
        _appUsers.add(friend);
      } else if (friend.status == FriendStatus.invited) {
        _invitedContacts.add(friend);
      }

      notifyListeners();
    }
  }

  void removeContact(String id) {
    _allContacts.removeWhere((friend) => friend.id == id);
    _appUsers.removeWhere((friend) => friend.id == id);
    _invitedContacts.removeWhere((friend) => friend.id == id);
    notifyListeners();
  }

  void updateContact(Friend friend) {
    final index = _allContacts.indexWhere((f) => f.id == friend.id);
    if (index != -1) {
      _allContacts[index] = friend;

      // Обновляем в appUsers если нужно
      final appUserIndex = _appUsers.indexWhere((f) => f.id == friend.id);
      if (appUserIndex != -1) {
        if (friend.status == FriendStatus.usingApp) {
          _appUsers[appUserIndex] = friend;
        } else {
          _appUsers.removeAt(appUserIndex);
        }
      } else if (friend.status == FriendStatus.usingApp) {
        _appUsers.add(friend);
      }

      // Обновляем в invitedContacts если нужно
      final invitedIndex = _invitedContacts.indexWhere((f) => f.id == friend.id);
      if (invitedIndex != -1) {
        if (friend.status == FriendStatus.invited) {
          _invitedContacts[invitedIndex] = friend;
        } else {
          _invitedContacts.removeAt(invitedIndex);
        }
      } else if (friend.status == FriendStatus.invited) {
        _invitedContacts.add(friend);
      }

      notifyListeners();
    }
  }

  Friend? getContactById(String id) {
    try {
      return _allContacts.firstWhere((friend) => friend.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Friend> getContactsByStatus(FriendStatus status) {
    return _allContacts.where((friend) => friend.status == status).toList();
  }

  int getContactsCountByStatus(FriendStatus status) {
    return _allContacts.where((friend) => friend.status == status).length;
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void acceptInvitation(String contactId) {
    final contact = getContactById(contactId);
    if (contact != null) {
      updateContact(contact.copyWith(status: FriendStatus.usingApp));
    }
  }

  void cancelInvitation(String contactId) {
    final contact = getContactById(contactId);
    if (contact != null) {
      updateContact(contact.copyWith(status: FriendStatus.notInvited));
    }
  }

  // Получить друзей с общими целями
  List<Friend> getFriendsWithCommonGoals() {
    return _appUsers.where((friend) => (friend.commonGoals ?? 0) > 0).toList();
  }

  // Получить друзей с балансом больше указанного
  List<Friend> getFriendsWithBalanceGreaterThan(double minBalance) {
    return _appUsers.where((friend) =>
    (friend.totalBalance ?? 0) > minBalance).toList();
  }

  // Сортировка контактов
  void sortContactsByName({bool ascending = true}) {
    _allContacts.sort((a, b) {
      if (ascending) {
        return a.name.compareTo(b.name);
      } else {
        return b.name.compareTo(a.name);
      }
    });
    _updateFilteredLists();
    notifyListeners();
  }

  void sortContactsByLastActive({bool ascending = true}) {
    _appUsers.sort((a, b) {
      if (a.lastActive == null && b.lastActive == null) return 0;
      if (a.lastActive == null) return ascending ? 1 : -1;
      if (b.lastActive == null) return ascending ? -1 : 1;

      if (ascending) {
        return a.lastActive!.compareTo(b.lastActive!);
      } else {
        return b.lastActive!.compareTo(a.lastActive!);
      }
    });
    notifyListeners();
  }
}