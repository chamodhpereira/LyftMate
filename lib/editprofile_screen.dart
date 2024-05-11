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
  bool _isPasswordVisible = false;
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
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    // Profile Picture Container
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider<Object>
                          : _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child: _imageFile == null && _profileImageUrl == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    // Camera Icon for Editing
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _updateProfileImage,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Section Header
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Account Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Update Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible, // Show/hide based on the toggle state
                decoration: InputDecoration(
                  labelText: 'Update Password (leave blank to keep current)',
                  labelStyle: const TextStyle(
                    fontSize: 14.0,
                    height: 1.2,
                  ),
                  border: const OutlineInputBorder(),
                  // Icon to toggle password visibility
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible; // Toggle state
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
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

      // Upload a new profile image if selected
      if (_imageFile != null) {
        String imagePath = 'users/${user!.uid}/profile_image.jpg';
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref()
            .child(imagePath)
            .putFile(_imageFile!);
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      // Update other profile fields
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

      // Check if the new email is different from the current one
      if (_emailController.text != user.email) {
        // Prompt user for their current password
        String? currentPassword = await _promptForPassword();
        if (currentPassword == null) return; // User canceled the dialog

        // Re-authenticate with the current password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword, // Use the password from the dialog
        );

        try {
          await user.reauthenticateWithCredential(credential);

          // Send a verification email to the new email address before updating it
          await user.verifyBeforeUpdateEmail(_emailController.text);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'A verification email has been sent to your new email address.',
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Email update error: $e')),
            );
          }
          debugPrint("$e");
        }
      }

      // Update the password if the new password field is not empty
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
      debugPrint("$e");
    }
  }

  Future<String?> _promptForPassword() async {
    String? password;
    await showDialog<String?>(
      context: context,
      builder: (context) {
        final TextEditingController _passwordDialogController = TextEditingController();
        return AlertDialog(
          title: const Text("Re-authentication Required"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter your current password to continue.'),
              TextField(
                controller: _passwordDialogController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                password = _passwordDialogController.text;
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
    return password;
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
