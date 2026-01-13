import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  String _message = 'Hello, Cricket Spirit!';
  int _taps = 0;

  String get message => _message;
  int get taps => _taps;

  void increment() {
    _taps++;
    _message = _taps == 1
        ? 'Hello, Cricket Spirit!'
        : 'You tapped $_taps times.';
    notifyListeners();
  }
}

