import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lyft_mate/screens/profile/settings_screen.dart';
import 'package:lyft_mate/services/authentication_service.dart';
import 'models/user_profile.dart';


class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen> {

  final AuthenticationService authService = AuthenticationService();

  late User _currentUser;
  late Stream<DocumentSnapshot> _userProfileStream;
  late UserProfile userProfile;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _userProfileStream = FirebaseFirestore.instance.collection('users').doc(_currentUser.uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileSettingsScreen(userProfile: userProfile,),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userProfileStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User profile not found'));
          } else {
            userProfile = UserProfile.fromMap(snapshot.data!.data() as Map<String, dynamic>);
            debugPrint("user profile verified id: ${userProfile.governmentIdVerified}");
            debugPrint("user profile verified url: ${userProfile.governmentIdDocumentUrl}");
            debugPrint("user profile licesnse id: ${userProfile.driversLicenseVerified}");
            debugPrint("user profile verified url: ${userProfile.driversLicenseDocumentUrl}");

            // Check if _currentUser is null and return loading indicator if true

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: userProfile.profileImageUrl != null
                        ? NetworkImage(userProfile.profileImageUrl!)
                        : null, // Provide path to default user icon
                    child: userProfile.profileImageUrl == null ? const Icon(Icons.person, size: 55.0) : null,
                  ),

                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 30),
                      Text(
                        "${userProfile.firstName} ${userProfile.lastName}",
                        style: const TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        "${userProfile.ratings}",
                        // userRating.toStringAsFixed(1), // Show rating with one decimal point
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userProfile.bio,
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Verifications'),
                  const SizedBox(height: 10),
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
                  // ListTile(
                  //   leading: Icon(
                  //     _currentUser.emailVerified ? Icons.check_circle : Icons.cancel_outlined,
                  //     color: _currentUser.emailVerified ? Colors.green : Colors.red,
                  //   ),
                  //   title: const Text(
                  //     'Email Verified',
                  //     style: TextStyle(fontSize: 16),
                  //   ),
                  // ),
                  ListTile(
                    leading: Icon(
                      _currentUser.emailVerified ? Icons.check_circle : Icons.cancel_outlined,
                      color: _currentUser.emailVerified ? Colors.green : Colors.red,
                    ),
                    title: Row(
                      children: [
                        const Text(
                          'Email Verified',
                          style: TextStyle(fontSize: 16),
                        ),
                        if (!_currentUser.emailVerified)
                          TextButton(
                            onPressed: () async {
                              try {
                                await _currentUser.sendEmailVerification();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Verification email sent! Please check your email.',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                debugPrint('Error sending verification email: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to send verification email. Please try again later.'),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Verify Email',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20,),
                  const SectionHeader(title: 'Carpooling Stats'),
                  ListTile(
                    leading: const Icon(Icons.rocket_launch_outlined),
                    title: const Text('Rides Published'),
                    subtitle: Text('${userProfile.ridesPublished.length}'), // Replace with actual number of rides published
                  ),
                  ListTile(
                    leading: const Icon(Icons.book),
                    title: const Text('Rides Booked'),
                    subtitle: Text('${userProfile.ridesBooked.length}'), // Replace with actual number of rides booked
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Member Since'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(userProfile.memberSince)), // Replace with actual join date
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

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    super.key,
    required this.text,
    required this.verified,
    this.documentUrl,
    this.onDocumentUploaded,
  });

  @override
  VerificationItemState createState() => VerificationItemState();
}

class VerificationItemState extends State<VerificationItem> {
  bool isUploaded = false;
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
      Icon(

        widget.verified ? Icons.check_circle // If uploaded, show check mark
            :  (widget.documentUrl != null && widget.documentUrl!.isNotEmpty ? Icons.cloud_sync_outlined : Icons.cancel_outlined // Otherwise, show cancel icon
        ),
        color: widget.verified ? Colors.green // If uploaded, show check mark
            :  (widget.documentUrl != null && widget.documentUrl!.isNotEmpty ? Colors.green : Colors.red // Otherwise, show cancel icon
        ),

      ),
      title: Row(
        children: [
          // Text(
          //   widget.text,
          //   style: TextStyle(fontSize: 16),
          // ),
          // if (!widget.verified && (widget.documentUrl == null || widget.documentUrl!.isEmpty)) ...[
          //   SizedBox(width: 10),
          //   IconButton(
          //     icon: Icon(Icons.upload_file),
          //     onPressed: () async {
          //       FilePickerResult? result = await FilePicker.platform.pickFiles(
          //         withData: true,
          //         type: FileType.custom,
          //         allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
          //       );
          //       if (result != null) {
          //         String? documentUrl = await uploadDocument(result.files.first);
          //         var file = result?.files.first;
          //
          //         if (documentUrl != null) {
          //           widget.onDocumentUploaded?.call(documentUrl);
          //           setState(() {
          //             isUploaded = true;
          //           });
          //         } else {
          //           // Handle upload failure
          //         }
          //       }
          //     },
          //   ),
          Text(
            widget.text,
            style: const TextStyle(fontSize: 16),
          ),
          if (!widget.verified && (widget.documentUrl == null || widget.documentUrl!.isEmpty)) ...[
            const SizedBox(width: 10),
            isUploading
                ? const SizedBox(
              width: 8, // Adjust this width as needed
              height: 8, // Adjust this height as needed
              child: CircularProgressIndicator(),
            ) // Show circular progress indicator while uploading
                : IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () async {

                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  withData: true,
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
                );
                if (result != null) {
                  setState(() {
                    isUploading = true; // Set uploading state to true
                  });
                  String? documentUrl = await uploadDocument(result.files.first);
                  var file = result.files.first;

                  if (documentUrl != null) {
                    widget.onDocumentUploaded?.call(documentUrl);
                    setState(() {
                      isUploaded = true;
                    });
                  } else {
                    // Handle upload failure
                  }
                }
                setState(() {
                  isUploading = false; // Reset uploading state after upload is finished
                });
              },
            ),
          ],
          Visibility(
            visible: !widget.verified && (widget.documentUrl != null && widget.documentUrl!.isNotEmpty),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Text(
                  "Verification pending...",
                  style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          // if (isUploaded) ...[
          //   SizedBox(width: 10),
          //   Text('Verification Pending', style: TextStyle(fontSize: 14, color: Colors.grey)),
          // ],


          // if (widget.documentUrl != null && widget.documentUrl!.isNotEmpty) ...[
          //   SizedBox(width: 10),
          //   Text("Verification pending...", style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.7)),),
          //
          //   // TextButton(
          //   //   onPressed: () {
          //   //     // Implement logic to view/download the uploaded document
          //   //   },
          //   //   child: Text('View Document'),
          //   // ),
          // ],
        ],
      ),
    );
  }
}

Future<String?> uploadDocument(PlatformFile file) async {
  try {
    if (file.bytes == null) {
      debugPrint('File bytes are null.');
      return null;
    }

    Reference ref = FirebaseStorage.instance.ref().child('verification_documents').child(file.name);
    UploadTask uploadTask = ref.putData(file.bytes!);

    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    debugPrint('Error uploading document: $e');
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
