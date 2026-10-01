import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatFreshness(DateTime? dateTime) {
    if (dateTime == null) return 'Freshness unconfirmed';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      if (difference.inMinutes <= 1) return 'Confirmed just now';
      return 'Confirmed ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Confirmed ${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Confirmed yesterday';
    } else if (difference.inDays < 7) {
      return 'Confirmed ${difference.inDays}d ago';
    } else {
      return 'Confirmed on ${DateFormat('dd MMM').format(dateTime)}';
    }
  }

  static String formatListedDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }
}
