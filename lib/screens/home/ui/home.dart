import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  // void _getToken() {
  //   FirebaseMessaging.instance.getToken().then((token) {
  //     print('FCM Token: $token');
  //   });
  // }
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  bool newNotificationsAvailable = false;

  @override
  void initState() {
    homeBloc.add(HomeInitialEvent());

    // Add listener to FirebaseMessaging to detect new notifications
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   // Update state variable when new notification is received
    //   setState(() {
    //     newNotificationsAvailable = true;
    //   });
    // });

    // FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userID)
    //     .collection('notifications')
    //     .snapshots()
    //     .listen((snapshot) {
    //   // Check if there are new documents or modifications
    //   bool hasNewDocument = snapshot.docChanges.any((change) => change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified);
    //   print("HAASSSSSSSSSSSSSS in homeeeee CHANGEEEEEEEEEE: $hasNewDocument");
    //   if(hasNewDocument){
    //     setState(() {
    //       newNotificationsAvailable = true;
    //     });
    //   }
    //
    // });

    super.initState();
  }

  final HomeBloc homeBloc = HomeBloc(); //not recommended

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    print(
        "hasssNewNotification value: ${notificationProvider.hasNewNotification}");

    // _getToken();
    return Scaffold(
      appBar: AppBar(
        title: Text('LyftMate'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(
              notificationProvider.hasNewNotification
                  ? Icons
                      .notifications_active // Change icon if new notifications are available
                  : Icons.notifications,
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
          // Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  homeBloc.add(HomeDisplayFindRideScreenBtnEvent());
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.green,
                  child: const Text(
                    'Find Ride',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  homeBloc.add(HomeDisplayOfferRideScreenBtnEvent());
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.blue,
                  child: const Text(
                    'Offer Ride',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          // Spacer(),
          Expanded(
            child: BlocConsumer<HomeBloc, HomeState>(
              bloc: homeBloc,
              listenWhen: (prev, curr) =>
                  curr is HomeActionState, //Take action if ActionState
              buildWhen: (prev, curr) =>
                  curr is! HomeActionState, //Build ui if not ActionState
              listener: (context, state) {
                if (state is HomeNavToNotificationPageActionState) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationsPage()));
                } else if (state is HomeNavToFindRidePageActionState) {
                  print("navigating to find ride screeen");
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
                  return SizedBox();
                }
              },
            ),
          ),
          // const Spacer(),
        ],
      ),
    );
  }
}

// ---- working but deleted some code can be taken from git commit refactor ride screen
// import 'package:flutter/material.dart';
// import 'package:lyft_mate/screens/find_ride/find_ride_screen.dart';
// import 'package:lyft_mate/screens/offer_ride/offer_ride_screen.dart';
//
// import 'package:lyft_mate/screens/map/map_screen.dart';
// import 'package:provider/provider.dart';
//
//
// import '../../../models/offer_ride.dart';
// import '../../../models/search_ride.dart';
// import '../../../providers/ride_provider.dart';
// import '../../notifications/notifications_screen.dart';
// import '../../offer_ride/confirm_route_screen.dart';
//
//
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     // RideProvider rideProvider = Provider.of<RideProvider>(context, listen: false);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('LyftMate'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 0.5,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notifications),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => NotificationsPage(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body:
//         FindRideScreen(),
//       // OfferRideScreen(),
//       // Padding(
//       //   padding: EdgeInsets.all(20),
//       //   child: Column(
//       //     mainAxisAlignment: MainAxisAlignment.center,
//       //     crossAxisAlignment: CrossAxisAlignment.stretch,
//       //     children: [
//       //       Row(
//       //         mainAxisAlignment: MainAxisAlignment.center,
//       //         children: [
//       //           Expanded(
//       //             child: TextButton(
//       //               onPressed: () {
//       //                 setState(() {
//       //                   isFindingRide = true;
//       //                 });
//       //               },
//       //               style: isFindingRide
//       //                   ? ButtonStyle(
//       //                       foregroundColor:
//       //                           MaterialStateProperty.all<Color>(Colors.white),
//       //                       backgroundColor:
//       //                           MaterialStateProperty.all<Color>(Colors.green),
//       //                     )
//       //                   : ButtonStyle(
//       //                       foregroundColor:
//       //                           MaterialStateProperty.all<Color>(Colors.green),
//       //                     ),
//       //               child: Text('Find a Ride',
//       //                   style: TextStyle(
//       //                       fontSize: 14.0, fontWeight: FontWeight.bold)),
//       //             ),
//       //           ),
//       //           SizedBox(width: 20),
//       //           Expanded(
//       //             child: TextButton(
//       //               onPressed: () {
//       //                 setState(() {
//       //                   isFindingRide = false;
//       //                 });
//       //               },
//       //               style: !isFindingRide
//       //                   ? ButtonStyle(
//       //                       foregroundColor:
//       //                           MaterialStateProperty.all<Color>(Colors.white),
//       //                       backgroundColor:
//       //                           MaterialStateProperty.all<Color>(Colors.green),
//       //                     )
//       //                   : ButtonStyle(
//       //                       foregroundColor:
//       //                           MaterialStateProperty.all<Color>(Colors.green),
//       //                     ),
//       //               child: Text('Offer a Ride',
//       //                   style: TextStyle(
//       //                       fontSize: 14.0, fontWeight: FontWeight.bold)),
//       //             ),
//       //           ),
//       //         ],
//       //       ),
//       //       SizedBox(height: 20),
//       //       TextField(
//       //         readOnly: true,
//       //         controller: _pickupLocationController,
//       //         onTap: () async {
//       //           final result = await Navigator.push(
//       //             context,
//       //             MaterialPageRoute(
//       //                 builder: (context) => MapScreen(
//       //                       locType: 'pickup',
//       //                     )), // Navigate to MapPage
//       //           );
//       //           if (result != null) {
//       //             double lat = result['lat'];
//       //             double lng = result['lng'];
//       //             String locationName = result['locationName'];
//       //             String cityName = result['cityName'];
//       //
//       //
//       //             print("CITTTTTTYYYY POOOOOOOOOOOOOOOOOOOP NAMEEEEEEEEEEEE: $cityName");
//       //             // rideProvider.updatePickupCoordinates(lat, lng);
//       //             ride.updatePickupCoordinates(lat, lng);
//       //             ride.pickupCityName = cityName;
//       //             ride.pickupLocationName = locationName;
//       //                 setState(() {
//       //               _pickupLocationController.text = locationName;
//       //               pickupLat = lat;
//       //               pickupLng = lng;
//       //             });
//       //           }
//       //         },
//       //         decoration: InputDecoration(
//       //           labelText: 'Offer ride Pickup Location',
//       //           border: OutlineInputBorder(),
//       //         ),
//       //       ),
//       //       SizedBox(height: 10),
//       //       TextField(
//       //         readOnly: true,
//       //         controller: _dropoffLocationController,
//       //         onTap: () async {
//       //           final result = await Navigator.push(
//       //             context,
//       //             MaterialPageRoute(
//       //                 builder: (context) => MapScreen(
//       //                       locType: 'dropoff',
//       //                     )), // Navigate to MapPage
//       //           );
//       //           if (result != null) {
//       //             double lat = result['lat'];
//       //             double lng = result['lng'];
//       //             String locationName = result['locationName'];
//       //             String cityName = result['cityName'];
//       //             ride.updateDropoffCoordinates(lat, lng);
//       //             ride.dropoffCityName = cityName;
//       //             ride.dropoffLocationName = locationName;
//       //             // ride.cityName =
//       //             setState(() {
//       //               _dropoffLocationController.text = locationName;
//       //               dropoffLat = lat;
//       //               dropoffLng = lng;
//       //             });
//       //           }
//       //         },
//       //         decoration: InputDecoration(
//       //           labelText: 'Drop Location',
//       //           border: OutlineInputBorder(),
//       //         ),
//       //       ),
//       //       SizedBox(height: 10),
//       //       Row(
//       //         mainAxisAlignment: MainAxisAlignment.center,
//       //         children: [
//       //           Expanded(
//       //             child: GestureDetector(
//       //               onTap: () => _selectDate(context),
//       //               child: AbsorbPointer(
//       //                 child: TextFormField(
//       //                   readOnly: true,
//       //                   decoration: InputDecoration(
//       //                     labelText: 'Select Date',
//       //                     border: OutlineInputBorder(),
//       //                     suffixIcon: Icon(Icons.calendar_today),
//       //                   ),
//       //                   controller: TextEditingController(
//       //                     text: _selectedDate != null
//       //                         ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
//       //                         : '',
//       //                   ),
//       //                 ),
//       //               ),
//       //             ),
//       //           ),
//       //           SizedBox(width: 10),
//       //           Expanded(
//       //             child: GestureDetector(
//       //               onTap: () => _selectTime(context),
//       //               child: AbsorbPointer(
//       //                 child: TextFormField(
//       //                   readOnly: true,
//       //                   decoration: InputDecoration(
//       //                     labelText: 'Select Time',
//       //                     border: OutlineInputBorder(),
//       //                     suffixIcon: Icon(Icons.access_time),
//       //                   ),
//       //                   controller: TextEditingController(
//       //                       // text: _selectedTime != null
//       //                       //     ? '${_selectedTime!.hourOfPeriod}:${_selectedTime!.minute} ${_selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}'
//       //                       //     : '',
//       //                       ),
//       //                 ),
//       //               ),
//       //             ),
//       //           ),
//       //         ],
//       //       ),
//       //       SizedBox(height: 10),
//       //       Visibility(
//       //         visible: !isFindingRide,
//       //         child: Row(
//       //           mainAxisAlignment: MainAxisAlignment.center,
//       //           children: [
//       //             Expanded(
//       //               child: GestureDetector(
//       //                 onTap: () => _selectVehicle(context),
//       //                 child: AbsorbPointer(
//       //                   child: TextFormField(
//       //                     readOnly: true,
//       //                     decoration: InputDecoration(
//       //                       labelText: 'Select Vehicle',
//       //                       border: OutlineInputBorder(),
//       //                       suffixIcon: Icon(Icons.directions_car),
//       //                     ),
//       //                     controller: TextEditingController(
//       //                       text: selectedVehicle ?? '',
//       //                     ),
//       //                   ),
//       //                 ),
//       //               ),
//       //             ),
//       //             SizedBox(width: 10),
//       //             Expanded(
//       //               child: TextField(
//       //                 onChanged: (value) {
//       //                   setState(() {
//       //                     selectedSeats = value;
//       //                     ride.setSeats(value);
//       //                   });
//       //                 },
//       //                 keyboardType: TextInputType.number,
//       //                 decoration: InputDecoration(
//       //                   labelText: 'Select Seats',
//       //                   border: OutlineInputBorder(),
//       //                 ),
//       //               ),
//       //             ),
//       //           ],
//       //         ),
//       //       ),
//       //       SizedBox(height: 20),
//       //       Container(
//       //         // PROCEED Button - offer ride
//       //         height: 50.0,
//       //         color: Colors.transparent,
//       //         child: ElevatedButton(
//       //           style: ButtonStyle(
//       //             foregroundColor:
//       //                 MaterialStateProperty.all<Color>(Colors.white),
//       //             backgroundColor:
//       //                 MaterialStateProperty.all<Color>(Colors.green),
//       //           ),
//       //           onPressed: () async {
//       //             if (isFindingRide) {
//       //               // Call your method here
//       //               // try {
//       //               //   String pickupLatitudeString = _pickupLocationController.text; // Assuming this contains the latitude string
//       //               //   String pickupLongitudeString = _dropoffLocationController.text; // Assuming this contains the longitude string
//       //               //   // Convert latitude and longitude strings to doubles
//       //               //   double pickupLatitude = double.parse(pickupLatitudeString);
//       //               //   double pickupLongitude = double.parse(pickupLongitudeString);
//       //               //
//       //               //   String dropoffLatitudeString = _dropoffLocationController.text; // Assuming this contains the latitude string
//       //               //   String dropoffLongitudeString = _dropoffLocationController.text; // Assuming this contains the longitude string
//       //               //
//       //               //   // Convert latitude and longitude strings to doubles
//       //               //   double dropoffLatitude = double.parse(dropoffLatitudeString);
//       //               //   double dropoffLongitude = double.parse(dropoffLongitudeString);
//       //               //
//       //               //   GeoFirePoint pickupLocation = GeoFirePoint(pickupLatitude, pickupLongitude);
//       //               //   GeoFirePoint dropoffLocation = GeoFirePoint(dropoffLatitude, dropoffLongitude);
//       //               //
//       //               //   List<DocumentSnapshot> rides =
//       //               //       await rideSearch.filterRidesByDestinationNearUser(
//       //               //           pickupLocation, dropoffLocation);
//       //               //
//       //               //   // Now you have the filtered rides, you can handle them as needed
//       //               //   print("Filtered rides: $rides");
//       //               //
//       //               //   // Navigate to AvailableRides screen or do whatever you want with the filtered rides
//       //               //   print("navigate to available rides pages");
//       //               //   // Navigator.push(
//       //               //   //   context,
//       //               //   //   MaterialPageRoute(
//       //               //   //     builder: (context) => AvailableRides(),
//       //               //   //   ),
//       //               //   // );
//       //               // } catch (e) {
//       //               //   // Handle any errors that might occur during filtering
//       //               //   print("Error filtering rides: $e");
//       //               // }
//       //             } else {
//       //               // Handle Publish Ride Button Press
//       //               _handlePublishRideButtonPress();
//       //             }
//       //           },
//       //           child: Text(
//       //             isFindingRide ? 'Search Ride' : 'Proceed',
//       //             style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
//       //           ),
//       //         ),
//       //       ),
//       //
//       //       // ElevatedButton(
//       //       //   onPressed: _handlePublishRideButtonPress,
//       //       //   child: Text(isFindingRide ? 'Search Ride' : 'Publish Ride'),
//       //       // ),
//       //     ],
//       //   ),
//       // ),
//     );
//   }
//
//   // Function to handle button press
//   // void _handlePublishRideButtonPress() {
//   //   if (isFindingRide) {
//   //     // Implement logic for finding a ride
//   //   } else {
//   //     print("publish ride was pressed");
//   //     // Implement logic for offering a ride
//   //     if (pickupLat != null &&
//   //         pickupLng != null &&
//   //         dropoffLat != null &&
//   //         dropoffLng != null) {
//   //       // Navigate to the next screen with pickup and dropoff coordinates
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder: (context) => ConfirmRoute(
//   //             pickupLat: pickupLat!,
//   //             pickupLng: pickupLng!,
//   //             dropoffLat: dropoffLat!,
//   //             dropoffLng: dropoffLng!,
//   //           ),
//   //         ),
//   //       );
//   //     } else {
//   //       // Show an error or prompt the user to select locations
//   //       // before publishing the ride.
//   //     }
//   //   }
//   // }
// }
