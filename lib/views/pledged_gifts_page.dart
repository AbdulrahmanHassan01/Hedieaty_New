import 'package:flutter/material.dart';

class PledgedGift {
  final String id;
  final String giftName;
  final String friendName;
  final String eventName;
  final DateTime dueDate;
  final double price;
  final bool isPending; // true if still pending, false if already purchased

  PledgedGift({
    required this.id,
    required this.giftName,
    required this.friendName,
    required this.eventName,
    required this.dueDate,
    required this.price,
    required this.isPending,
  });
}

class PledgedGiftsPage extends StatefulWidget {
  const PledgedGiftsPage({super.key});

  @override
  State<PledgedGiftsPage> createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  // Mock data
  final List<PledgedGift> _mockPledgedGifts = [
    PledgedGift(
      id: '1',
      giftName: 'PlayStation 5',
      friendName: 'John Smith',
      eventName: 'Birthday Party',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      price: 499.99,
      isPending: true,
    ),
    PledgedGift(
      id: '2',
      giftName: 'Air Fryer',
      friendName: 'Sarah Johnson',
      eventName: 'House Warming',
      dueDate: DateTime.now().add(const Duration(days: 15)),
      price: 119.99,
      isPending: true,
    ),
    PledgedGift(
      id: '3',
      giftName: 'Book Collection',
      friendName: 'Mike Wilson',
      eventName: 'Graduation',
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      price: 89.99,
      isPending: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockPledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = _mockPledgedGifts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PledgedGiftCard(
              gift: gift,
              onMarkPurchased: gift.isPending ? () {
                setState(() {
                  _mockPledgedGifts[index] = PledgedGift(
                    id: gift.id,
                    giftName: gift.giftName,
                    friendName: gift.friendName,
                    eventName: gift.eventName,
                    dueDate: gift.dueDate,
                    price: gift.price,
                    isPending: false,
                  );
                });
              } : null,
              onCancelPledge: gift.isPending ? () {
                setState(() {
                  _mockPledgedGifts.removeAt(index);
                });
              } : null,
            ),
          );
        },
      ),
    );
  }
}

class _PledgedGiftCard extends StatelessWidget {
  final PledgedGift gift;
  final VoidCallback? onMarkPurchased;
  final VoidCallback? onCancelPledge;

  const _PledgedGiftCard({
    required this.gift,
    this.onMarkPurchased,
    this.onCancelPledge,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = gift.isPending && gift.dueDate.isBefore(DateTime.now());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gift.giftName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'For ${gift.friendName}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${gift.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              gift.eventName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: isOverdue ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Due ${_formatDate(gift.dueDate)}',
                  style: TextStyle(
                    color: isOverdue ? Colors.red : Colors.grey[600],
                    fontWeight: isOverdue ? FontWeight.bold : null,
                  ),
                ),
                const Spacer(),
                if (gift.isPending) ...[
                  TextButton.icon(
                    onPressed: onMarkPurchased,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark Purchased'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onCancelPledge,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            size: 16,
                            color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Purchased',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}