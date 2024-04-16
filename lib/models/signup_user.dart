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
  late String notificationToken;
  late String emergencyContactName;
  late String emergencyContactPhoneNumber;
  // late Map<String, String> emergencyContacts;

  void reset() {
    // Reset all properties
    firstName = '';
    lastName = '';
    selectedGender = Gender.unassigned;
    email = '';
    dob = DateTime.now();
    phoneNumber = '';
    notificationToken = '';
    // emergencyContacts = {};
    emergencyContactName = '';
    emergencyContactPhoneNumber = '';
    print("UserData reset");
  }

  void updateEmergencyContactName(String name){
    emergencyContactName = name;
    print("EM NAME UPDATED: $emergencyContactName");
  }

  void updateEmergencyContactPhoneNumber(String phoneNumber){
    emergencyContactPhoneNumber = phoneNumber;
    print("EM NUMBER UPDATED: $emergencyContactPhoneNumber");
  }

  // Methods to update properties
  void updatePhoneNumber(String newPhoneNumber) {
    phoneNumber = "+94$newPhoneNumber";
    print("Phone number updated: $phoneNumber");
  }

  void updateNotificationToken(String fcmToken){
    notificationToken = fcmToken;
    print("NOTIFICTION TOKEN in userData: $notificationToken");
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

  // void addEmergencyContact(String name, String phoneNumber) {
  //   emergencyContacts[name] = phoneNumber;
  //   print("Emergency contact added: $name - $phoneNumber");
  // }
}
