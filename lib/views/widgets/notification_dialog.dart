import '../../controllers/gift_controller.dart';
import '../../models/notification_model.dart';
import 'package:flutter/material.dart';
import '../../models/gift_model.dart';

import '../gift_details_page.dart';

class NotificationDialog extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDialog({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_getNotificationTitle(notification.type)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.giftName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _formatTimeAgo(notification.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
          },
          child: const Text('Dismiss'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Close dialog

            // Get gift details before navigation
            final giftController = GiftController();
            try {
              final gift = await giftController.getGiftById(notification.giftId);
              if (gift != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftDetailsPage(
                      eventId: gift.eventId,
                      eventName: 'Gift Details',
                      gift: gift,
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gift not found')),
                );
              }
            }
          },
          child: const Text('View'),
        ),
      ],
    );
  }

  String _getNotificationTitle(NotificationType type) {
    switch (type) {
      case NotificationType.giftPledged:
        return 'New Gift Pledged';
      case NotificationType.giftUnpledged:
        return 'Gift Unpledged';
      case NotificationType.giftPurchased:
        return 'Gift Purchased';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}