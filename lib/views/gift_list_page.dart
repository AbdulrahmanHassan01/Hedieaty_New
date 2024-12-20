import 'package:flutter/material.dart';
import 'addGift_page.dart';

enum GiftStatus {
  available,
  pledged,
}

class Gift {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final GiftStatus status;
  final String? imageUrl;

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    this.imageUrl,
  });
}

class GiftListPage extends StatefulWidget {
  final String eventName; // Pass the event name to show in AppBar

  const GiftListPage({
    super.key,
    required this.eventName,
  });

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  String _sortBy = 'name'; // 'name', 'category', 'status'
  List<Gift> _mockGifts = [
    Gift(
      id: '1',
      name: 'PlayStation 5',
      description: 'Gaming console with extra controller',
      category: 'Electronics',
      price: 499.99,
      status: GiftStatus.available,
    ),
    Gift(
      id: '2',
      name: 'Air Fryer',
      description: 'Digital air fryer, 5.8 Qt',
      category: 'Kitchen',
      price: 119.99,
      status: GiftStatus.pledged,
    ),
    // Add more mock gifts
  ];

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
              setState(() {
                _sortBy = value;
                _sortGifts();
              });
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
              const PopupMenuItem(
                value: 'status',
                child: Text('Sort by Status'),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockGifts.length,
        itemBuilder: (context, index) {
          final gift = _mockGifts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _GiftCard(
              gift: gift,
              onEdit: gift.status == GiftStatus.available ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftDetailsPage(
                      eventName: widget.eventName,
                      gift: gift,
                    ),
                  ),
                );
              } : null,
              onDelete: gift.status == GiftStatus.available ? () {
                setState(() {
                  _mockGifts.removeAt(index);
                });
              } : null,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GiftDetailsPage(
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

  void _sortGifts() {
    setState(() {
      switch (_sortBy) {
        case 'name':
          _mockGifts.sort((a, b) => a.name.compareTo(b.name));
        case 'category':
          _mockGifts.sort((a, b) => a.category.compareTo(b.category));
        case 'price':
          _mockGifts.sort((a, b) => a.price.compareTo(b.price));
        case 'status':
          _mockGifts.sort((a, b) => a.status.index.compareTo(b.status.index));
      }
    });
  }
}

class _GiftCard extends StatelessWidget {
  final Gift gift;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _GiftCard({
    required this.gift,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to gift details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gift Image or Placeholder
                  Container(
                    width: 80,
                    height: 80,
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

                  // Gift Info
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _CategoryChip(category: gift.category),
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
                      ],
                    ),
                  ),

                  // Actions
                  if (gift.status == GiftStatus.available) ...[
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
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
                                Icon(Icons.delete, size: 20),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit?.call();
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Gift'),
                              content: const Text(
                                  'Are you sure you want to delete this gift?'
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
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
                ],
              ),
              const SizedBox(height: 12),
              _StatusChip(status: gift.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final GiftStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case GiftStatus.available:
        color = Colors.blue;
        label = 'Available';
        icon = Icons.card_giftcard;
      case GiftStatus.pledged:
        color = Colors.green;
        label = 'Pledged';
        icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}