import 'package:flutter/material.dart';

enum NameTitle { Mr, Mrs }

class User extends ChangeNotifier {
  late String firstName;
  late String lastName;
  late String email;
  // String password;
  // late String reEnterPassword;
  DateTime? selectedDate;
  NameTitle? selectedTitle;
  bool sendPromos = false;

  @override
  String toString() {
    return 'User{firstName: $firstName, lastName: $lastName, email: $email, '
        'selectedDate: $selectedDate, selectedTitle: $selectedTitle}';
  }

  void updateFirstName(String value) {
    firstName = value;
    notifyListeners();
  }

  void updateLastName(String value) {
    lastName = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  // void updatePassword(String value) {
  //   password = value;
  //   notifyListeners();
  // }
  //
  // void updateReEnterPassword(String value) {
  //   reEnterPassword = value;
  //   notifyListeners();
  // }

  void updateDob(DateTime? dob) {
    selectedDate = dob;
    print("date of birth wtto: $selectedDate");
    notifyListeners();
  }

  void updateTitle(NameTitle? title) {
    selectedTitle = title;
    print("see;ecteddd ttileee fm: $selectedTitle");
    notifyListeners();
  }

  void updateSendPromos(bool promos) {
    sendPromos = promos;
    notifyListeners();
  }
}
