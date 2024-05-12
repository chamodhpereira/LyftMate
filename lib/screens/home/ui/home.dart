import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lyft_mate/screens/find_ride/find_ride_screen.dart';
import 'package:lyft_mate/screens/notifications/notifications_screen.dart';
import 'package:lyft_mate/screens/offer_ride/ui/offer_ride_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import '../../../providers/notification_provider.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatefulWidget {
  // const Home({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? userID = FirebaseAuth.instance.currentUser?.uid;
  bool newNotificationsAvailable = false;

  @override
  void initState() {
    homeBloc.add(HomeInitialEvent());

    super.initState();
  }

  int selectedOption = 0;

  final HomeBloc homeBloc = HomeBloc(); //not recommended

  @override
  Widget build(BuildContext context) {
    // final notificationProvider = context.watch<NotificationProvider>();
    // print(
    //     "hasssNewNotification value: ${notificationProvider.hasNewNotification}");

    // _getToken();
    return Scaffold(
      appBar: AppBar(
        title: Text('LyftMate'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(
              // notificationProvider.hasNewNotification
              //     ? Icons
              //     .notifications_active // Change icon if new notifications are available
              //     : Icons.notifications,
                Icons.notifications
            ),
            onPressed: () {
              homeBloc.add(HomeNotificationNavBtnNavigateEvent());
            },
          ),
          // Consumer<NotificationProvider>(
          //   builder: (context, notificationProvider, _) {
          //     print("Doessss have new notificationsss: ${notificationProvider.hasNewNotification}");
          //     return IconButton(
          //       icon: Icon(
          //         notificationProvider.hasNewNotification
          //             ? Icons.notifications_active // Change icon if new notifications are available
          //             : Icons.notifications,
          //       ),
          //       onPressed: () {
          //         homeBloc.add(
          //             HomeNotificationNavBtnNavigateEvent()
          //         );
          //       },
          //     );
          //   },
          // ),
        ],
      ),
      body: Column(
        children: [
          // SizedBox(height: 90,),
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            // padding: const EdgeInsets.only(top: 38.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedOption = 0; // Set selected option to "Find Ride"
                    });
                    homeBloc.add(HomeDisplayFindRideScreenBtnEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedOption == 0
                        ? Colors.green
                        : Colors.grey, // Change color based on selected option
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Find Ride',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedOption = 1; // Set selected option to "Offer Ride"
                    });
                    homeBloc.add(HomeDisplayOfferRideScreenBtnEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedOption == 1
                        ? Colors.green
                        : Colors.grey, // Change color based on selected option
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Offer Ride',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Spacer(),
          Expanded(
            child: BlocConsumer<HomeBloc, HomeState>(
              bloc: homeBloc,
              listenWhen: (prev, curr) => curr is HomeActionState,
              //Take action if ActionState
              buildWhen: (prev, curr) => curr is! HomeActionState,
              //Build ui if not ActionState
              listener: (context, state) {
                if (state is HomeNavToNotificationPageActionState) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsPage()));
                } else if (state is HomeNavToFindRidePageActionState) {
                  debugPrint("navigating to find ride screeen");
                }
                // else if (state is HomeNavToWishlistPageActionState) {
                //   Navigator.push(
                //       context, MaterialPageRoute(builder: (context) => Wishlist()));
                // } else if (state is HomeProductItemWishlistedActionState){
                //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item added to wishlist")));
                // } else if (state is HomeProductItemCartedActionState) {
                //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item added to cart")));
                // }
              },
              builder: (context, state) {
                // the three states that need to be handled in my builder
                if (state is HomeDisplayFindRideScreen) {
                  return FindRideScreen(
                    homeBloc: homeBloc,
                  );
                } else if (state is HomeDisplayOfferRideScreen) {
                  return OfferRideScreen(
                    homeBloc: homeBloc,
                  ); //not the right way - change this after testing
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}



