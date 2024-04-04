import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/authentication_service.dart';
import 'edit_profile_screen.dart';

class UserProfilePage extends StatelessWidget {

  final AuthenticationService authService = AuthenticationService();

  UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Add functionality to navigate to edit profile screen
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              child: Icon(
                Icons.person,
                size: 55.0,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'John Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'A passionate traveler exploring the world!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            SectionHeader(title: 'Ride Preferences'),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.pets),
              title: Text('Comfortable with pets'),
            ),
            ListTile(
              leading: Icon(Icons.smoking_rooms),
              title: Text('Non-smoker'),
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Early morning rides preferred'),
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Friendly and talkative'),
            ),
            SizedBox(height: 20),
            SectionHeader(title: 'Verifications'),
            SizedBox(height: 10),
            VerificationItem(
              text: 'Government ID',
              verified: false,
              uploadAction: () async {
                FilePickerResult? result =
                await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'doc', 'docx'],
                );

                if (result != null) {
                  // Implement functionality to handle the selected file
                  print('File picked: ${result.files.first.name}');
                  // Implement further actions such as upload or processing
                }
              },
            ),
            VerificationItem(text: "Driver's License", verified: true),
            VerificationItem(text: 'Email ID', verified: true),
            VerificationItem(text: 'Phone Number', verified: true),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule),
                SizedBox(width: 5),
                Text(
                  '12 Rides Published',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person),
                SizedBox(width: 5),
                Text(
                  'Member since March 2020',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
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
  final VoidCallback? uploadAction;

  const VerificationItem({required this.text, required this.verified, this.uploadAction});

  @override
  _VerificationItemState createState() => _VerificationItemState();
}

class _VerificationItemState extends State<VerificationItem> {
  bool isUploaded = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        widget.verified ? Icons.check_circle : Icons.cancel,
        color: widget.verified ? Colors.green : Colors.red,
      ),
      title: Row(
        children: [
          Text(
            widget.text,
            style: TextStyle(fontSize: 16),
          ),
          if (!widget.verified && widget.uploadAction != null && !isUploaded) ...[
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.upload_file),
              onPressed: () {
                widget.uploadAction!();
                setState(() {
                  isUploaded = true;
                });
              },
            ),
          ],
          if (isUploaded) ...[
            SizedBox(width: 10),
            Text('Verification Pending', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}
