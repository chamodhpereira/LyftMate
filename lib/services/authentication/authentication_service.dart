import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lyft_mate/models/loggeduser.dart';
import 'package:provider/provider.dart';

import 'package:lyft_mate/models/user.dart';

import '../../models/signup_user.dart';
import '../../providers/user_provider.dart';


class AuthException implements Exception {
  final String message;

  AuthException(this.message);
}

class AuthenticationService extends ChangeNotifier{

  final FirebaseAuth _auth = FirebaseAuth.instance; // commented for mock testing in fb_test
  // FirebaseAuth _auth;
  // FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // AuthenticationService(this._auth);



  // // Add this setter method
  // set auth(FirebaseAuth firebaseAuth) {
  //   _auth = firebaseAuth;
  // }

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


  // Future<void> signUpWithEmailAndPassword(String email, String password) async {
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
  //     return;
  //   } catch (e) {
  //     debugPrint("error occurred when signing up: $e");
  //
  //     // If the exception is FirebaseAuthException, throw a custom AuthException
  //     if (e is FirebaseAuthException) {
  //       final errorMessage = e.message ?? 'An unexpected error occurred';
  //       throw AuthException(errorMessage);
  //     } else {
  //       // Throw other types of exceptions as they are
  //       rethrow;
  //     }
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

      return;
    } catch (e) {
      debugPrint("error occurred when signing up: $e");

      // If the exception is FirebaseAuthException, throw a custom AuthException
      if (e is FirebaseAuthException) {
        final errorMessage = e.message ?? 'An unexpected error occurred';
        throw AuthException(errorMessage);
      } else {
        // Throw other types of exceptions as they are
        rethrow;
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
        "ratings": 0.0,
        "reviews": [],
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
        'driversLicenseDocumentUrl' : "",
        "memberSince" : DateTime.now(),

      });
    } catch (e) {
      debugPrint("Failed to create user document: $e");
      rethrow;
    }
  }

  Future<bool> signInWithEmailAndPassword(BuildContext context, String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Fetch additional user details from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();

        // // Create a User object with the fetched user data
        // LoggedUser newUser = LoggedUser(
        //   userID: userDoc.id,
        //   firstName: userDoc['firstName'],
        //   // username: userDoc['username'],
        //   // dateOfBirth: userDoc['dateOfBirth'],
        //   // gender: userDoc['gender'],
        //   // messages: List<String>.from(userDoc['messages'] ?? []),
        //   // ridesBooked: List<String>.from(userDoc['ridesBooked'] ?? []),
        //   // ridesOffered: List<String>.from(userDoc['ridesOffered'] ?? []),
        // );
        //
        // // Update user data through UserProvider
        // Provider.of<UserProvider>(context, listen: false).updateUser(newUser);
        //
        // debugPrint('User instance hash code after signInWithEmailAndPassword: ${newUser.hashCode}');

        // Navigate to the next screen or perform any other action after successful login
        // Navigator.pushReplacementNamed(context, '/home');
        return true; // Return true if login is successful
      } else {
        return false; // Return false if login fails
      }
    } catch (e) {
      debugPrint("Failed to sign in: $e");
      return false; // Return false if login fails
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("Failed to sign out: $e");
      rethrow; // Re-throw the exception for handling in the UI if needed
    }
  }

  // Future<void> sendPasswordResetEmail(BuildContext context, String email) async {
  //   try {
  //     // Optional: Check user existence in Firestore or another database
  //     final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .where('email', isEqualTo: email)
  //         .get();
  //
  //     // If no user documents were found, handle this scenario as "user not found."
  //     if (userSnapshot.docs.isEmpty) {
  //       throw FirebaseAuthException(
  //         code: 'user-not-found',
  //         message: 'No account found with that email address.',
  //       );
  //     }
  //
  //     // If user found, proceed with password reset email
  //     await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text(
  //             'If this email is registered, you will receive a password reset email shortly.'),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     String errorMessage = 'Something went wrong. Please try again.';
  //
  //     // Provide meaningful error messages
  //     if (e.code == 'user-not-found') {
  //       errorMessage = 'No account found with that email address.';
  //     } else if (e.code == 'invalid-email') {
  //       errorMessage = 'The email address is not valid.';
  //     }
  //
  //     // Display error feedback
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(errorMessage),
  //         duration: const Duration(seconds: 3),
  //       ),
  //     );
  //   } catch (e) {
  //     // Handle unexpected errors
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('An unknown error occurred. Please try again.'),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //   }
  // }

  Future<bool> sendPasswordResetEmail(BuildContext context, String email) async {
    try {
      // Optionally, provide ActionCodeSettings for handling the redirect
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';

      // Handle specific FirebaseAuthException error codes
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with that email address.';
          break;
        case 'missing-android-pkg-name':
          errorMessage = 'Missing Android package name.';
          break;
        case 'missing-continue-uri':
          errorMessage = 'A continue URL must be provided.';
          break;
        case 'missing-ios-bundle-id':
          errorMessage = 'Missing iOS Bundle ID.';
          break;
        case 'invalid-continue-uri':
          errorMessage = 'The continue URL is invalid.';
          break;
        case 'unauthorized-continue-uri':
          errorMessage = 'The continue URL domain is not whitelisted.';
          break;
        default:
          errorMessage = 'An unknown error occurred.';
          break;
      }

      // Provide feedback through the UI
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      debugPrint(errorMessage);
      return false;

    } catch (e) {
      // Handle any other exceptions
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unknown error occurred. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      return false;
    }
  }



// Future<void> sendPasswordResetEmail(BuildContext context, String email) async {
  //   try {
  //     await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  //     // Provide feedback that the reset email has been sent (success path)
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('If this email is registered, you will receive a password reset email shortly.'),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     String errorMessage = 'Something went wrong. Please try again.';
  //
  //     // Customize error message based on Firebase exception codes
  //     if (e.code == 'user-not-found') {
  //       errorMessage = 'No account found with that email address.';
  //     } else if (e.code == 'invalid-email') {
  //       errorMessage = 'The email address is not valid bitvh.';
  //     }
  //
  //     // Display an error message to the user via SnackBar
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(errorMessage),
  //         duration: const Duration(seconds: 3),
  //       ),
  //     );
  //   } catch (e) {
  //     // Fallback for unexpected errors
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('An unknown error occurred. Please try again.'),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //   }
  // }



}
