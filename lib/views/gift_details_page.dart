import 'package:flutter/material.dart';
import 'friend_gift_list_page.dart';


class GiftDetailsPage extends StatefulWidget {
  final String friendName;
  final String eventName;
  final FriendGift gift;

  const GiftDetailsPage({
    super.key,
    required this.friendName,
    required this.eventName,
    required this.gift,
  });

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  late bool isPledged;

  @override
  void initState() {
    super.initState();
    isPledged = widget.gift.isPledged;
  }

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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gift Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: widget.gift.imageUrl != null
                      ? DecorationImage(
                    image: NetworkImage(widget.gift.imageUrl!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: widget.gift.imageUrl == null
                    ? Icon(
                  Icons.card_giftcard,
                  size: 80,
                  color: Colors.grey[400],
                )
                    : null,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gift Status Badge
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPledged ? Icons.check_circle : Icons.card_giftcard,
                          size: 16,
                          color: isPledged ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isPledged ? 'Pledged' : 'Available',
                          style: TextStyle(
                            color: isPledged ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gift Name and Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.gift.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$${widget.gift.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.gift.category,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.gift.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _togglePledge,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPledged ? Colors.red : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isPledged ? Icons.cancel : Icons.check_circle),
                const SizedBox(width: 8),
                Text(isPledged ? 'Unpledge Gift' : 'Pledge Gift'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _togglePledge() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPledged ? 'Unpledge Gift?' : 'Pledge Gift?'),
        content: Text(
          isPledged
              ? 'Are you sure you want to unpledge this gift?'
              : 'Would you like to pledge this gift?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => isPledged = !isPledged);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isPledged
                        ? 'Gift pledged successfully!'
                        : 'Gift unpledged successfully!',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(isPledged ? 'Unpledge' : 'Pledge'),
          ),
        ],
      ),
    );
  }
}