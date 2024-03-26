import 'package:flutter/material.dart';

import '../models/user.dart';


class UserProvider extends ChangeNotifier {

  late UserM _user;

  UserM get user => _user;

  void setUser(UserM user) {
    _user = user;
    notifyListeners();
  }

  void updateUser(UserM newUser) {
    _user = newUser;
    notifyListeners();
  }

}
