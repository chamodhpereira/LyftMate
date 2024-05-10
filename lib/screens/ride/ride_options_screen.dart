import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:lottie/lottie.dart';

import '../../models/offer_ride.dart';
import '../find_ride/ride_booked_screen.dart';
import '../offer_ride/ui/ride_offered_screen.dart';

class RideOptions extends StatefulWidget {
  const RideOptions({Key? key}) : super(key: key);

  @override
  _RideOptionsState createState() => _RideOptionsState();
}

class _RideOptionsState extends State<RideOptions> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _pricePerSeatController = TextEditingController();

  String _selectedLuggageOption = 'Select Luggage';
  String _selectedPaymentOption = 'Select Payment';
  String _selectedApprovalOption = 'Select Approval';
  final List<String> _selectedPreferences = [];

  final OfferRide ride = OfferRide();
  bool _isLoading = false;

  void _showBottomSheet(
      BuildContext context, String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: options.map((option) {
                    return ListTile(
                      title: Text(option),
                      onTap: () {
                        Navigator.pop(context);
                        onSelect(option);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPreferencesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Select Preferences',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        'Instant Approval',
                        'Smoking is Allowed',
                        'Music is Allowed',
                        'Smoking is Not-Allowed',
                        'Pets are Allowed'
                      ].map((option) {
                        bool isSelected = _selectedPreferences.contains(option);
                        return CheckboxListTile(
                          title: Text(option),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value != null && value) {
                                _selectedPreferences.add(option);
                              } else {
                                _selectedPreferences.remove(option);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _publishRide() async {
    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      ride.setPricePerSeat(double.parse(_pricePerSeatController.text));
      ride.setLuggageAllowance(_selectedLuggageOption);
      ride.setPaymentMode(_selectedPaymentOption);
      ride.setRideApproval(_selectedApprovalOption);
      ride.setPreferences(_selectedPreferences);
      ride.setNotes(_notesController.text);

      try {
        await addRideToFirestore(ride);
        if(context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RidePublishedPage()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not signed in')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish Ride'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 250,
                    margin: EdgeInsets.zero,
                    child: Lottie.asset(
                      "assets/images/right-animation.json",
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    child: const Text(
                      'Your ride is created',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Got anything to add about the ride?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'eg: Flexible about when and where to meet/ got limited space in the boot/ need passengers to be punctual/ etc.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(fontSize: 13.5),
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Enter your additional notes (max 100 characters)',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pricePerSeatController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Price per seat',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Luggage Allowance'),
              trailing: Text(_selectedLuggageOption),
              onTap: () {
                _showBottomSheet(
                  context,
                  'Select Luggage',
                  ['Small', 'Medium', 'Large'],
                      (option) {
                    setState(() {
                      _selectedLuggageOption = option;
                    });
                  },
                );
              },
            ),
            ListTile(
              title: const Text('Mode of Payment'),
              trailing: Text(_selectedPaymentOption),
              onTap: () {
                _showBottomSheet(
                  context,
                  'Select Payment',
                  ['Cash', 'Card', 'No Preference'],
                      (option) {
                    setState(() {
                      _selectedPaymentOption = option;
                    });
                  },
                );
              },
            ),
            ListTile(
              title: const Text('Ride Approval'),
              trailing: Text(_selectedApprovalOption),
              onTap: () {
                _showBottomSheet(
                  context,
                  'Select Approval',
                  ['Instant', 'Request'],
                      (option) {
                    setState(() {
                      _selectedApprovalOption = option;
                    });
                  },
                );
              },
            ),
            ListTile(
              title: const Text('Preferences'),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () {
                _showPreferencesBottomSheet(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
        child: SizedBox(
          width: double.infinity,
          height: 50.0,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            onPressed: _isLoading ? null : _publishRide,
            child: _isLoading
                ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : const Text(
              "Publish Ride",
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> addRideToFirestore(OfferRide ride) async {
  final geo = GeoFlutterFire();

  if (ride.pickupLocation == null || ride.dropoffLocation == null) {
    throw Exception('Pickup location or dropoff location is null.');
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  GeoFirePoint geoPickupPoint = geo.point(
    latitude: ride.pickupLocation!.latitude,
    longitude: ride.pickupLocation!.longitude,
  );

  GeoFirePoint geoDropoffPoint = geo.point(
    latitude: ride.dropoffLocation!.latitude,
    longitude: ride.dropoffLocation!.longitude,
  );

  DateTime rideDateTime = DateTime(
    ride.date!.year,
    ride.date!.month,
    ride.date!.day,
    ride.time!.hour,
    ride.time!.minute,
  );

  Timestamp rideTimestamp = Timestamp.fromDate(rideDateTime);

  List<Map<String, double>> polylineCoordinates =
  ride.polylinePoints.map((latLng) {
    return {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    };
  }).toList();

  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception('No user is currently signed in.');
  }

  Map<String, dynamic> rideData = {
    'driverId': user.uid,
    'rideLocation': geoPickupPoint.data,
    'pickupLocation': geoPickupPoint.data,
    'dropoffLocation': geoDropoffPoint.data,
    "seats": ride.seats,
    "vehicle": ride.vehicle,
    "date": ride.date,
    "time": rideTimestamp,
    "pricePerSeat": ride.pricePerSeat,
    "passengers": [], // List of passenger user IDs
    "polylinePoints": polylineCoordinates,
    "polylinePointsGeohashes": ride.geohashGroups,
    "rideDistance": ride.rideDistance,
    "pickupCityName": ride.pickupCityName,
    "pickupLocationName": ride.pickupLocationName,
    "dropoffCityName": ride.dropoffCityName,
    "dropoffLocationName": ride.dropoffLocationName,
    "rideDuration": ride.rideDuration,
    "luggageAllowance": ride.luggageAllowance ?? "",
    "paymentMode": ride.paymentMode ?? "",
    "rideApproval": ride.rideApproval ?? "",
    "rideStatus": ride.rideStatus,
    "ridePreferences": ride.ridePreferences,
    "rideInstructions": ride.rideNotes,
    "pickedUpPassengers": [],
    "droppedOffPassengers": [],
  };

  DocumentReference rideRef = await firestore.collection('rides').add(rideData);

  DocumentSnapshot userSnapshot = await firestore.collection('users').doc(user.uid).get();

  List<String> userRides = List<String>.from(userSnapshot.get('ridesPublished') ?? []);

  userRides.add(rideRef.id);

  await firestore.collection('users').doc(user.uid).update({
    'ridesPublished': userRides,
  });

  ride.reset();
}





// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:geoflutterfire2/geoflutterfire2.dart';
// import 'package:lottie/lottie.dart';
// import 'package:lyft_mate/screens/offer_ride/ui/ride_offered_screen.dart';
//
// import '../../models/offer_ride.dart';
// import '../find_ride/ride_booked_screen.dart';
// // import 'package:lyft_mate/src/screens/home_screen.dart';
//
// class RideOptions extends StatefulWidget {
//   const RideOptions({Key? key}) : super(key: key);
//
//   @override
//   _RideOptionsState createState() => _RideOptionsState();
// }
//
// class _RideOptionsState extends State<RideOptions> {
//   final TextEditingController _notesController = TextEditingController();
//   final TextEditingController _pricePerSeatController = TextEditingController();
//
//   String _selectedLuggageOption = 'Select Luggage';
//   String _selectedPaymentOption = 'Select Payment';
//   String _selectedApprovalOption = 'Select Approval';
//   final List<String> _selectedPreferences = [];
//
//   final OfferRide ride = OfferRide();
//
//   void _showBottomSheet(BuildContext context, String title,
//       List<String> options, Function(String) onSelect) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Column(
//                   children: options.map((option) {
//                     return ListTile(
//                       title: Text(option),
//                       onTap: () {
//                         Navigator.pop(context);
//                         onSelect(option);
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _showPreferencesBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return SingleChildScrollView(
//               child: Padding(
//                 padding: const  EdgeInsets.only(top: 10.0, bottom: 20.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'Select Preferences',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Column(
//                       children:
//                           ['Instant Approval','Smoking is Allowed','Music is Allowed','Smoking is Not-Allowed', 'Pets are Allowed'].map((option) {
//                         bool isSelected = _selectedPreferences.contains(option);
//                         return CheckboxListTile(
//                           title: Text(option),
//                           value: isSelected,
//                           onChanged: (value) {
//                             setState(() {
//                               if (value != null && value) {
//                                 _selectedPreferences.add(option);
//                               } else {
//                                 _selectedPreferences.remove(option);
//                               }
//                             });
//                           },
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 10),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Publish Ride'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 0.5,
//         // leadingWidth: 50.0,
//         // leading: IconButton(
//         //   icon: const Icon(Icons.arrow_back_ios), // Back button icon
//         //   onPressed: () {
//         //     Navigator.pop(context); // Handle back navigation
//         //   },
//         // ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Center(
//             //   child: Column(
//             //     // mainAxisSize: MainAxisSize.min,
//             //     children: [
//             //       Container(
//             //         height: 250,
//             //           // padding: EdgeInsets.all(20.0),
//             //           margin: EdgeInsets.zero,
//             //           child: Lottie.asset("assets/images/right-animation.json", height: 500, fit: BoxFit.fill )
//             //       ),
//             //       // SizedBox(height: 10),
//             //       Text(
//             //         'Your ride is created',
//             //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             Center(
//               child: Stack(
//                 alignment: Alignment.center, // Aligns all children in the stack
//                 children: [
//                   Container(
//                     height: 250,
//                     margin: EdgeInsets.zero,
//                     child: Lottie.asset(
//                       "assets/images/right-animation.json",
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 10, // Adjust this value to move the text closer or further away
//                     child: Text(
//                       'Your ride is created',
//                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 15),
//             const Text(
//               'Got anything to add about the ride?',
//               style: TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 5),
//             const Text(
//               'eg: Flexible about when and where to meet/ got limited space in the boot/ need passengers to be punctual/ etc.',
//               style: TextStyle(fontSize: 12),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               style: TextStyle(fontSize: 13.5),
//               controller: _notesController,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your additional notes (max 100 characters)',
//                 border: OutlineInputBorder(),
//               ),
//               maxLength: 100,
//               maxLines: 3,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _pricePerSeatController,
//               keyboardType: TextInputType.numberWithOptions(
//                   decimal: true), // Allow decimal numbers
//               decoration: const InputDecoration(
//                 hintText: 'Price per seat',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             ListTile(
//               title: const Text('Luggage Allowance'),
//               trailing: Text(_selectedLuggageOption),
//               onTap: () {
//                 _showBottomSheet(
//                   context,
//                   'Select Luggage',
//                   ['Small', 'Medium', 'Large'],
//                   (option) {
//                     setState(() {
//                       _selectedLuggageOption = option;
//                     });
//                   },
//                 );
//               },
//             ),
//             ListTile(
//               title: const Text('Mode of Payment'),
//               trailing: Text(_selectedPaymentOption),
//               onTap: () {
//                 _showBottomSheet(
//                   context,
//                   'Select Payment',
//                   ['Cash', 'Card', 'No Preference'],
//                   (option) {
//                     setState(() {
//                       _selectedPaymentOption = option;
//                     });
//                   },
//                 );
//               },
//             ),
//             ListTile(
//               title: const Text('Ride Approval'),
//               trailing: Text(_selectedApprovalOption),
//               onTap: () {
//                 _showBottomSheet(
//                   context,
//                   'Select Approval',
//                   ['Instant', 'Request'],
//                   (option) {
//                     setState(() {
//                       _selectedApprovalOption = option;
//                     });
//                   },
//                 );
//               },
//             ),
//             ListTile(
//               title: const Text('Preferences'),
//               // trailing: _selectedPreferences.isNotEmpty
//               //     ? Text('Change Preferences')
//               //     : Text('Select Preferences'),
//               trailing: const Icon(Icons.arrow_drop_down),
//               onTap: () {
//                 _showPreferencesBottomSheet(context);
//               },
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
//         child: SizedBox(
//             width: double.infinity,
//             height: 50.0,
//             child: ElevatedButton(
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
//                 foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//               ),
//               onPressed: () {
//                 User? user = FirebaseAuth.instance.currentUser;
//
//                 if (user != null) {
//                   // User is signed in
//                   print('User ID: ${user.uid}');
//                   print('User Name: ${user.email}');
//                 }
//
//                 ride.setPricePerSeat(
//                     double.parse(_pricePerSeatController.text));
//                 ride.setLuggageAllowance(_selectedLuggageOption);
//                 ride.setPaymentMode(_selectedPaymentOption);
//                 ride.setRideApproval(_selectedApprovalOption);
//                 ride.setPreferences(_selectedPreferences);
//                 ride.setNotes(_notesController.text);
//
//                 addRideToFirestore(ride);
//                 // Navigator.pushAndRemoveUntil(
//                 //   context,
//                 //   MaterialPageRoute(
//                 //     builder: (context) => NewHomeScreen(),
//                 //   ),
//                 //       (route) => false,
//                 // );
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => RidePublishedPage(),
//                     // builder: (context) => const PaymentScreen(),
//                   ),
//                 );
//               },
//               child: const Text(
//                 "Publish Ride",
//                 style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
//               ),
//             )),
//       ),
//     );
//   }
// }
//
// Future<void> addRideToFirestore(OfferRide ride) async {
//   final geo = GeoFlutterFire();
//
//   // print("THISSSS IS THEEE RIDEEE in mfunc: $ride");
//   // print("THISSSS IS THEEE RIDEEE Pickup mfunc: ${ride.pickupLocation}");
//   // print("THISSSS IS THEEE RIDEEE deoppppkup mfunc: ${ride.dropoffLocation}");
//
//   if (ride.pickupLocation == null || ride.dropoffLocation == null) {
//     print('Error: Pickup location or dropoff location is null.');
//     return;
//   }
//
//   // Access the Firestore instance
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//   GeoFirePoint geoPickupPoint = geo.point(
//     latitude: ride.pickupLocation!.latitude,
//     longitude: ride.pickupLocation!.longitude,
//   );
//
//   GeoFirePoint geoDropoffPoint = geo.point(
//     latitude: ride.dropoffLocation!.latitude,
//     longitude: ride.dropoffLocation!.longitude,
//   );
//
//   // Convert TimeOfDay to DateTime
//   DateTime rideDateTime = DateTime(ride.date!.year, ride.date!.month, ride.date!.day, ride.time!.hour, ride.time!.minute);
//
//   // Convert DateTime to Timestamp
//   Timestamp rideTimestamp = Timestamp.fromDate(rideDateTime);
//
//   List<Map<String, double>> polylineCoordinates =
//       ride.polylinePoints.map((latLng) {
//     return {
//       'latitude': latLng.latitude,
//       'longitude': latLng.longitude,
//     };
//   }).toList();
//
//   try {
//     User? user = FirebaseAuth.instance.currentUser;
//
//     if (user != null) {
//       // Create a map containing ride data
//       Map<String, dynamic> rideData = {
//         'driverId': user.uid,
//         'rideLocation': geoPickupPoint.data,
//         'pickupLocation': geoPickupPoint.data,
//         'dropoffLocation': geoDropoffPoint.data,
//         "seats": ride.seats,
//         "vehicle": ride.vehicle,
//         "date": ride.date,
//         "time": rideTimestamp,
//         "pricePerSeat": ride.pricePerSeat,
//         "passengers": [], // List of passenger user IDs
//         "polylinePoints": polylineCoordinates, // Store polyline points as List<List<double>>
//         "polylinePointsGeohashes": ride.geohashGroups,
//         "rideDistance": ride.rideDistance,
//         "pickupCityName": ride.pickupCityName,
//         "pickupLocationName": ride.pickupLocationName,
//         "dropoffCityName": ride.dropoffCityName,
//         "dropoffLocationName": ride.dropoffLocationName,
//         "rideDuration": ride.rideDuration,
//         "luggageAllowance": ride.luggageAllowance ?? "",
//         "paymentMode": ride.paymentMode ?? "",
//         "rideApproval": ride.rideApproval ?? "",
//         "rideStatus" : ride.rideStatus,
//         "ridePreferences": ride.ridePreferences,
//         "rideInstructions": ride.rideNotes,
//         "pickedUpPassengers": [],
//         "droppedOffPassengers": [],
//       };
//
//       // Add the ride data to Firestore
//       DocumentReference rideRef =
//       await firestore.collection('rides').add(rideData);
//
//       // Get the user document from Firestore
//       DocumentSnapshot userSnapshot = await firestore.collection('users').doc(user.uid).get();
//
//       // Extract the 'ridesPublished' array from the user document
//       List<String> userRides = List<String>.from(userSnapshot.get('ridesPublished') ?? []);
//
//       // Add the ID of the newly added ride to the 'ridesPublished' array
//       userRides.add(rideRef.id);
//
//       await firestore.collection('users').doc(user.uid).update({
//         'ridesPublished': userRides,
//       });
//
//       ride.reset();
//       print('Ride published successfully!');
//     } else {
//       print('Error: No user is currently signed in.');
//     }
//   } catch (error) {
//     print("This is the error: ${error.toString()}");
//
//   }
// }
