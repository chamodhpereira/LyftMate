import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:lyft_mate/models/loggeduser.dart';
import 'package:provider/provider.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // // Store additional user details in Firestore
      // await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      //   'firstName': firstNameController.text,
      //   'lastName': secondNameController.text,
      //   // Add more user details as needed
      // });

      // Navigate to the next screen or perform any other action after successful signup
      // } on FirebaseAuthException catch (e) {
      //   if (e.code == 'weak-password') {
      //     print('The password provided is too weak.');
      //   } else if (e.code == 'email-already-in-use') {
      //     print('The account already exists for that email.');
      //   }
      // Show relevant error messages to the user
    } catch (e) {
      print(e);
      // Handle other exceptions
    }
  }

  Future<bool> signInWithEmailAndPassword(BuildContext context, String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update user details in LoggedUser model
        LoggedUser loggedUser = Provider.of<LoggedUser>(context, listen: false);
        print("WTFFFFFFFFFFFFFFFFFFFFFFFFFFFFQERRRR");
        print('signin methoddddd- User instance hash code: ${loggedUser.hashCode}');
        loggedUser.updateUID(userCredential.user!.uid);
        loggedUser.updateEmail(userCredential.user!.email ?? "");


        // Navigate to the next screen or perform any other action after successful login
        return true; // Return true if login is successful
      } else {
        return false; // Return false if login fails
      }
    } catch (e) {
      print("Failed to sign in: $e");
      return false; // Return false if login fails
    }
  }


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