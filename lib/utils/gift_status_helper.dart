import 'package:flutter/material.dart';
import '../models/gift_model.dart';

class GiftStatusHelper {
  static Color getStatusColor(GiftStatus status) {
    switch (status) {
      case GiftStatus.available:
        return Colors.blue;
      case GiftStatus.pledged:
        return Colors.green;
      case GiftStatus.purchased:
        return Colors.purple;
    }
  }

  static IconData getStatusIcon(GiftStatus status) {
    switch (status) {
      case GiftStatus.available:
        return Icons.card_giftcard;
      case GiftStatus.pledged:
        return Icons.check_circle;
      case GiftStatus.purchased:
        return Icons.shopping_bag;
    }
  }

  static String getStatusText(GiftStatus status) {
    switch (status) {
      case GiftStatus.available:
        return 'Available';
      case GiftStatus.pledged:
        return 'Pledged';
      case GiftStatus.purchased:
        return 'Purchased';
    }
  }
}