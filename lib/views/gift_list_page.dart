import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import '../controllers/gift_controller.dart';
import 'addGift_page.dart';
import 'gift_details_page.dart';

class GiftListPage extends StatefulWidget {
  final String eventId;
  final String eventName;

  const GiftListPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftController _giftController = GiftController();
  String _sortBy = 'name'; // 'name', 'category', 'price'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.eventName} Gifts'),
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
                value: 'name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: 'category',
                child: Text('Sort by Category'),
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
        stream: _giftController.getEventGifts(widget.eventId),
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
            case 'name':
              gifts.sort((a, b) => a.name.compareTo(b.name));
            case 'category':
              gifts.sort((a, b) => a.category.compareTo(b.category));
            case 'price':
              gifts.sort((a, b) => a.price.compareTo(b.price));
          }

          if (gifts.isEmpty) {
            return const Center(
              child: Text('No gifts found. Add some!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GiftCard(
                  gift: gift,
                  onEdit: () async {
                    // TODO: Navigate to edit gift page
                  },
                  onDelete: () async {
                    try {
                      await _giftController.deleteGift(gift.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gift deleted successfully')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftDetailsPage(
                          eventId: widget.eventId,  // Pass eventId
                          eventName: widget.eventName,  // Pass eventName
                          gift: gift,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddGiftPage(
                eventId: widget.eventId,
                eventName: widget.eventName,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Gift'),
      ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  final GiftModel gift;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _GiftCard({
    required this.gift,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gift Image or Placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: gift.imageUrl != null
                      ? DecorationImage(
                    image: NetworkImage(gift.imageUrl!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: gift.imageUrl == null
                    ? Icon(Icons.card_giftcard,
                    size: 40,
                    color: Colors.grey[400])
                    : null,
              ),
              const SizedBox(width: 16),

              // Gift Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gift.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gift.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            gift.category,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${gift.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: gift.status == GiftStatus.pledged
                                ? Colors.green.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                gift.status == GiftStatus.pledged
                                    ? Icons.check_circle
                                    : Icons.card_giftcard,
                                size: 16,
                                color: gift.status == GiftStatus.pledged
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                gift.status == GiftStatus.pledged
                                    ? 'Pledged'
                                    : 'Available',
                                style: TextStyle(
                                  color: gift.status == GiftStatus.pledged
                                      ? Colors.green
                                      : Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (gift.status == GiftStatus.available &&
                            (onEdit != null || onDelete != null))
                          PopupMenuButton<String>(
                            itemBuilder: (context) => [
                              if (onEdit != null)
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                              if (onDelete != null)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  onEdit?.call();
                                case 'delete':
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Gift'),
                                      content: const Text(
                                          'Are you sure you want to delete this gift?'
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            onDelete?.call();
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}