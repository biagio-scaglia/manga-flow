import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ReadingStatus {
  reading,
  planToRead,
  completed,
  onHold,
  dropped;

  String get label {
    switch (this) {
      case ReadingStatus.reading:
        return 'In lettura';
      case ReadingStatus.planToRead:
        return 'Da leggere';
      case ReadingStatus.completed:
        return 'Completato';
      case ReadingStatus.onHold:
        return 'In pausa';
      case ReadingStatus.dropped:
        return 'Abbandonato';
    }
  }

  Color get color {
    switch (this) {
      case ReadingStatus.reading:
        return AppColors.statusReading;
      case ReadingStatus.planToRead:
        return AppColors.statusPlanToRead;
      case ReadingStatus.completed:
        return AppColors.statusCompleted;
      case ReadingStatus.onHold:
        return AppColors.statusOnHold;
      case ReadingStatus.dropped:
        return AppColors.statusDropped;
    }
  }

  IconData get icon {
    switch (this) {
      case ReadingStatus.reading:
        return Icons.auto_stories_rounded;
      case ReadingStatus.planToRead:
        return Icons.bookmark_add_rounded;
      case ReadingStatus.completed:
        return Icons.check_circle_rounded;
      case ReadingStatus.onHold:
        return Icons.pause_circle_rounded;
      case ReadingStatus.dropped:
        return Icons.cancel_rounded;
    }
  }

  String toStorageKey() {
    switch (this) {
      case ReadingStatus.reading:
        return 'reading';
      case ReadingStatus.planToRead:
        return 'plan_to_read';
      case ReadingStatus.completed:
        return 'completed';
      case ReadingStatus.onHold:
        return 'on_hold';
      case ReadingStatus.dropped:
        return 'dropped';
    }
  }

  static ReadingStatus fromStorageKey(String key) {
    switch (key.toLowerCase()) {
      case 'reading':
        return ReadingStatus.reading;
      case 'plan_to_read':
      case 'plantoread':
        return ReadingStatus.planToRead;
      case 'completed':
        return ReadingStatus.completed;
      case 'on_hold':
      case 'onhold':
        return ReadingStatus.onHold;
      case 'dropped':
        return ReadingStatus.dropped;
      default:
        return ReadingStatus.planToRead;
    }
  }
}
