import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
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
  // Future<void> signUpWithEmailAndPassword(String email, String password) async {
  //   // Call Firebase authentication APIs to sign up the user
  //   // For example:
  //   // await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  //   // Handle any errors and exceptions
  // }
  //
  // Future<void> signInWithEmailAndPassword(String email, String password) async {
  //   // Call Firebase authentication APIs to sign in the user
  //   // For example:
  //   // await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  //   // Handle any errors and exceptions
  // }
  //
  // Future<void> signOut() async {
  //   // Call Firebase authentication APIs to sign out the user
  //   // For example:
  //   // await FirebaseAuth.instance.signOut();
  //   // Handle any errors and exceptions
  // }
}