import 'package:flutter/material.dart';
import 'gift_list_page.dart';


enum EventStatus {
  upcoming,
  current,
  past,
}

class Event {
  final String id;
  final String name;
  final String category;
  final DateTime date;
  final EventStatus status;

  Event({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.status,
  });
}

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  String _sortBy = 'name'; // 'name', 'category', 'status'
  List<Event> _mockEvents = [
    Event(
      id: '1',
      name: 'Birthday Party',
      category: 'Birthday',
      date: DateTime.now().add(const Duration(days: 5)),
      status: EventStatus.upcoming,
    ),
    Event(
      id: '2',
      name: 'Wedding Anniversary',
      category: 'Anniversary',
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: EventStatus.current,
    ),
    // Add more mock events as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortEvents();
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
                value: 'status',
                child: Text('Sort by Status'),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockEvents.length,
        itemBuilder: (context, index) {
          final event = _mockEvents[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _EventCard(
              event: event,
              onEdit: () {
                // TODO: Navigate to edit event
              },
              onDelete: () {
                // TODO: Implement delete
                setState(() {
                  _mockEvents.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to create event
        },
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
      ),
    );
  }

  void _sortEvents() {
    setState(() {
      switch (_sortBy) {
        case 'name':
          _mockEvents.sort((a, b) => a.name.compareTo(b.name));
        case 'category':
          _mockEvents.sort((a, b) => a.category.compareTo(b.category));
        case 'status':
          _mockEvents.sort((a, b) => a.status.index.compareTo(b.status.index));
      }
    });
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(  // Add InkWell here
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GiftListPage(eventName: event.name),
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
                            event.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.category,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
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
                          onEdit();
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Event'),
                              content: const Text(
                                  'Are you sure you want to delete this event?'
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    onDelete();
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatusChip(status: event.status),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(event.date),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final EventStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case EventStatus.upcoming:
        color = Colors.blue;
        label = 'Upcoming';
      case EventStatus.current:
        color = Colors.green;
        label = 'Current';
      case EventStatus.past:
        color = Colors.grey;
        label = 'Past';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}