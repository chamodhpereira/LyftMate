import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String bio;
  final double ratings;
  final List<String> reviews;
  final bool governmentIdVerified;
  final String? governmentIdDocumentUrl;
  final bool driversLicenseVerified;
  final String? driversLicenseDocumentUrl;
  final String? profileImageUrl;
  final List<dynamic> ridesPublished; // Added field
  final List<dynamic> ridesBooked; // Added field
  final DateTime memberSince; // Added field

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.bio,
    required this.ratings,
    required this.reviews,
    required this.governmentIdVerified,
    this.governmentIdDocumentUrl,
    required this.driversLicenseVerified,
    this.driversLicenseDocumentUrl,
    this.profileImageUrl,
    required this.ridesPublished,
    required this.ridesBooked,
    required this.memberSince,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      bio: map['bio'],
      ratings: (map['ratings'] ?? 0).toDouble(),
      reviews: (map['reviews'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      governmentIdVerified: map['governmentIdVerified'] ?? false,
      governmentIdDocumentUrl: map['governmentIdDocumentUrl'],
      driversLicenseVerified: map['driversLicenseVerified'] ?? false,
      driversLicenseDocumentUrl: map['driversLicenseDocumentUrl'],
      profileImageUrl: map['profileImageUrl'],
      ridesPublished: map['ridesPublished'] ?? [],
      ridesBooked: map['ridesBooked'] ?? [],
      memberSince: (map['memberSince'] as Timestamp).toDate(),
    );
  }

  UserProfile updateFromMap(Map<String, dynamic> map) {
    return UserProfile(
      firstName: map['firstName'] ?? this.firstName,
      lastName: map['lastName'] ?? this.lastName,
      email: map['email'] ?? this.email,
      bio: map['bio'] ?? this.bio,
      ratings: (map['ratings'] ?? this.ratings).toDouble(),
      reviews: (map['reviews'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? this.reviews,
      governmentIdVerified: map['governmentIdVerified'] ?? this.governmentIdVerified,
      governmentIdDocumentUrl: map['governmentIdDocumentUrl'] ?? this.governmentIdDocumentUrl,
      driversLicenseVerified: map['driversLicenseVerified'] ?? this.driversLicenseVerified,
      driversLicenseDocumentUrl: map['driversLicenseDocumentUrl'] ?? this.driversLicenseDocumentUrl,
      profileImageUrl: map['profileImageUrl'] ?? this.profileImageUrl,
      ridesPublished: map['ridesPublished'] ?? this.ridesPublished,
      ridesBooked: map['ridesBooked'] ?? this.ridesBooked,
      memberSince: map['memberSince'] ?? this.memberSince,
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







