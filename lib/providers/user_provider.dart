import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lyft_mate/models/loggeduser.dart';

import '../models/user.dart';


class UserProvider extends ChangeNotifier {

  // late UserM _user;
  //
  // UserM get user => _user;
  //
  // void setUser(UserM user) {
  //   _user = user;
  //   notifyListeners();
  // }
  //
  // void updateUser(UserM newUser) {
  //   _user = newUser;
  //   notifyListeners();
  // }

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
