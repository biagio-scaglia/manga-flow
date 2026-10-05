import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateFormatter {
  static bool _isInitialized = false;

  static Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      try {
        await initializeDateFormatting('it_IT', null);
        _isInitialized = true;
      } catch (_) {
        // Fallback silently if platform doesn't need external data
      }
    }
  }

  static String formatShortDate(DateTime? date) {
    if (date == null) return 'Data non disponibile';
    try {
      final formatter = DateFormat('d MMM yyyy', 'it_IT');
      return formatter.format(date);
    } catch (_) {
      try {
        final fallbackFormatter = DateFormat('d MMM yyyy');
        return fallbackFormatter.format(date);
      } catch (_) {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    }
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
