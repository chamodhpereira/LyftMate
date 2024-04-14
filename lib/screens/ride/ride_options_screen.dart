import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

import '../../models/offer_ride.dart';
// import 'package:lyft_mate/src/screens/home_screen.dart';

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

  void _showBottomSheet(BuildContext context, String title,
      List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Select Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children:
                        ['Non-smoking', 'Music', 'Pet-friendly'].map((option) {
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish Ride'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        // leadingWidth: 50.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Back button icon
          onPressed: () {
            Navigator.pop(context); // Handle back navigation
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.green,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your ride is created',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Got anything to add about the ride?',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              'eg: Flexible about when and where to meet/ got limited space in the boot/ need passengers to be punctual/ etc.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
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
              keyboardType: TextInputType.numberWithOptions(
                  decimal: true), // Allow decimal numbers
              decoration: const InputDecoration(
                hintText: 'Price per seat',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
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
                  ['Cash', 'Card'],
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
              // trailing: _selectedPreferences.isNotEmpty
              //     ? Text('Change Preferences')
              //     : Text('Select Preferences'),
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
              ),
              onPressed: () {
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // User is signed in
                  print('User ID: ${user.uid}');
                  print('User Name: ${user.email}');
                }

                ride.setPricePerSeat(
                    double.parse(_pricePerSeatController.text));
                ride.setLuggageAllowance(_selectedLuggageOption);
                ride.setPaymentMode(_selectedPaymentOption);
                ride.setRideApproval(_selectedApprovalOption);
                ride.setPreferences(_selectedPreferences);
                ride.setNotes(_notesController.text);

                addRideToFirestore(ride);
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => NewHomeScreen(),
                //   ),
                //       (route) => false,
                // );
              },
              child: const Text(
                "Publish Ride",
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
            )),
      ),
    );
  }
}

Future<void> addRideToFirestore(OfferRide ride) async {
  final geo = GeoFlutterFire();

  // print("THISSSS IS THEEE RIDEEE in mfunc: $ride");
  // print("THISSSS IS THEEE RIDEEE Pickup mfunc: ${ride.pickupLocation}");
  // print("THISSSS IS THEEE RIDEEE deoppppkup mfunc: ${ride.dropoffLocation}");

  if (ride.pickupLocation == null || ride.dropoffLocation == null) {
    print('Error: Pickup location or dropoff location is null.');
    return;
  }

  // Access the Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  GeoFirePoint geoPickupPoint = geo.point(
    latitude: ride.pickupLocation!.latitude,
    longitude: ride.pickupLocation!.longitude,
  );

  GeoFirePoint geoDropoffPoint = geo.point(
    latitude: ride.dropoffLocation!.latitude,
    longitude: ride.dropoffLocation!.longitude,
  );

  List<Map<String, double>> polylineCoordinates =
      ride.polylinePoints.map((latLng) {
    return {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    };
  }).toList();

  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Create a map containing ride data
      Map<String, dynamic> rideData = {
        'userId': user.uid,
        'rideLocation': geoPickupPoint.data,
        'pickupLocation': geoPickupPoint.data,
        'dropoffLocation': geoDropoffPoint.data,
        "seats": ride.seats,
        "vehicle": ride.vehicle,
        "date": ride.date,
        // "time": ride.time,
        "pricePerSeat": ride.pricePerSeat,
        "passengers": [], // List of passenger user IDs
        "polylinePoints": polylineCoordinates, // Store polyline points as List<List<double>>
        "rideDistance": ride.rideDistance,
        "pickupCityName": ride.pickupCityName,
        "pickupLocationName": ride.pickupLocationName,
        "dropoffCityName": ride.dropoffCityName,
        "dropoffLocationName": ride.dropoffLocationName,
        "rideDuration": ride.rideDuration,
        "luggageAllowance": ride.luggageAllowance ?? "",
        "paymentMode": ride.paymentMode ?? "",
        "rideApproval": ride.rideApproval ?? "",
        "rideStatus" : ride.rideStatus,
      };

      // Add the ride data to Firestore
      DocumentReference rideRef =
      await firestore.collection('rides').add(rideData);

      // Get the user document from Firestore
      DocumentSnapshot userSnapshot = await firestore.collection('users').doc(user.uid).get();

      // Extract the 'ridesPublished' array from the user document
      List<String> userRides = List<String>.from(userSnapshot.get('ridesPublished') ?? []);

      // Add the ID of the newly added ride to the 'ridesPublished' array
      userRides.add(rideRef.id);

      await firestore.collection('users').doc(user.uid).update({
        'ridesPublished': userRides,
      });

      ride.reset();
      print('Ride published successfully!');
    } else {
      print('Error: No user is currently signed in.');
    }
  } catch (error) {
    print(error.toString());
  }
}
