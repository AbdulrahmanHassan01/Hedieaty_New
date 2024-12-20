import 'package:flutter/material.dart';

import '../../controllers/notification_controller.dart';
import '../../models/notification_model.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationController().getNotifications(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final unreadCount = snapshot.data!
            .where((notification) => !notification.isRead)
            .length;

        if (unreadCount == 0) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          constraints: const BoxConstraints(
            minWidth: 20,
            minHeight: 20,
          ),
          child: Text(
            unreadCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}