import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lyft_mate/models/user_profile.dart';
import 'package:lyft_mate/screens/vehicles/vehicle_screen.dart';

import 'editprofile_screen.dart';
import '../../services/authentication/authentication_service.dart';

class UserProfileSettingsScreen extends StatefulWidget {
  final UserProfile userProfile;

  const UserProfileSettingsScreen({super.key, required this.userProfile});

  @override
  State<UserProfileSettingsScreen> createState() => _UserProfileSettingsScreenState();
}

class _UserProfileSettingsScreenState extends State<UserProfileSettingsScreen> {
  final AuthenticationService authService = AuthenticationService();

  @override
  Widget build(BuildContext context) {

    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? widget.userProfile.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
          child: Column(
            children: [
              SizedBox(
                height: 125.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: widget.userProfile.profileImageUrl != null
                          ? NetworkImage(widget.userProfile.profileImageUrl!)
                          : null, // Provide path to default user icon
                      child: widget.userProfile.profileImageUrl == null ? const Icon(Icons.person, size: 50.0) : null,
                    ),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${widget.userProfile.firstName} ${widget.userProfile.lastName}",
                            style: const TextStyle(fontSize: 20.0),
                          ),
                          Text(
                              currentUserEmail,
                            style: const TextStyle(fontSize: 15.0),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileEditScreen(userProfile: widget.userProfile,),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Text("Edit Profile"),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Icon(
                                  Icons.edit,
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 15.0,
                    ),
                    // GestureDetector(child: const Icon(Icons.edit), onTap: () {
                    //   print("Edit button clicked");
                    // },),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
                child: Divider(),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.settings,
                        size: 32.0,
                      ),
                      title: const Text("Account Settings"),
                      subtitle: const Text("Notifications, passwords and more"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print("Account settings");
                      },
                    ),
                    const SizedBox(height: 5,),
                    ListTile(
                      leading: const Icon(
                        Icons.directions_car_outlined,
                        size: 32.0,
                      ),
                      title: const Text("Vehicles"),
                      subtitle: const Text("Manage your vehicles, add or remove vehicles, and more"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print("Account settings");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VehicleScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 5,),
                    ListTile(
                      leading: const Icon(
                        Icons.payment,
                        size: 32.0,
                      ),
                      title: const Text("Payments"),
                      subtitle: const Text("Payment methods, bank details and more"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print("My vehciles");
                      },
                    ),
                    const SizedBox(height: 5,),
                    ListTile(
                      leading: const Icon(
                        Icons.bar_chart,
                        size: 30.0,
                      ),
                      title: const Text("Ride statistics"),
                      subtitle: const Text("Ratings, reviews and more"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print("My vehciles");
                      },
                    ),
                    const SizedBox(height: 5,),
                    ListTile(
                      leading: const Icon(
                        Icons.language,
                        size: 30.0,
                      ),
                      title: const Text("Accessibility"),
                      subtitle: const Text("Language, text size and more"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print("My vehciles");
                      },
                    ),
                    const SizedBox(height: 5,),
                    ListTile(
                      leading: const Icon(
                        Icons.support_agent,
                        size: 30.0,
                      ),
                      title: const Text("Customer Support"),
                      subtitle: const Text("Contact one of our agents"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print("My vehciles");
                      },
                    ),
                    const SizedBox(height: 10,),
                    TextButton(
                      onPressed: () async {
                        await authService.signOut();
                        if(context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/loginScreen', (route) => false,);
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Logout", style: TextStyle(color: Colors.red, fontSize: 15.0),),
                          SizedBox(
                            width: 5.0,
                          ),
                          Icon(
                            Icons.logout_outlined,
                            size: 20,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
