import 'dart:async';
import 'package:flutter/foundation.dart';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }
}

class Throttler {
  final Duration interval;
  Timer? _timer;
  bool _isReady = true;

  Throttler({required this.interval});

  void run(VoidCallback action) {
    if (_isReady) {
      _isReady = false;
      action();
      _timer?.cancel();
      _timer = Timer(interval, () {
        _isReady = true;
      });
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
