import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OtherUserProfileScreen extends StatelessWidget {
  final String userId;

  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User profile not found'));
          } else {
            final userProfile = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: userProfile['profileImageUrl'] != null
                        ? NetworkImage(userProfile['profileImageUrl'])
                        : null, // Provide path to default user icon
                    child: userProfile['profileImageUrl'] == null
                        ? const Icon(Icons.person, size: 55.0)
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 30),
                      Text(
                        "${userProfile['firstName']} ${userProfile['lastName']}",
                        style: const TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        "${userProfile['ratings']}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Verifications'),
                  ListTile(
                    leading: Icon(
                      userProfile['governmentIdVerified']
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      color: userProfile['governmentIdVerified']
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: const Text('Government ID', style: TextStyle(fontSize: 16)),
                  ),
                  ListTile(
                    leading: Icon(
                      userProfile['driversLicenseVerified']
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      color: userProfile['driversLicenseVerified']
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: const Text('Driver\'s License', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Carpooling Stats'),
                  ListTile(
                    leading: const Icon(Icons.rocket_launch_outlined),
                    title: const Text('Rides Published'),
                    subtitle: Text('${userProfile['ridesPublished'].length}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.book),
                    title: const Text('Rides Booked'),
                    subtitle: Text('${userProfile['ridesBooked'].length}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Member Since'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(
                        (userProfile['memberSince'] as Timestamp).toDate())),
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
