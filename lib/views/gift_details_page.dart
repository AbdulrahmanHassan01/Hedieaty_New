import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gift_model.dart';
import '../controllers/gift_controller.dart';
import '../views/widgets/gift_status_chip.dart';

class GiftDetailsPage extends StatefulWidget {
  final String eventId;
  final String eventName;
  final GiftModel gift;

  const GiftDetailsPage({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.gift,
  });

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final GiftController _giftController = GiftController();
  bool _isLoading = false;

  bool get isOwner => widget.gift.userId == FirebaseAuth.instance.currentUser?.uid;
  bool get isPledger => widget.gift.pledgedByUserId == FirebaseAuth.instance.currentUser?.uid;
  bool get canPledge => !isOwner && widget.gift.status == GiftStatus.available;

  Future<void> _handlePledgeAction() async {
    setState(() => _isLoading = true);

    try {
      if (widget.gift.status == GiftStatus.pledged) {
        await _giftController.unpledgeGift(widget.gift.id);
      } else {
        await _giftController.pledgeGift(widget.gift.id);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.gift.status == GiftStatus.pledged
                  ? 'Gift unpledged successfully'
                  : 'Gift pledged successfully',
            ),
          ),
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleMarkAsPurchased() async {
    setState(() => _isLoading = true);
    try {
      await _giftController.markGiftAsPurchased(widget.gift.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gift marked as purchased')),
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gift Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
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
                  size: 64,
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
                  // Status Badge
                  GiftStatusChip(status: widget.gift.status),
                  const SizedBox(height: 16),

                  // Gift Details
                  Text(
                    widget.gift.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.gift.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 24),

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

                  // Pledge Info
                  if (widget.gift.status == GiftStatus.pledged &&
                      widget.gift.pledgedByUserId != null &&
                      widget.gift.pledgedAt != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Pledge Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pledged by: ${isPledger ? 'You' : 'Someone else'}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      'Pledged on: ${_formatDate(widget.gift.pledgedAt!)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (canPledge || isPledger)
          ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPledger && widget.gift.status == GiftStatus.pledged)
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleMarkAsPurchased,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag),
                      SizedBox(width: 8),
                      Text('Mark as Purchased'),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              if (isPledger && widget.gift.status != GiftStatus.purchased)
                ElevatedButton(
                  onPressed: _isLoading ? null : _handlePledgeAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove_circle_outline),
                      SizedBox(width: 8),
                      Text('Unpledge Gift'),
                    ],
                  ),
                ),
              if (canPledge)
                ElevatedButton(
                  onPressed: _isLoading ? null : _handlePledgeAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline),
                      SizedBox(width: 8),
                      Text('Pledge Gift'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      )
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}