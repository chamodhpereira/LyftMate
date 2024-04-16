import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lyft_mate/editprofile_screen.dart';
import 'package:lyft_mate/services/authentication_service.dart';
import 'models/user_profile.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  final AuthenticationService authService = AuthenticationService();

  late Future<UserProfile> _futureUserProfile;
  late User _currentUser;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _futureUserProfile = fetchUserProfile();
  }

  Future<UserProfile> fetchUserProfile() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    print("user DATAAAAAA: $_currentUser");

    if (userProfileSnapshot.exists) {
      return UserProfile.fromMap(userProfileSnapshot.data() as Map<String, dynamic>);
      // _profileImageUrl = userProfile.profileImageUrl;
    } else {
      throw Exception('User profile not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileEditScreen(),
                ),
              ).then((_) {
                setState(() {
                  _futureUserProfile = fetchUserProfile();
                });
              });
            },
          ),
          IconButton( // Added Sign-out Button
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: _futureUserProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            UserProfile userProfile = snapshot.data!;
            print("user profile verified id: ${userProfile.governmentIdVerified}");
            print("user profile verified url: ${userProfile.governmentIdDocumentUrl}");
            print("user profile licesnse id: ${userProfile.driversLicenseVerified}");
            print("user profile verified url: ${userProfile.driversLicenseDocumentUrl}");

            // Check if _currentUser is null and return loading indicator if true

            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: userProfile.profileImageUrl != null
                        ? NetworkImage(userProfile.profileImageUrl!)
                        : null, // Provide path to default user icon
                    child: userProfile.profileImageUrl == null ? Icon(Icons.person, size: 55.0) : null,
                  ),
                  // CircleAvatar(
                  //   radius: 70,
                  //   child: Icon(
                  //     Icons.person,
                  //     size: 55.0,
                  //   ),
                  // ),
                  SizedBox(height: 20),
                  // Text(
                  //   "${userProfile.firstName}",
                  //   style: const TextStyle(
                  //       fontSize: 24, fontWeight: FontWeight.bold),
                  // ),
                  // SizedBox(height: 10),
                  // Show user rating below the name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${userProfile.firstName} ${userProfile.firstName}",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 5),
                      Text(
                        "4.0",
                        // userRating.toStringAsFixed(1), // Show rating with one decimal point
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${userProfile.bio}',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  SectionHeader(title: 'Verifications'),
                  SizedBox(height: 10),
                  VerificationItem(
                    text: 'Government ID',
                    verified: userProfile.governmentIdVerified,
                    documentUrl: userProfile.governmentIdDocumentUrl,
                    onDocumentUploaded: (documentUrl) async {
                      String? userId = FirebaseAuth.instance.currentUser?.uid;
                      await FirebaseFirestore.instance.collection('users').doc(userId).update({'governmentIdDocumentUrl': documentUrl});
                    },
                  ),
                  VerificationItem(
                    text: 'Driver\'s License',
                    verified: userProfile.driversLicenseVerified,
                    documentUrl: userProfile.driversLicenseDocumentUrl,
                    onDocumentUploaded: (documentUrl) async {
                      String? userId = FirebaseAuth.instance.currentUser?.uid;
                      await FirebaseFirestore.instance.collection('users').doc(userId).update({'driversLicenseDocumentUrl': documentUrl});
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      _currentUser?.emailVerified ?? false ? Icons.check_circle : Icons.cancel_outlined,
                      color: _currentUser?.emailVerified ?? false ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      'Email Verified',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 20,),
                  ListTile(
                    leading: Icon(Icons.rocket_launch_outlined),
                    title: Text('Rides Published'),
                    subtitle: Text('10'), // Replace with actual number of rides published
                  ),
                  ListTile(
                    leading: Icon(Icons.book),
                    title: Text('Rides Booked'),
                    subtitle: Text('5'), // Replace with actual number of rides booked
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Member Since'),
                    subtitle: Text('January 2022'), // Replace with actual join date
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class VerificationItem extends StatefulWidget {
  final String text;
  final bool verified;
  final String? documentUrl;
  final Function(String)? onDocumentUploaded;

  const VerificationItem({
    required this.text,
    required this.verified,
    this.documentUrl,
    this.onDocumentUploaded,
  });

  @override
  _VerificationItemState createState() => _VerificationItemState();
}

class _VerificationItemState extends State<VerificationItem> {
  bool isUploaded = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        // widget.verified ? Icons.check_circle : Icons.cancel,
        // color: widget.verified ? Colors.green : Colors.red,
        isUploaded
            ? Icons.check_circle // If uploaded, show check mark
            : (widget.verified
            ? Icons.check_circle // If verified, show check mark
            : (widget.documentUrl != null && widget.documentUrl!.isNotEmpty
            ? Icons.cloud_sync_outlined // If documentUrl is not empty, show check mark
            : Icons.cancel_outlined // Otherwise, show cancel icon
        )
        ),
        color: isUploaded // Set color based on upload status
            ? Colors.green
            : (widget.verified // If not uploaded, set color based on verification status
            ? Colors.green
            : (widget.documentUrl != null && widget.documentUrl!.isNotEmpty
            ? Colors.green // If documentUrl is not empty, set color to green
            : Colors.red // Otherwise, set color to red
        )
        ),

      ),
      title: Row(
        children: [
          Text(
            widget.text,
            style: TextStyle(fontSize: 16),
          ),
          if (!widget.verified && (widget.documentUrl == null || widget.documentUrl!.isEmpty) && !isUploaded) ...[
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.upload_file),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  withData: true,
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
                );
                if (result != null) {
                  String? documentUrl = await uploadDocument(result.files.first);
                  var file = result?.files.first;

                  if (documentUrl != null) {
                    widget.onDocumentUploaded?.call(documentUrl);
                    setState(() {
                      isUploaded = true;
                    });
                  } else {
                    // Handle upload failure
                  }
                }
              },
            ),
          ],
          if (isUploaded) ...[
            SizedBox(width: 10),
            Text('Verification Pending', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
          if (widget.documentUrl != null && widget.documentUrl!.isNotEmpty) ...[
            SizedBox(width: 10),
            Text("Verification pending...", style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.7)),),
            // TextButton(
            //   onPressed: () {
            //     // Implement logic to view/download the uploaded document
            //   },
            //   child: Text('View Document'),
            // ),
          ],
        ],
      ),
    );
  }
}

Future<String?> uploadDocument(PlatformFile file) async {
  try {
    if (file.bytes == null) {
      print('File bytes are null.');
      return null;
    }

    Reference ref = FirebaseStorage.instance.ref().child('verification_documents').child(file.name!);
    UploadTask uploadTask = ref.putData(file.bytes!);

    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print('Error uploading document: $e');
    return null;
  }
}








//// ---- wrokingggg government id upload
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lyft_mate/editprofile_screen.dart';
// import 'models/user_profile.dart';
//
// class UserProfileScreen extends StatefulWidget {
//   @override
//   _UserProfileScreenState createState() => _UserProfileScreenState();
// }
//
// class _UserProfileScreenState extends State<UserProfileScreen> {
//   late Future<UserProfile> _futureUserProfile;
//
//   @override
//   void initState() {
//     super.initState();
//     _futureUserProfile = fetchUserProfile();
//   }
//
//   Future<UserProfile> fetchUserProfile() async {
//     String? userId = FirebaseAuth.instance.currentUser?.uid;
//     DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
//
//     if (userProfileSnapshot.exists) {
//       return UserProfile.fromMap(userProfileSnapshot.data() as Map<String, dynamic>);
//     } else {
//       throw Exception('User profile not found');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('User Profile'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.edit),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ProfileEditScreen(),
//                 ),
//               ).then((_) {
//                 setState(() {
//                   _futureUserProfile = fetchUserProfile();
//                 });
//               });
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder<UserProfile>(
//         future: _futureUserProfile,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             UserProfile userProfile = snapshot.data!;
//             print("user profile verified id: ${userProfile.governmentIdVerified}");
//             print("user profile verified url: ${userProfile.governmentIdDocumentUrl}");
//             return SingleChildScrollView(
//               padding: EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 70,
//                     child: Icon(
//                       Icons.person,
//                       size: 55.0,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "${userProfile.firstName}",
//                     style: const TextStyle(
//                         fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     '${userProfile.bio}',
//                     style: TextStyle(fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 20),
//                   SectionHeader(title: 'Verifications'),
//                   SizedBox(height: 10),
//                   VerificationItem(
//                     text: 'Government ID',
//                     governmentIdVerified: userProfile.governmentIdVerified,
//                     governmentIdDocumentUrl: userProfile.governmentIdDocumentUrl,
//                     onDocumentUploaded: (documentUrl) async {
//                       String? userId = FirebaseAuth.instance.currentUser?.uid;
//                       await FirebaseFirestore.instance.collection('users').doc(userId).update({'governmentIdDocumentUrl': documentUrl});
//                     },
//                   ),
//                   // i need a another verification for drivers license
//                   // VerificationItem(text: text, governmentIdVerified: governmentIdVerified)
//                 ],
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
//
// class SectionHeader extends StatelessWidget {
//   final String title;
//
//   const SectionHeader({required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Text(
//         title,
//         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }
//
// class VerificationItem extends StatefulWidget {
//   final String text;
//   final bool governmentIdVerified;
//   final String? governmentIdDocumentUrl;
//   final Function(String)? onDocumentUploaded;
//
//   const VerificationItem({
//     required this.text,
//     required this.governmentIdVerified,
//     this.governmentIdDocumentUrl,
//     this.onDocumentUploaded,
//   });
//
//   @override
//   _VerificationItemState createState() => _VerificationItemState();
// }
//
// class _VerificationItemState extends State<VerificationItem> {
//   bool isUploaded = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Icon(
//         widget.governmentIdVerified ? Icons.check_circle : Icons.cancel,
//         color: widget.governmentIdVerified ? Colors.green : Colors.red,
//       ),
//       title: Row(
//         children: [
//           Text(
//             widget.text,
//             style: TextStyle(fontSize: 16),
//           ),
//           if (!widget.governmentIdVerified && (widget.governmentIdDocumentUrl == null || widget.governmentIdDocumentUrl!.isEmpty) && !isUploaded) ...[
//             SizedBox(width: 10),
//             IconButton(
//               icon: Icon(Icons.upload_file),
//               onPressed: () async {
//                 FilePickerResult? result = await FilePicker.platform.pickFiles(
//                   withData: true,
//                   type: FileType.custom,
//                   allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
//                   // allowedMimeType: ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'image/png', 'image/jpeg'],
//                 );
//                 if (result != null) {
//                   String? documentUrl = await uploadDocument(result.files.first);
//                   var file = result?.files.first;
//
//                   print(file?.name);
//                   print(file?.bytes);
//                   print(file?.size);
//                   print(file?.extension);
//                   print(file?.path);
//
//                   if (documentUrl != null) {
//                     widget.onDocumentUploaded?.call(documentUrl);
//                     setState(() {
//                       isUploaded = true;
//                     });
//                   } else {
//                     // Handle upload failure
//                   }
//                 }
//               },
//             ),
//           ],
//           if (isUploaded) ...[
//             SizedBox(width: 10),
//             Text('Verification Pending', style: TextStyle(fontSize: 14, color: Colors.grey)),
//           ],
//           if (widget.governmentIdDocumentUrl != null && widget.governmentIdDocumentUrl!.isNotEmpty) ...[
//             SizedBox(width: 10),
//             TextButton(
//               onPressed: () {
//                 // Implement logic to view/download the uploaded document
//               },
//               child: Text('View Document'),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// Future<String?> uploadDocument(PlatformFile file) async {
//   try {
//     if (file.bytes == null) {
//       print('File bytes are null.');
//       return null;
//     }
//
//     Reference ref = FirebaseStorage.instance.ref().child('government_ids').child(file.name!);
//     UploadTask uploadTask = ref.putData(file.bytes!);
//
//     TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
//     String downloadUrl = await taskSnapshot.ref.getDownloadURL();
//     return downloadUrl;
//   } catch (e) {
//     print('Error uploading document: $e');
//     return null;
//   }
// }




// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:lyft_mate/editprofile_screen.dart';
//
// import 'models/user_profile.dart';
//
// class UserProfileScreen extends StatefulWidget {
//   @override
//   _UserProfileScreenState createState() => _UserProfileScreenState();
// }
//
// class _UserProfileScreenState extends State<UserProfileScreen> {
//   late Future<UserProfile> _futureUserProfile;
//
//   @override
//   void initState() {
//     super.initState();
//     _futureUserProfile = fetchUserProfile();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('User Profile'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.edit),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       ProfileEditScreen(), // Navigate to the edit profile screen
//                 ),
//               ).then((_) {
//                 // Refresh user profile data after editing
//                 setState(() {
//                   _futureUserProfile = fetchUserProfile();
//                 });
//               });
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder<UserProfile>(
//         future: _futureUserProfile,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             UserProfile userProfile = snapshot.data!;
//             // return Padding(
//             //   padding: EdgeInsets.all(16.0),
//             //   child: Column(
//             //     crossAxisAlignment: CrossAxisAlignment.start,
//             //     children: [
//             //       Text(
//             //         'Username: ${userProfile.firstName}',
//             //         style: TextStyle(fontSize: 18.0),
//             //       ),
//             //       SizedBox(height: 8.0),
//             //       Text(
//             //         'Email: ${userProfile.email}',
//             //         style: TextStyle(fontSize: 18.0),
//             //       ),
//             //       SizedBox(height: 8.0),
//             //       Text(
//             //         'Bio: ${userProfile.bio}',
//             //         style: TextStyle(fontSize: 18.0),
//             //       ),
//             //     ],
//             //   ),
//             // );
//             return SingleChildScrollView(
//               padding: EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 70,
//                     child: Icon(
//                       Icons.person,
//                       size: 55.0,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "${userProfile.firstName}",
//                     style: const TextStyle(
//                         fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     '${userProfile.bio}',
//                     style: TextStyle(fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 20),
//                   SectionHeader(title: 'Ride Preferences'),
//                   SizedBox(height: 10),
//                   ListTile(
//                     leading: Icon(Icons.pets),
//                     title: Text('Comfortable with pets'),
//                   ),
//                   ListTile(
//                     leading: Icon(Icons.smoking_rooms),
//                     title: Text('Non-smoker'),
//                   ),
//                   ListTile(
//                     leading: Icon(Icons.schedule),
//                     title: Text('Early morning rides preferred'),
//                   ),
//                   ListTile(
//                     leading: Icon(Icons.chat),
//                     title: Text('Friendly and talkative'),
//                   ),
//                   SizedBox(height: 20),
//                   SectionHeader(title: 'Verifications'),
//                   SizedBox(height: 10),
//                   VerificationItem(
//                     text: 'Government ID',
//                     verified: false,
//                     uploadAction: () async {
//                       FilePickerResult? result =
//                           await FilePicker.platform.pickFiles(
//                         type: FileType.custom,
//                         allowedExtensions: ['pdf', 'doc', 'docx'],
//                       );
//
//                       if (result != null) {
//                         // Implement functionality to handle the selected file
//                         print('File picked: ${result.files.first.name}');
//                         // Implement further actions such as upload or processing
//                       }
//                     },
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.schedule),
//                       SizedBox(width: 5),
//                       Text(
//                         '12 Rides Published',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 5),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.person),
//                       SizedBox(width: 5),
//                       Text(
//                         'Member since March 2020',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
//
// class SectionHeader extends StatelessWidget {
//   final String title;
//
//   const SectionHeader({required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Text(
//         title,
//         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }
//
// class VerificationItem extends StatefulWidget {
//   final String text;
//   final bool verified;
//   final VoidCallback? uploadAction;
//
//   const VerificationItem(
//       {required this.text, required this.verified, this.uploadAction});
//
//   @override
//   _VerificationItemState createState() => _VerificationItemState();
// }
//
// class _VerificationItemState extends State<VerificationItem> {
//   bool isUploaded = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Icon(
//         widget.verified ? Icons.check_circle : Icons.cancel,
//         color: widget.verified ? Colors.green : Colors.red,
//       ),
//       title: Row(
//         children: [
//           Text(
//             widget.text,
//             style: TextStyle(fontSize: 16),
//           ),
//           if (!widget.verified &&
//               widget.uploadAction != null &&
//               !isUploaded) ...[
//             SizedBox(width: 10),
//             IconButton(
//               icon: Icon(Icons.upload_file),
//               onPressed: () {
//                 widget.uploadAction!();
//                 setState(() {
//                   isUploaded = true;
//                 });
//               },
//             ),
//           ],
//           if (isUploaded) ...[
//             SizedBox(width: 10),
//             Text('Verification Pending',
//                 style: TextStyle(fontSize: 14, color: Colors.grey)),
//           ],
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:lyft_mate/models/loggeduser.dart';
// import 'package:lyft_mate/providers/user_provider.dart';
// import 'package:lyft_mate/services/authentication_service.dart';
// import 'package:provider/provider.dart';
// import 'models/user.dart';
//
// // class UserProfileScreen extends StatelessWidget {
// //   UserProfileScreen({Key? key});
// //
// //
// //   AuthenticationService authService = AuthenticationService();
// //
// //   Widget build(BuildContext context) {
// //
// //     final userProvider = Provider.of<UserProvider>(context); // Access UserProvider
// //     final user = userProvider.user;
// //
// //     // Print the hash code of the user instance
// //     print('User instance hash code: ${user.hashCode}');
// //
// //     return Scaffold(
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             Text('UID: ${user.userID}'),
// //             Text('Email: ${user.firstName}'),
// //             ElevatedButton(
// //               onPressed: () async {
// //                 await authService.signOut();
// //               },
// //               child: Text("signout"),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// class UserProfileScreen extends StatelessWidget {
//   UserProfileScreen({Key? key});
//
//   AuthenticationService authService = AuthenticationService();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // If you want to display user information, you need to retrieve it first
//             // For example, you can retrieve it from your AuthenticationService
//             // Text('UID: ${user.userID}'),
//             // Text('Email: ${user.firstName}'),
//             ElevatedButton(
//               onPressed: () async {
//                 await authService.signOut();
//               },
//               child: Text("Sign Out"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
