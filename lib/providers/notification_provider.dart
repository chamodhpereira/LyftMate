import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  bool _hasNewNotification = false;

  bool get hasNewNotification => _hasNewNotification;

  void setNewNotification(bool value) {
    _hasNewNotification = value;
    notifyListeners();
    print("PROVIDEEEEEEEEEER: $_hasNewNotification");
  }
}
