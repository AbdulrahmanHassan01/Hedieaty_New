import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gift_model.dart';
import '../controllers/gift_controller.dart';

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

  Future<void> _handlePledgeAction() async {
    setState(() => _isLoading = true);

    try {
      if (widget.gift.status == GiftStatus.pledged) {
        // Only allow unpledging if current user pledged it
        if (widget.gift.pledgedByUserId != FirebaseAuth.instance.currentUser?.uid) {
          throw 'You cannot unpledge a gift pledged by someone else';
        }
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

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwnGift = widget.gift.userId == currentUserId;
    final canPledge = !isOwnGift &&
        (widget.gift.status != GiftStatus.pledged ||
            widget.gift.pledgedByUserId == currentUserId);

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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.gift.status == GiftStatus.pledged
                          ? Colors.green.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.gift.status == GiftStatus.pledged
                              ? Icons.check_circle
                              : Icons.card_giftcard,
                          size: 16,
                          color: widget.gift.status == GiftStatus.pledged
                              ? Colors.green
                              : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.gift.status == GiftStatus.pledged
                              ? 'Pledged'
                              : 'Available',
                          style: TextStyle(
                            color: widget.gift.status == GiftStatus.pledged
                                ? Colors.green
                                : Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  if (widget.gift.status == GiftStatus.pledged) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Pledge Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
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
      bottomNavigationBar: canPledge
          ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handlePledgeAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.gift.status == GiftStatus.pledged
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
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
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.gift.status == GiftStatus.pledged
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.gift.status == GiftStatus.pledged
                      ? 'Unpledge Gift'
                      : 'Pledge Gift',
                ),
              ],
            ),
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