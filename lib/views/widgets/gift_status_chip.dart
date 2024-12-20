import 'package:flutter/material.dart';
import '../../models/gift_model.dart';

class GiftStatusChip extends StatelessWidget {
  final GiftStatus status;

  const GiftStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case GiftStatus.available:
        color = Colors.blue;
        label = 'Available';
        icon = Icons.card_giftcard;
      case GiftStatus.pledged:
        color = Colors.green;
        label = 'Pledged';
        icon = Icons.check_circle;
      case GiftStatus.purchased:
        color = Colors.purple;
        label = 'Purchased';
        icon = Icons.shopping_bag;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}