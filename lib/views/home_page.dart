import 'package:flutter/material.dart';
import 'event_list_page.dart';
import 'friend_event_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedieaty'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search friends',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                // TODO: Implement search
              },
            ),
          ),

          // Friends Grid
          Expanded(
            child: // In home_page.dart, update the GridView.builder section:

            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                return _FriendCard(
                  name: 'Friend ${index + 1}',
                  eventCount: index % 3,
                  imageUrl: null,
                  onTap: () {
                    // Navigate to FriendEventListPage when a friend card is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendEventListPage(
                          friendName: 'Friend ${index + 1}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              heroTag: 'createEvent',
              onPressed: () {
                // Navigate to EventListPage when Create Event is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EventListPage(),
                  ),
                );
              },
              label: const Text('Create Event'),
              icon: const Icon(Icons.add),
            ),
            FloatingActionButton(
              heroTag: 'addFriend',
              onPressed: () {
                // TODO: Implement add friend
              },
              child: const Icon(Icons.person_add),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final String name;
  final int eventCount;
  final String? imageUrl;
  final VoidCallback onTap;

  const _FriendCard({
    required this.name,
    required this.eventCount,
    required this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                child: imageUrl == null
                    ? Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                )
                    : null,
              ),
              const SizedBox(height: 12),

              // Name
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Event Count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: eventCount > 0
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  eventCount == 0
                      ? 'No Events'
                      : '$eventCount Events',
                  style: TextStyle(
                    color: eventCount > 0
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}