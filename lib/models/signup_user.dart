enum Gender { male, female, unassigned }

class SignupUserData {
  // Singleton instance
  static final SignupUserData _instance = SignupUserData._internal();

  // Private constructor
  SignupUserData._internal();

  // Factory constructor to return the singleton instance
  factory SignupUserData() {
    return _instance;
  }

  // Properties
  late String firstName;
  late String lastName;
  late Gender selectedGender;
  late String email;
  DateTime dob = DateTime.now();
  late String phoneNumber;

  void reset() {
    // Reset all properties
    firstName = '';
    lastName = '';
    selectedGender = Gender.unassigned;
    email = '';
    dob = DateTime.now();
    phoneNumber = '';
    print("UserData reset");
  }

  // Methods to update properties
  void updatePhoneNumber(String newPhoneNumber) {
    phoneNumber = "+94$newPhoneNumber";
    print("Phone number updated: $phoneNumber");
  }

  void updateFirstName(String newFirstName) {
    firstName = newFirstName;
    print("First name updated: $firstName");
  }

  void updateLastName(String newLastName) {
    lastName = newLastName;
    print("Last name updated: $lastName");
  }

  void updateGender(Gender newGender) {
    selectedGender = newGender;
    print("Gender updated: $selectedGender");
  }

  void updateEmail(String newEmail) {
    email = newEmail;
    print("Email updated: $email");
  }

  void updateDOB(DateTime newDOB) {
    dob = newDOB;
    print("Date of Birth updated: $dob");
  }
}
