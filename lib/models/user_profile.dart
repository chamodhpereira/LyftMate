import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String firstName;
  final String email;
  final String bio;
  final bool governmentIdVerified;
  final String? governmentIdDocumentUrl;
  final bool driversLicenseVerified; // New field for driver's license verification
  final String? driversLicenseDocumentUrl; // New field for driver's license document URL
  final String? profileImageUrl; // New field for profile image URL

  UserProfile({
    required this.firstName,
    required this.email,
    required this.bio,
    required this.governmentIdVerified,
    this.governmentIdDocumentUrl,
    required this.driversLicenseVerified,
    this.driversLicenseDocumentUrl,
    this.profileImageUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      firstName: map['firstName'],
      email: map['email'],
      bio: map['bio'],
      governmentIdVerified: map['governmentIdVerified'] ?? false,
      governmentIdDocumentUrl: map['governmentIdDocumentUrl'],
      driversLicenseVerified: map['driversLicenseVerified'] ?? false,
      driversLicenseDocumentUrl: map['driversLicenseDocumentUrl'],
      profileImageUrl: map['profileImageUrl'], // New field for profile image URL
    );
  }
}

Future<UserProfile> fetchUserProfile() async {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (userProfileSnapshot.exists) {
    return UserProfile.fromMap(userProfileSnapshot.data() as Map<String, dynamic>);
  } else {
    throw Exception('User profile not found');
  }
}














// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class UserProfile {
//   final String firstName;
//   final String email;
//   final String bio;
//   final bool governmentIdVerified;
//   final String? governmentIdDocumentUrl;
//   final bool driversLicenseVerified; // New field for driver's license verification
//   final String? driversLicenseDocumentUrl; // New field for driver's license document URL
//
//   UserProfile({
//     required this.firstName,
//     required this.email,
//     required this.bio,
//     required this.governmentIdVerified,
//     this.governmentIdDocumentUrl,
//     required this.driversLicenseVerified,
//     this.driversLicenseDocumentUrl,
//   });
//
//   factory UserProfile.fromMap(Map<String, dynamic> map) {
//     return UserProfile(
//       firstName: map['firstName'],
//       email: map['email'],
//       bio: map['bio'],
//       governmentIdVerified: map['governmentIdVerified'] ?? false,
//       governmentIdDocumentUrl: map['governmentIdDocumentUrl'],
//       driversLicenseVerified: map['driversLicenseVerified'] ?? false,
//       driversLicenseDocumentUrl: map['driversLicenseDocumentUrl'],
//     );
//   }
// }
//
// Future<UserProfile> fetchUserProfile() async {
//   String? userId = FirebaseAuth.instance.currentUser?.uid;
//   DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
//
//   if (userProfileSnapshot.exists) {
//     return UserProfile.fromMap(userProfileSnapshot.data() as Map<String, dynamic>);
//   } else {
//     throw Exception('User profile not found');
//   }
// }







