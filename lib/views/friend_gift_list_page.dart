// views/friend_gift_list_page.dart
import 'package:flutter/material.dart';
import 'gift_details_page.dart';

class FriendGift {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final bool isPledged;
  final String? imageUrl;

  FriendGift({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.isPledged = false,
    this.imageUrl,
  });
}

class FriendGiftListPage extends StatefulWidget {
  final String friendName;
  final String eventName;

  const FriendGiftListPage({
    super.key,
    required this.friendName,
    required this.eventName,
  });

  @override
  State<FriendGiftListPage> createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  String _sortBy = 'name';

  // Mock data
  final List<FriendGift> _mockGifts = [
    FriendGift(
      id: '1',
      name: 'PlayStation 5',
      description: 'Gaming console with extra controller',
      category: 'Electronics',
      price: 499.99,
      isPledged: true,
    ),
    FriendGift(
      id: '2',
      name: 'Nike Running Shoes',
      description: 'Size 42, Black color',
      category: 'Sports',
      price: 129.99,
      isPledged: false,
    ),
    FriendGift(
      id: '3',
      name: 'Harry Potter Collection',
      description: 'Complete book series, hardcover',
      category: 'Books',
      price: 199.99,
      isPledged: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.eventName),
            Text(
              widget.friendName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftDetailsPage(
                      friendName: widget.friendName,
                      eventName: widget.eventName,
                      gift: gift,
                    ),
                  ),
                );
              },
            ),
          );
        },
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
      }
    });
  }
}

class _GiftCard extends StatelessWidget {
  final FriendGift gift;
  final VoidCallback onTap;

  const _GiftCard({
    required this.gift,
    required this.onTap,
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
                            color: gift.isPledged
                                ? Colors.green.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                gift.isPledged
                                    ? Icons.check_circle
                                    : Icons.card_giftcard,
                                size: 16,
                                color: gift.isPledged
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                gift.isPledged ? 'Pledged' : 'Available',
                                style: TextStyle(
                                  color: gift.isPledged
                                      ? Colors.green
                                      : Colors.blue,
                                  fontSize: 12,
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
            ],
          ),
        ),
      ),
    );
  }
}