import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lyft_mate/models/loggeduser.dart';

import '../models/user.dart';


class UserProvider extends ChangeNotifier {

  late LoggedUser _user;

  LoggedUser get user => _user;

  void setUser(LoggedUser user) {
    _user = user;
    notifyListeners();
  }

  void updateUser(LoggedUser newUser) {
    _user = newUser;
    notifyListeners();
  }


}
