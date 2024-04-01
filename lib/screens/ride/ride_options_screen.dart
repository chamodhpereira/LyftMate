import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

import '../../models/ride.dart';
// import 'package:lyft_mate/src/screens/home_screen.dart';

class RideOptions extends StatefulWidget {
  const RideOptions({Key? key}) : super(key: key);

  @override
  _RideOptionsState createState() => _RideOptionsState();
}

class _RideOptionsState extends State<RideOptions> {
  String _selectedLuggageOption = 'Select Luggage';
  String _selectedPaymentOption = 'Select Payment';
  String _selectedApprovalOption = 'Select Approval';
  List<String> _selectedPreferences = [];

  final Ride ride = Ride();


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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Select Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
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
                  SizedBox(height: 10),
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
        title: Text('Publish Ride'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        // leadingWidth: 50.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), // Back button icon
          onPressed: () {
            Navigator.pop(context); // Handle back navigation
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
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
            SizedBox(height: 20),
            Text(
              'Got anything to add about the ride?',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'eg: Flexible about when and where to meet/ got limited space in the boot/ need passengers to be punctual/ etc.',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your additional notes (max 100 characters)',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text('Luggage Allowance'),
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
              title: Text('Mode of Payment'),
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
              title: Text('Ride Approval'),
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
              title: Text('Preferences'),
              // trailing: _selectedPreferences.isNotEmpty
              //     ? Text('Change Preferences')
              //     : Text('Select Preferences'),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: () {
                _showPreferencesBottomSheet(context);
              },
            ),
            SizedBox(height: 20),
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
                addRideToFirestore(ride);
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => NewHomeScreen(),
                //   ),
                //       (route) => false,
                // );
              },
              child: Text(
                "Publish Ride",
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
            )),
      ),
    );
  }
}

void addRideToFirestore(Ride ride) {

  final geo = GeoFlutterFire();

  print("THISSSS IS THEEE RIDEEE in mfunc: $ride");
  print("THISSSS IS THEEE RIDEEE Pickup mfunc: ${ride.pickupLocation}");
  print("THISSSS IS THEEE RIDEEE deoppppkup mfunc: ${ride.dropoffLocation}");

  if (ride.pickupLocation == null || ride.dropoffLocation == null) {
    print('Error: Pickup location or dropoff location is null.');
    return;
  }



  // Access the Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Convert pickup and dropoff locations to GeoPoint objects
  GeoPoint pickupGeoPoint =
  GeoPoint(ride.pickupLocation!.latitude, ride.pickupLocation!.longitude);
  GeoPoint dropoffGeoPoint =
  GeoPoint(ride.dropoffLocation!.latitude, ride.dropoffLocation!.longitude);

  // // Convert polyline points (LatLng objects) to List<List<double>>
  // List<List<double>> polylineCoordinates = ride.polylinePoints.map((latLng) {
  //   return [latLng.latitude, latLng.longitude];
  // }).toList();
  List<Map<String, double>> polylineCoordinates = ride.polylinePoints.map((latLng) {
    return {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    };
  }).toList();

  // Future createStore(String name, double lng, double lat) async {
  //   GeoFirePoint geoPickupPoint = geo.point(
  //     latitude: lat,
  //     longitude: lng,
  //   );
  //
  //   GeoFirePoint geoDropoffPoint = geo.point(
  //     latitude: lat,
  //     longitude: lng,
  //   );
  //
  //   final storeData = {'name': name, 'location': geoPoint.data};
  //
  //   try {
  //     await _firestore.collection('stores').add(storeData);
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  GeoFirePoint geoPickupPoint = geo.point(
    latitude: ride.pickupLocation!.latitude,
    longitude: ride.pickupLocation!.longitude,
  );

  GeoFirePoint geoDropoffPoint = geo.point(
    latitude: ride.dropoffLocation!.latitude,
    longitude: ride.dropoffLocation!.longitude,
  );

  // Create a map containing ride data
  Map<String, dynamic> rideData = {
    'userId': "geoHASH-user-naha-uu-gihin",
    'pickupLocation': geoPickupPoint.data,
    'dropoffLocation': geoDropoffPoint.data,
    "seats": ride.seats,
    "vehicle": ride.vehicle,
    "date": ride.date,
    // "time": ride.time,
    "pricePerSeat": ride.pricePerSeat,
    "passengers": [], // List of passenger user IDs
    "polylinePoints": polylineCoordinates // Store polyline points as List<List<double>>
    // Add other ride data as needed
  };

  // Add the ride data to Firestore
  firestore.collection('rides').add(rideData).then((value) {
    // Successfully added ride to Firestore
    print('Ride published successfully yakoooooooooooooooo!');
    // Reset ride data if needed
    ride.reset();
  }).catchError((error) {
    // Failed to add ride to Firestore
    print('WTFFFF ettoooo Failed to publish ride: $error');
  });
}


