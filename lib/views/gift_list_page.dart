import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import '../models/event_model.dart';
import '../controllers/gift_controller.dart';
import 'widgets/gift_card.dart';
import 'addGift_page.dart';
import 'gift_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GiftListPage extends StatefulWidget {
  final String eventId;
  final String eventName;
  final EventStatus eventStatus;

  const GiftListPage({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.eventStatus,
  });

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftController _giftController = GiftController();
  String _sortBy = 'name';

  void _showEditGiftDialog(GiftModel gift) {
    final nameController = TextEditingController(text: gift.name);
    final descriptionController = TextEditingController(text: gift.description);
    final priceController = TextEditingController(text: gift.price.toString());
    String selectedCategory = gift.category;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Gift'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Gift Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: [
                  'Electronics',
                  'Books',
                  'Clothing',
                  'Kitchen',
                  'Home',
                  'Sports',
                  'Toys',
                  'Other',
                ].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCategory = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _giftController.editGift(
                  giftId: gift.id,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  category: selectedCategory,
                  price: double.parse(priceController.text),
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gift updated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isUpcomingEvent = widget.eventStatus == EventStatus.upcoming;

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
          if (gifts.isEmpty) {
            return const Center(
              child: Text('No gifts found. Add some!'),
            );
          }

          // Sort gifts
          switch (_sortBy) {
            case 'name':
              gifts.sort((a, b) => a.name.compareTo(b.name));
            case 'category':
              gifts.sort((a, b) => a.category.compareTo(b.category));
            case 'price':
              gifts.sort((a, b) => a.price.compareTo(b.price));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              final isOwner = gift.userId == currentUserId;
              final canEdit = isOwner && isUpcomingEvent;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GiftCard(
                  gift: gift,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftDetailsPage(
                          eventId: widget.eventId,
                          eventName: widget.eventName,
                          gift: gift,
                        ),
                      ),
                    );
                  },
                  onEdit: canEdit ? () => _showEditGiftDialog(gift) : null,
                  onDelete: canEdit ? () async {
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
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isUpcomingEvent
          ? FloatingActionButton.extended(
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
      )
          : null,
    );
  }
}