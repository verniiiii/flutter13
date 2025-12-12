import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/ui/features/social/state/social_store.dart';
import 'package:prac13/core/models/friend_model.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<SocialStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Друзья в приложении'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: store.isLoading ? null : store.syncContacts,
            tooltip: 'Синхронизировать контакты',
          ),
        ],
      ),
      body: Column(
        children: [
          // Статистика
          _buildStatsSection(store),

          // Поиск и фильтры
          _buildSearchSection(store),

          // Список контактов
          Expanded(
            child: _buildContactsList(store, context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInviteDialog(context, store),
        child: const Icon(Icons.person_add),
        tooltip: 'Пригласить друзей',
      ),
    );
  }

  Widget _buildStatsSection(SocialStore store) {
    return Observer(
      builder: (_) => Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('В приложении', '${store.totalAppUsers}'),
              _buildStatItem('Приглашены', '${store.totalInvited}'),
              _buildStatItem('Всего контактов', '${store.totalContacts}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(SocialStore store) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Поиск
          TextField(
            decoration: const InputDecoration(
              labelText: 'Поиск контактов',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: store.setSearchQuery,
          ),

          const SizedBox(height: 12),

          // Переключатель фильтра
          Observer(
            builder: (_) => Row(
              children: [
                const Text('Только в приложении'),
                const Spacer(),
                Switch(
                  value: store.showOnlyAppUsers,
                  onChanged: (_) => store.toggleShowOnlyAppUsers(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(SocialStore store, BuildContext context) {
    return Observer(
      builder: (_) {
        if (store.isLoading && store.allContacts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final contacts = store.filteredContacts;

        if (contacts.isEmpty) {
          return _buildEmptyState(store);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final friend = contacts[index];
            return _buildFriendItem(friend, store, context);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(SocialStore store) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Observer(
            builder: (_) => Text(
              store.showOnlyAppUsers
                  ? 'Нет друзей в приложении'
                  : 'Контакты не найдены',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Пригласите друзей или синхронизируйте контакты',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: store.syncContacts,
            child: const Text('Синхронизировать контакты'),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendItem(Friend friend, SocialStore store, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: friend.photoUrl != null
              ? NetworkImage(friend.photoUrl!)
              : const AssetImage('assets/default_avatar.png') as ImageProvider,
          child: friend.photoUrl == null
              ? Text(friend.name[0])
              : null,
        ),
        title: Text(
          friend.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (friend.phoneNumber != null)
              Text(friend.phoneNumber!),
            const SizedBox(height: 4),
            _buildStatusChip(friend.status),
            if (friend.status == FriendStatus.usingApp && friend.lastActive != null)
              Text(
                'Был(а) в сети: ${_formatLastActive(friend.lastActive!)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: _buildFriendActions(friend, store, context),
        onTap: () => _showFriendDetails(context, friend, store),
      ),
    );
  }

  Widget _buildStatusChip(FriendStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case FriendStatus.usingApp:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        text = 'В приложении';
        break;
      case FriendStatus.invited:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        text = 'Приглашен';
        break;
      case FriendStatus.notInvited:
        backgroundColor = Colors.grey[300]!;
        textColor = Colors.grey[600]!;
        text = 'Не в приложении';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: backgroundColor,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildFriendActions(Friend friend, SocialStore store, BuildContext context) {
    switch (friend.status) {
      case FriendStatus.usingApp:
        return IconButton(
          icon: const Icon(Icons.chat, color: Colors.blue),
          onPressed: () => _showChatDialog(context, friend),
          tooltip: 'Написать сообщение',
        );
      case FriendStatus.invited:
        return const Icon(
          Icons.schedule,
          color: Colors.orange,
          size: 20,
        );
      case FriendStatus.notInvited:
        return IconButton(
          icon: const Icon(Icons.person_add, color: Colors.green),
          onPressed: () => store.inviteFriend(friend),
          tooltip: 'Пригласить в приложение',
        );
    }
  }

  void _showFriendDetails(BuildContext context, Friend friend, SocialStore store) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: friend.photoUrl != null
                  ? NetworkImage(friend.photoUrl!)
                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
              child: friend.photoUrl == null
                  ? Text(
                friend.name[0],
                style: const TextStyle(fontSize: 24),
              )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              friend.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (friend.phoneNumber != null) ...[
              const SizedBox(height: 8),
              Text(friend.phoneNumber!),
            ],
            const SizedBox(height: 16),
            _buildStatusChip(friend.status),
            const SizedBox(height: 20),
            if (friend.status == FriendStatus.notInvited)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    store.inviteFriend(friend);
                    Navigator.pop(context);
                  },
                  child: const Text('Пригласить в приложение'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showChatDialog(BuildContext context, Friend friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Чат с ${friend.name}'),
        content: const Text(
          'В будущих версиях здесь будет чат с друзьями для обсуждения финансовых целей и советов.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context, SocialStore store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пригласить друзей'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people, size: 60, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Пригласите друзей и следите за их финансовыми успехами вместе!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ссылка для приглашения скопирована'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Пригласить'),
          ),
        ],
      ),
    );
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else {
      return '${difference.inDays} дн назад';
    }
  }
}