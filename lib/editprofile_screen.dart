import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'models/user_profile.dart';

class ProfileEditScreen extends StatefulWidget {
  final UserProfile userProfile;

  const ProfileEditScreen({super.key, required this.userProfile});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _profileImageUrl;
  File? _imageFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.userProfile.firstName;
    _lastNameController.text = widget.userProfile.lastName;
    _bioController.text = widget.userProfile.bio;
    _profileImageUrl = widget.userProfile.profileImageUrl;
    _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _submitForm();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (_profileImageUrl != null || _imageFile != null) ...[
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider<Object>
                          : _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                                  as ImageProvider<Object>
                              : null,
                      child: _imageFile == null && _profileImageUrl == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: -10,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            size: 28, color: Colors.blue),
                        onPressed: _updateProfileImage,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // TextFormField(
              //   controller: _usernameController,
              //   decoration: const InputDecoration(labelText: 'Username'),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter your username';
              //     }
              //     return null;
              //   },
              // ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),  // Spacing between the fields
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    labelText: 'New Password (leave blank to keep current)'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () {
              //     if (_formKey.currentState!.validate()) {
              //       _submitForm();
              //     }
              //   },
              //   child: const Text('Save Changes'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateProfileImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _profileImageUrl = null;
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? downloadUrl;

      if (_imageFile != null) {
        String imagePath = 'users/${user!.uid}/profile_image.jpg';
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref()
            .child(imagePath)
            .putFile(_imageFile!);
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      Map<String, dynamic> updateData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'bio': _bioController.text,
      };

      if (downloadUrl != null) {
        updateData['profileImageUrl'] = downloadUrl;
      }

      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update(updateData);

      if (_emailController.text != user.email) {
        await user.updateEmail(_emailController.text);
      }

      if (_passwordController.text.isNotEmpty) {
        await user.updatePassword(_passwordController.text);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// import 'models/user_profile.dart';
//
// class ProfileEditScreen extends StatefulWidget {
//
//   final UserProfile userProfile;
//
//   const ProfileEditScreen({super.key, required this.userProfile});
//
//
//   @override
//   _ProfileEditScreenState createState() => _ProfileEditScreenState();
// }
//
// class _ProfileEditScreenState extends State<ProfileEditScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _bioController = TextEditingController();
//   // late TextEditingController _bioController;
//   String? _profileImageUrl; // New variable to store profile image URL
//   File? _imageFile;
//
//   final ImagePicker picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     // _usernameController = TextEditingController();
//     // _bioController = TextEditingController();
//     // Assume fetchUserProfile returns a Future<UserProfile>
//     // fetchUserProfile().then((userProfile) {
//     //   setState(() {
//     //     _usernameController.text = userProfile.firstName;
//     //     _bioController.text = userProfile.bio;
//     //     _profileImageUrl = userProfile.profileImageUrl;
//     //   });
//     // });
//
//     _usernameController.text = widget.userProfile.firstName;
//     _bioController.text = widget.userProfile.bio;
//     _profileImageUrl = widget.userProfile.profileImageUrl;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Profile'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 60,
//                     backgroundImage: _profileImageUrl != null
//                         ? NetworkImage(_profileImageUrl!)
//                         : (_imageFile != null
//                         ? FileImage(_imageFile!) as ImageProvider<Object>
//                         : null),
//                     child: _profileImageUrl == null && _imageFile == null
//                         ? _getUserIcon()
//                         : null,
//                   ),
//                   // CircleAvatar(
//                   //   radius: 60,
//                   //   backgroundImage: _profileImageUrl != null
//                   //       ? NetworkImage(_profileImageUrl!)
//                   //       : (_imageFile != null
//                   //       ? FileImage(_imageFile!) as ImageProvider<Object>
//                   //       : null),
//                   //   child: _profileImageUrl == null && _imageFile == null
//                   //       ? _getUserIcon()
//                   //       : null,
//                   // ),
//                   // CircleAvatar(
//                   //   radius: 60,
//                   //   backgroundImage: _imageFile != null
//                   //       ? FileImage(_imageFile!)
//                   //       : null,
//                   //   child: _imageFile == null
//                   //       ? _getUserIcon()
//                   //       : Container(),
//                   // ),
//                   Positioned(
//                     bottom: -10,
//                     right: 0,
//                     child: IconButton(
//                       icon: Icon(Icons.camera_alt, size: 25.0, color: Colors.black,),
//                       onPressed: _updateProfileImage,
//                     ),
//                   ),
//                 ],
//               ),
//               TextFormField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(labelText: 'Username'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your username';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _bioController,
//                 decoration: InputDecoration(labelText: 'Bio'),
//               ),
//               SizedBox(height: 20.0),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _submitForm();
//                   }
//                 },
//                 child: Text('Save'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _getUserIcon() {
//     return Icon(Icons.person, size: 50, color: Colors.grey);
//   }
//
//
//
//   // void _updateProfileImage() async {
//   //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//   //   if (pickedFile != null) {
//   //     setState(() {
//   //       _imageFile = File(pickedFile.path);
//   //     });
//   //   }
//   // }
//
//   void _updateProfileImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//         _profileImageUrl = null; // Reset profile image URL when a new image is selected
//       });
//     }
//   }
//
//   void _submitForm() async {
//     // Update profile data in Firebase
//     String? userId = FirebaseAuth.instance.currentUser?.uid;
//
//     // Upload image to Firebase Storage
//     if (_imageFile != null) {
//       String imagePath = 'users/$userId/profile_image.jpg';
//       print('Uploading image to Firebase Storage...');
//       UploadTask uploadTask =
//       FirebaseStorage.instance.ref().child(imagePath).putFile(_imageFile!);
//       TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
//       String downloadUrl = await snapshot.ref.getDownloadURL();
//       print('Image uploaded successfully. Download URL: $downloadUrl');
//
//       // Update user document in Firestore with image URL
//       print('Updating user document in Firestore...');
//       FirebaseFirestore.instance.collection('users').doc(userId).update({
//         'firstName': _usernameController.text,
//         'bio': _bioController.text,
//         'profileImageUrl': downloadUrl, // Field to store image URL
//       }).then((_) {
//         print('User document updated successfully.');
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('Profile updated successfully'),
//         ));
//       }).catchError((error) {
//         print('Failed to update user document: $error');
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('Failed to update profile: $error'),
//         ));
//       });
//     } else {
//       // If no image selected, update other profile data without image
//       print('No image selected. Updating user document without image...');
//       FirebaseFirestore.instance.collection('users').doc(userId).update({
//         'firstName': _usernameController.text,
//         'bio': _bioController.text,
//       }).then((_) {
//         print('User document updated successfully.');
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('Profile updated successfully'),
//         ));
//       }).catchError((error) {
//         print('Failed to update user document: $error');
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('Failed to update profile: $error'),
//         ));
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _bioController.dispose();
//     super.dispose();
//   }
// }

// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// import 'models/user_profile.dart';
//
// class ProfileEditScreen extends StatefulWidget {
//   @override
//   _ProfileEditScreenState createState() => _ProfileEditScreenState();
// }
//
// class _ProfileEditScreenState extends State<ProfileEditScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _usernameController;
//   late TextEditingController _bioController;
//   File? _imageFile;
//
//   final ImagePicker picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     _usernameController = TextEditingController();
//     _bioController = TextEditingController();
//     // Assume fetchUserProfile returns a Future<UserProfile>
//     fetchUserProfile().then((userProfile) {
//       setState(() {
//         _usernameController.text = userProfile.firstName;
//         _bioController.text = userProfile.bio;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Profile'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 60,
//                     backgroundImage: _imageFile != null
//                         ? FileImage(_imageFile!)
//                         : null,
//                     child: _imageFile == null
//                         ? _getUserIcon()
//                         : Container(),
//                   ),
//                   Positioned(
//                     bottom: -10,
//                     right: 0,
//                     child: IconButton(
//                       icon: Icon(Icons.camera_alt, size: 25.0,),
//                       onPressed: _updateProfileImage,
//                     ),
//                   ),
//                 ],
//               ),
//               TextFormField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(labelText: 'Username'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your username';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _bioController,
//                 decoration: InputDecoration(labelText: 'Bio'),
//               ),
//               SizedBox(height: 20.0),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _submitForm();
//                   }
//                 },
//                 child: Text('Save'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _getUserIcon() {
//     return Icon(Icons.person, size: 50, color: Colors.grey);
//   }
//
//   void _updateProfileImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }
//
//   void _submitForm() {
//     // Update profile data in Firebase
//     print("Nameee in controller: ${_usernameController.text}");
//     String? userId = FirebaseAuth.instance.currentUser?.uid;
//     FirebaseFirestore.instance.collection('users').doc(userId).update({
//       'username': _usernameController.text,
//       'bio': _bioController.text,
//     }).then((_) {
//       print("HAriiiiiiii");
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Profile updated successfully'),
//       ));
//     }).catchError((error) {
//       print(error);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Failed to update profile: $error'),
//       ));
//     });
//   }
//
//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _bioController.dispose();
//     super.dispose();
//   }
// }
