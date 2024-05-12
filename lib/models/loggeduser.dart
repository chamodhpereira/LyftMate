import 'package:flutter/material.dart';

enum NameTitle { Mr, Mrs }

class LoggedUser {
  String? userID = "";
  String? firstName;
  String? lastName;
  String? email;

  // String password;
  // late String reEnterPassword;
  DateTime? selectedDate;
  NameTitle? selectedTitle;
  bool sendPromos = false;


  LoggedUser({
    this.userID,
    this.email,
    this.firstName,
    this.lastName,
  });
}

