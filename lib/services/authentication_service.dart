import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:lyft_mate/models/loggeduser.dart';
import 'package:provider/provider.dart';

import 'package:lyft_mate/models/user.dart';

import '../models/signup_user.dart';
import '../providers/user_provider.dart';


class AuthException implements Exception {
  final String message;

  AuthException(this.message);
}

class AuthenticationService extends ChangeNotifier{




  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton instance of SignupUserData
  final SignupUserData _signupUserData = SignupUserData();
  var verificationID = "";

  Future<void> phoneAuthentication (String phoneNo) async{
    _auth.verifyPhoneNumber(
      phoneNumber: phoneNo,
      verificationCompleted: (credential) async{
        await _auth.signInWithCredential(credential);
        // _navigateToNextScreen();
      },
      codeSent: (verificationId, resendToken) {
          verificationID = verificationId;
          print("verificationIDDDD: $verificationId");
      },
      codeAutoRetrievalTimeout: (verificationId) {
        verificationID = verificationId;
      },
      verificationFailed: (e) {
        print("FAAAAAAAAAAAAILLLEDDDDDDD TTOOOOOOO");
        print(e);
      },
    );
  }

  Future<bool> verifyOTP(String otp) async {
    if (verificationID == null) {
      print("Verification ID is null. Unable to verify OTP.");
      return false;
    }
    print("verification id: $verificationID");
    print("Entered OTP: $otp");

    try {
      var credentials = await _auth.signInWithCredential(
          PhoneAuthProvider.credential(verificationId: verificationID, smsCode: otp));
      // _navigateToNextScreen();
      return credentials.user != null ? true : false;
    } catch (e) {
      print("Failed to verify OTP: $e");
      return false;
      // Handle verification failure
    }
  }

  // Method to sign up with email and password  -- return bool
  // Future<bool> signUpWithEmailAndPassword(String email, String password) async {
  //   try {
  //     // Create user with email and password
  //     final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //
  //     // Create user document based on signup data
  //     await createUserDocument(userCredential.user!.uid);
  //
  //     // Reset SignupUserData after successful signup
  //     _signupUserData.reset();
  //
  //     return true;
  //   } catch (e) {
  //     print(e);
  //     // Handle signup failure
  //     return false;
  //   }
  // }
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document based on signup data
      await createUserDocument(userCredential.user!.uid);

      // Reset SignupUserData after successful signup
      _signupUserData.reset();

      return null; // Return null to indicate success
    } catch (e) {
      print("errrrrrrrrrorrrrr in method: $e");


      // Return the error message to be handled in the calling code
      // return e.toString();

      // If the exception is FirebaseAuthException, throw a custom AuthException
      if (e is FirebaseAuthException) {
        final errorMessage = e.message ?? 'An unexpected error occurred';
        throw AuthException(errorMessage);
      } else {
        // Throw other types of exceptions as they are
        throw e;
      }
    }
  }



  // Method to create user document in Firestore
  Future<void> createUserDocument(String userId) async {
    try {

      Map<String, String> emergencyContacts = {_signupUserData.emergencyContactName : _signupUserData.emergencyContactPhoneNumber};

      await _firestore.collection('users').doc(userId).set({
        'firstName': _signupUserData.firstName,
        'lastName': _signupUserData.lastName,
        'gender': _signupUserData.selectedGender.toString(), // Convert enum to string
        'email': _signupUserData.email,
        'dob': _signupUserData.dob.toIso8601String(),
        'bio': "",
        'phoneNumber': _signupUserData.phoneNumber,
        'notificationToken': _signupUserData.notificationToken,
        'vehicles': [],
        'emergencyContacts' : emergencyContacts,
        'ridesPublished': [],
        'ridesBooked': [],
        'preferences': [],
        'governmentIdVerified': false,
        'governmentIdDocumentUrl' : "",
        'driversLicenseVerified': false,
        'driversLicenseDocumentUrl' : ""

        // Add more fields as needed
      });
    } catch (e) {
      print("Failed to create user document: $e");
      // Handle document creation failure
    }
  }

// --------------worjinggggggggggg-
  // Future<void> signUpWithEmailAndPassword(String email, String password) async {
  //   try {
  //     final UserCredential userCredential =
  //         await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     print("USERRRRRR IDDDDDDDDD: ${userCredential.user!.uid}");
  //     // Store additional user details in Firestore
  //     await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
  //       'firstName': newUser.firstName,
  //       'lastName': newUser.lastName,
  //       // Add more user details as needed
  //     });
  //
  //     // Navigate to the next screen or perform any other action after successful signup
  //     // } on FirebaseAuthException catch (e) {
  //     //   if (e.code == 'weak-password') {
  //     //     print('The password provided is too weak.');
  //     //   } else if (e.code == 'email-already-in-use') {
  //     //     print('The account already exists for that email.');
  //     //   }
  //     // Show relevant error messages to the user
  //   } catch (e) {
  //     print(e);
  //     // Handle other exceptions
  //   }
  // }


  Future<bool> signInWithEmailAndPassword(BuildContext context, String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Fetch additional user details from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();

        // Create a User object with the fetched user data
        LoggedUser newUser = LoggedUser(
          userID: userDoc.id,
          firstName: userDoc['firstName'],
          // username: userDoc['username'],
          // dateOfBirth: userDoc['dateOfBirth'],
          // gender: userDoc['gender'],
          // messages: List<String>.from(userDoc['messages'] ?? []),
          // ridesBooked: List<String>.from(userDoc['ridesBooked'] ?? []),
          // ridesOffered: List<String>.from(userDoc['ridesOffered'] ?? []),
        );

        // Update user data through UserProvider
        Provider.of<UserProvider>(context, listen: false).updateUser(newUser);

        print('User instance hash code after signInWithEmailAndPassword: ${newUser.hashCode}');

        // Navigate to the next screen or perform any other action after successful login
        // Navigator.pushReplacementNamed(context, '/home');
        return true; // Return true if login is successful
      } else {
        return false; // Return false if login fails
      }
    } catch (e) {
      print("Failed to sign in: $e");
      return false; // Return false if login fails
    }
  }

  // Future<bool> signInWithEmailAndPassword(
  //     BuildContext context, String email, String password) async {
  //   try {
  //     final UserCredential userCredential =
  //         await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //
  //     if (userCredential.user != null) {
  //       // Update user details in LoggedUser model
  //       UserM loggedUser = Provider.of<UserM>(context, listen: false);
  //       print("WTFFFFFFFFFFFFFFFFFFFFFFFFFFFFQERRRR");
  //       print(
  //           'signin methoddddd- User instance hash code: ${loggedUser.hashCode}');
  //       loggedUser.updateUID(userCredential.user!.uid);
  //       loggedUser.updateEmail(userCredential.user!.email ?? "");
  //
  //       // Navigate to the next screen or perform any other action after successful login
  //       return true; // Return true if login is successful
  //     } else {
  //       return false; // Return false if login fails
  //     }
  //   } catch (e) {
  //     print("Failed to sign in: $e");
  //     return false; // Return false if login fails
  //   }
  // }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Failed to sign out: $e");
      throw e; // Re-throw the exception for handling in the UI if needed
    }
  }
}

// class AuthenticationService {
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   final LoggedUser _user = LoggedUser(); // Instance of your User class
//
//   LoggedUser get currentUser => _user;
//
//   Future<void> signUpWithEmailAndPassword(String email, String password) async {
//     try {
//       final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       // // Store additional user details in Firestore
//       // await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
//       //   'firstName': firstNameController.text,
//       //   'lastName': secondNameController.text,
//       //   // Add more user details as needed
//       // });
//
//       // Navigate to the next screen or perform any other action after successful signup
//     // } on FirebaseAuthException catch (e) {
//     //   if (e.code == 'weak-password') {
//     //     print('The password provided is too weak.');
//     //   } else if (e.code == 'email-already-in-use') {
//     //     print('The account already exists for that email.');
//     //   }
//       // Show relevant error messages to the user
//     } catch (e) {
//       print(e);
//       // Handle other exceptions
//     }
//   }
//
//   Future<bool> signInWithEmailAndPassword(String email, String password) async {
//     try {
//       final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       if (userCredential.user != null) {
//         // Update user object with user's information
//         _user.updateUID(userCredential.user!.uid);
//         _user.updateEmail(userCredential.user!.email ?? "");
//         // Add more updates as needed
//
//         print('signin methoddddd- User instance hash code: ${_user.hashCode}');
//
//         return true; // Return true if login is successful
//       } else {
//         return false; // Return false if login fails
//       }
//     } catch (e) {
//       print("Failed to sign in: $e");
//       return false; // Return false if login fails
//     }
//   }
//
//
//   // Future<void> signInWithEmailAndPassword(String email, String password) async {
//   //   try {
//   //     final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//   //       email: email,
//   //       password: password,
//   //     );
//   //
//   //     // If login is successful, userCredential.user will contain the logged-in user
//   //     // You can perform any additional actions here, such as storing user data or navigating to a new screen
//   //   } catch (e) {
//   //     print("Failed to sign in with email and password: $e");
//   //     // Handle the sign-in failure, such as displaying an error message to the user
//   //     throw e; // Re-throw the exception for handling in the UI if needed
//   //   }
//   // }
//
//   Future<void> signOut() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//     } catch (e) {
//       print("Failed to sign out: $e");
//       throw e; // Re-throw the exception for handling in the UI if needed
//     }
//   }
// }
