import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lyft_mate/screens/chat/user_list.dart';
import 'package:lyft_mate/screens/offer_ride/ui/offer_ride_screen.dart';
import 'package:lyft_mate/screens/notifications/notifications_screen.dart';
import 'package:lyft_mate/screens/user_rides/user_rides.dart';
import 'package:lyft_mate/userprofile_screen.dart';


import '../home/ui/home.dart';


class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {

  int selectedIndex = 0;
  List<Widget> widgetList = [
    HomePage(),
    // OfferRideScreen(),
    UserRides(),  //should be user booked and published rides
    const UserList(), // should be user chat list
    UserProfileScreen()
  ];

  void onTap() {
    setState(() {

    });
  }
  @override
  void initState() {
    print("The cureeeenttt userrr: ${FirebaseAuth.instance.currentUser?.uid}");
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: widgetList[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          selectedItemColor: Colors.blue, // Color for selected item
          unselectedItemColor: Colors.grey, // Color for unselected items
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'Rides',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        )
    );
  }
}