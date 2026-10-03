import 'package:intl/intl.dart';

class DateFormatter {
  static String formatShortDate(DateTime? date) {
    if (date == null) return 'Data non disponibile';
    final formatter = DateFormat('d MMM yyyy', 'it_IT');
    return formatter.format(date);
  }

  static String formatRelativeDate(DateTime? date) {
    if (date == null) return 'Mai';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes <= 1) {
          return 'Poco fa';
        }
        return '${difference.inMinutes} minuti fa';
      }
      return '${difference.inHours} ore fa';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 settimana fa' : '$weeks settimane fa';
    } else {
      return formatShortDate(date);
    }
  }
}
