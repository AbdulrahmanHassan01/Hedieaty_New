import 'package:flutter/material.dart';
import 'friend_gift_list_page.dart';
import 'gift_details_page.dart';

class FriendEventListPage extends StatefulWidget {
  final String friendName; // Pass friend's name to show in AppBar

  const FriendEventListPage({
    super.key,
    required this.friendName,
  });

  @override
  State<FriendEventListPage> createState() => _FriendEventListPageState();
}

class _FriendEventListPageState extends State<FriendEventListPage> {
  String _sortBy = 'name';
  // Use the same Event class as EventListPage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.friendName}'s Events"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
              // TODO: Implement sorting
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
                value: 'status',
                child: Text('Sort by Status'),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3, // Mock data
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendGiftListPage(
                        friendName: widget.friendName,
                        eventName: 'Event ${index + 1}',
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event ${index + 1}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Coming up in ${index + 1} days',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// views/friend_gift_list_page.dart
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.friendName}'s Gifts"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Sorting menu same as before
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Mock data
        itemBuilder: (context, index) {
          final bool isPledged = index % 2 == 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: InkWell(
                onTap: () {
                  // Create a mock gift for demonstration
                  final mockGift = FriendGift(
                    id: 'gift-${index + 1}',
                    name: 'Gift ${index + 1}',
                    description: 'This is a description for Gift ${index + 1}',
                    category: 'Category ${index + 1}',
                    price: 99.99 * (index + 1),
                    isPledged: index % 2 == 0, // Alternate between pledged and unpledged
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GiftDetailsPage(
                        friendName: widget.friendName,
                        eventName: 'Event ${index + 1}',
                        gift: mockGift,  // Pass the mock gift
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
                                  'Gift ${index + 1}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Category ${index + 1}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isPledged
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isPledged ? 'Pledged' : 'Available',
                              style: TextStyle(
                                color: isPledged ? Colors.green : Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${(99.99 * (index + 1)).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}