import 'package:flutter/material.dart';

enum NameTitle { Mr, Mrs }

class UserM extends ChangeNotifier {
  String? userID;
  String? firstName;
  String? lastName;
  String? email;
  // String password;
  // late String reEnterPassword;
  DateTime? selectedDate;
  NameTitle? selectedTitle;
  bool sendPromos = false;

  UserM({
    this.userID,
    this.email,
    this.firstName,
    this.lastName,
  });

  @override
  String toString() {
    return 'User{firstName: $firstName, lastName: $lastName, email: $email, '
        'selectedDate: $selectedDate, selectedTitle: $selectedTitle}';
  }

  void updateUID(String value) {
    userID = value;
    print("userrrr id update wenawaaa $userID");
    notifyListeners();
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
    print("emaaaail update wuna : $email");
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
    print("date of birth : $selectedDate");
    notifyListeners();
  }

  void updateTitle(NameTitle? title) {
    selectedTitle = title;
    print("selected title: $selectedTitle");
    notifyListeners();
  }

  void updateSendPromos(bool promos) {
    sendPromos = promos;
    notifyListeners();
  }
}
