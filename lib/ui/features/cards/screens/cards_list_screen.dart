import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/ui/features/cards/state/cards_store.dart';
import 'package:prac13/core/models/card_model.dart';

class CardsListScreen extends StatelessWidget {
  const CardsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<CardsStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои карты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/cards/add');
            },
            tooltip: 'Добавить карту',
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          if (store.isLoading && store.cards.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // Общая статистика
              _buildStatsSection(store),

              // Список карт
              Expanded(
                child: _buildCardsList(store, context),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/cards/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsSection(CardsStore store) {
    return Observer(
      builder: (_) => Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Общий баланс', '${store.totalBalance.toStringAsFixed(2)} ₽'),
                  _buildStatItem('Доступный кредит', '${store.totalAvailableCredit.toStringAsFixed(2)} ₽'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Карт: ${store.activeCards.length}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
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
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCardsList(CardsStore store, BuildContext context) {
    return Observer(
      builder: (_) {
        if (store.cards.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.credit_card,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Нет добавленных карт',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Нажмите + чтобы добавить карту',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: store.cards.length,
          itemBuilder: (context, index) {
            final card = store.cards[index];
            return _buildCardItem(card, store, context);
          },
        );
      },
    );
  }

  Widget _buildCardItem(CardModel card, CardsStore store, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(card.cardColor.colorValue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            card.isCreditCard ? Icons.credit_card : Icons.account_balance_wallet,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          '${card.bankName} • ${card.maskedCardNumber}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: card.isActive ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.cardType.displayName,
              style: TextStyle(
                color: card.isActive ? Colors.grey : Colors.grey[400],
              ),
            ),
            Text(
              'Баланс: ${card.balance.toStringAsFixed(2)} ₽',
              style: TextStyle(
                color: card.isActive ? Colors.green : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (card.isCreditCard)
              Text(
                'Лимит: ${card.creditLimit?.toStringAsFixed(2)} ₽',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            card.isActive ? Icons.toggle_on : Icons.toggle_off,
            color: card.isActive ? Colors.green : Colors.grey,
            size: 30,
          ),
          onPressed: () {
            store.toggleCardStatus(card.id);
          },
        ),
        onTap: () {
          context.push('/cards/${card.id}');
        },
        onLongPress: () {
          _showCardOptions(context, card, store);
        },
      ),
    );
  }

  void _showCardOptions(BuildContext context, CardModel card, CardsStore store) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Редактировать'),
            onTap: () {
              Navigator.pop(context);
              context.push('/cards/${card.id}/edit');
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Удалить', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(context, card, store);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CardModel card, CardsStore store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить карту?'),
        content: Text('Карта ${card.bankName} • ${card.maskedCardNumber} будет удалена.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              store.deleteCard(card.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}