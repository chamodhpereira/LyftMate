import 'package:flutter/material.dart';
import 'package:lyft_mate/screens/navigation/navigation_screen.dart';

class UserProfileSettingsScreen extends StatelessWidget {
  const UserProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
          child: Column(
            children: [
              SizedBox(
                height: 125.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      maxRadius: 50.0,
                      child: Icon(
                        Icons.person,
                        size: 55.0,
                      ),
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
                            "John Doe",
                            style: TextStyle(fontSize: 20.0),
                          ),
                          Text(
                            "johndoe@doe.com",
                            style: TextStyle(fontSize: 15.0),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Row(
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
                child: const Divider(),
              ),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.settings,
                        size: 32.0,
                      ),
                      title: Text("Account Settings"),
                      subtitle: Text("Notifications, passwords and more"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print("Account settings");
                      },
                    ),
                    SizedBox(height: 5,),
                    ListTile(
                      leading: Icon(
                        Icons.payment,
                        size: 32.0,
                      ),
                      title: Text("Payments"),
                      subtitle: Text("Payment methods, bank details and more"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print("My vehciles");
                      },
                    ),
                    SizedBox(height: 5,),
                    ListTile(
                      leading: Icon(
                        Icons.bar_chart,
                        size: 30.0,
                      ),
                      title: Text("Ride statistics"),
                      subtitle: Text("Ratings, reviews and more"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print("My vehciles");
                      },
                    ),
                    SizedBox(height: 5,),
                    ListTile(
                      leading: const Icon(
                        Icons.language,
                        size: 30.0,
                      ),
                      title: const Text("Accessibility"),
                      subtitle: const Text("Language, text size and more"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print("My vehciles");
                      },
                    ),
                    SizedBox(height: 5,),
                    ListTile(
                      leading: Icon(
                        Icons.support_agent,
                        size: 30.0,
                      ),
                      title: Text("Customer Support"),
                      subtitle: Text("Contact one of our agents"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print("My vehciles");
                      },
                    ),
                    SizedBox(height: 10,),
                    TextButton(
                      onPressed: () {},
                      child: Row(
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
