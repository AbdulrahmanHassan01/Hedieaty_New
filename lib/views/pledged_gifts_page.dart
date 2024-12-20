import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/gift_model.dart';
import 'gift_details_page.dart';
import '../views/widgets/gift_status_chip.dart';


class PledgedGiftsPage extends StatefulWidget {
  const PledgedGiftsPage({super.key});

  @override
  State<PledgedGiftsPage> createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final GiftController _giftController = GiftController();
  String _sortBy = 'date';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date',
                child: Text('Sort by Date'),
              ),
              const PopupMenuItem(
                value: 'status',
                child: Text('Sort by Status'),
              ),
              const PopupMenuItem(
                value: 'price',
                child: Text('Sort by Price'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<GiftModel>>(
        stream: _giftController.getUserPledgedGifts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final gifts = snapshot.data ?? [];

          // Sort gifts
          switch (_sortBy) {
            case 'date':
              gifts.sort((a, b) => (b.pledgedAt ?? DateTime.now())
                  .compareTo(a.pledgedAt ?? DateTime.now()));
            case 'status':
              gifts.sort((a, b) => a.status.index.compareTo(b.status.index));
            case 'price':
              gifts.sort((a, b) => b.price.compareTo(a.price));
          }

          if (gifts.isEmpty) {
            return const Center(
              child: Text('No pledged gifts yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              return Card(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftDetailsPage(
                          eventId: gift.eventId,
                          eventName: 'Pledged Gift', // You might want to fetch the actual event name
                          gift: gift,
                        ),
                      ),
                    );
                  },
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
                                    gift.name,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${gift.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GiftStatusChip(status: gift.status),
                          ],
                        ),
                        if (gift.pledgedAt != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Pledged on: ${_formatDate(gift.pledgedAt!)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}