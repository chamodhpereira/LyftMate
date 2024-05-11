import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:intl/intl.dart';
import 'package:lyft_mate/screens/find_ride/ride_details.dart';
import 'package:lyft_mate/screens/find_ride/ride_route.dart';
import '../../services/ride_matching_service.dart';
import '../../widgets/icon_preference.dart';
import 'carpool_ride_card_widget.dart';
import 'confirm_booking.dart';

class RideAndDriver {
  final Map<String, dynamic> rideData;
  // final DocumentSnapshot rideData;
  // final Map<String, dynamic>? driverData;
  // final DocumentSnapshot rideData;
  final DocumentSnapshot driverData;

  RideAndDriver(this.rideData, this.driverData) {
    print("Ride data type: ${rideData.runtimeType}");
    print("Driver data type: ${driverData.runtimeType}");
  }
}

class RideMatchingScreen extends StatefulWidget {
  final GeoPoint userPickupLocation;
  final GeoPoint userDropoffLocation;
  final DateTime? userPickedDate;

  RideMatchingScreen({
    required this.userPickupLocation,
    required this.userDropoffLocation,
    required this.userPickedDate,
  });

  @override
  State<RideMatchingScreen> createState() => _RideMatchingScreenState();
}

class _RideMatchingScreenState extends State<RideMatchingScreen> {
  RideMatching rideMatching = RideMatching();

  late Future<List<Map<String, dynamic>>> _ridesFuture;
  late Future<List<RideAndDriver>> _ridesAndDriversFuture;
  late DateTime? _selectedDate;

  // Define a list of available preferences
  List<String> availablePreferences = [
    'Instant Approval',
    'Smoking is Allowed',
    'Smoking is Not-Allowed',
    'Music is Allowed',
    'Pets are Allowed'
  ];

// Define a list to hold selected preferences
  List<String> selectedPreferences = [];
  List<bool> selectedTimeSlots = [false, false, false, false]; // Corresponds to each time slot
  int selectedTimeSlot = -1;


  @override
  void initState() {
    _selectedDate = widget.userPickedDate;
    // _loadRides();
    _loadRidesAndDrivers();
    super.initState();
  }

  void _loadRides({double maxWalkingDistance = 0.0}) {
    // print("LOAD RIDE DISTANcee: $maxWalkingDistance");
    setState(() {
      _ridesFuture = rideMatching.findRidesWithDistances(
        LatLng(widget.userPickupLocation.latitude,
            widget.userPickupLocation.longitude),
        LatLng(widget.userDropoffLocation.latitude,
            widget.userDropoffLocation.longitude),
        _selectedDate,
        walkingDistance: maxWalkingDistance,
        preferences:
            selectedPreferences.isNotEmpty ? selectedPreferences : null,
      );
    });
  }

  void _loadRidesAndDrivers({double maxWalkingDistance = 0.0}) {
    debugPrint("CALLLLEDDDD LOADDD RIDE AND DRIVERS");
    setState(() {
      _ridesAndDriversFuture = rideMatching
          .findRidesWithDistances(
        LatLng(widget.userPickupLocation.latitude,
            widget.userPickupLocation.longitude),
        LatLng(widget.userDropoffLocation.latitude,
            widget.userDropoffLocation.longitude),
        _selectedDate,
        walkingDistance: maxWalkingDistance,
        preferences:
            selectedPreferences.isNotEmpty ? selectedPreferences : null,
          selectedTimeSlot: selectedTimeSlot
      )
          .then((rides) async {
        List<RideAndDriver> ridesAndDrivers = [];
        for (var rideData in rides) {
          var driverSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(rideData['ride']['driverId'])
              .get();

          if (driverSnapshot.exists) {
            ridesAndDrivers.add(RideAndDriver(rideData, driverSnapshot));
          }
        }
        return ridesAndDrivers; // This will be the combined data structure for rides and drivers
      });
    });
    //
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Rides'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<RideAndDriver>>(
        future: _ridesAndDriversFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errorrr: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No rides found.'));
          } else {
            // This ListView.builder now directly works with the combined data of rides and drivers.
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var rideAndDriver = snapshot.data![index];
                var rideData = rideAndDriver.rideData;
                var driverData = rideAndDriver.driverData;

                // Debugging right before using the data in widgets
                print(
                    "Ride data type before widget: ${rideAndDriver.rideData.runtimeType}");
                print(
                    "Driver data type before widget: ${rideAndDriver.driverData.runtimeType}");

                String pickupDistance = rideData['pickupDistanceText'];
                String dropoffDistance = rideData['dropoffDistanceText'];
                GeoPoint closestCoordinateToPickup = GeoPoint(
                  rideData['closestSnappedPickupCoordinate'].latitude,
                  rideData['closestSnappedPickupCoordinate'].longitude,
                );
                GeoPoint closestCoordinateToDropoff = GeoPoint(
                  rideData['closestSnappedDropoffCoordinate'].latitude,
                  rideData['closestSnappedDropoffCoordinate'].longitude,
                );

                // Now you can directly access the driver's name like this:
                String driverName = driverData?['firstName'] ?? 'Unavailable';

                return GestureDetector(
                  onTap: () {
                    // Navigate to ride details screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RideDetailsScreen(
                          ride: rideData['ride'],
                          pickupDistance: pickupDistance,
                          dropoffDistance: dropoffDistance,
                          closestCoordinateToPickup: closestCoordinateToPickup,
                          closestCoordinateToDropoff:
                              closestCoordinateToDropoff,
                          userPickupLocation: widget.userPickupLocation,
                          userDropoffLocation: widget.userDropoffLocation,
                          driverDetails: driverData,
                        ),
                      ),
                    );
                  },
                  child: CarpoolRideCard(
                    // ride: rideAndDriver.rideData,
                    ride: rideData['ride'],
                    pickupDistance: pickupDistance,
                    dropoffDistance: dropoffDistance,
                    closestCoordinateToPickup: closestCoordinateToPickup,
                    closestCoordinateToDropoff: closestCoordinateToDropoff,
                    userPickupLocation: widget.userPickupLocation,
                    userDropoffLocation: widget.userDropoffLocation,
                    driver: driverData,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {

    // Initialize the maximum walking distance
    double maxWalkingDistance = 0.0;

    DateTime? selectedDate = _selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Filters',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),

                    // Departure Time Section
                    Text('Departure Time', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 10, // Horizontal spacing between items
                      runSpacing: 10, // Vertical spacing between rows
                      children: [
                        _buildToggleButton('Before 6:00 a.m', 0, setState),
                        _buildToggleButton('6:00 a.m - 12:00 noon', 1, setState),
                        _buildToggleButton('12:00 noon - 6:00 p.m', 2, setState),
                        _buildToggleButton('After 6:00 p.m', 3, setState),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Departure Date Section
                    Text('Select Departure Date', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        if (selectedDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'Selected Date: ${DateFormat('EEE, MMM d, yyyy').format(selectedDate!)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        IconButton(
                          icon: Icon(Icons.calendar_today, color: Colors.blue),
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                                _selectedDate = selectedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),


                    // Ride Preferences Section
                    Divider(),
                    Text('Ride Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
                    Column(
                      children: availablePreferences.map((preference) {
                        bool isSelected = selectedPreferences.contains(preference);
                        return SwitchListTile(
                          title: Text(preference, style: TextStyle(fontSize: 14.0),),
                          value: isSelected,
                          onChanged: (bool value) {
                            setState(() {
                              if (value) {
                                // Add to selectedPreferences if not already present
                                if (!selectedPreferences.contains(preference)) {
                                  selectedPreferences.add(preference);
                                }
                              } else {
                                // Remove from selectedPreferences if unselected
                                selectedPreferences.remove(preference);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    // Maximum Walking Distance Slider
                    Divider(),
                    Text(
                      'Maximum Walking Distance: ${maxWalkingDistance.toStringAsFixed(1)} km',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: maxWalkingDistance,
                      min: 0,
                      max: 10,
                      divisions: 100,
                      label: maxWalkingDistance.toStringAsFixed(1),
                      onChanged: (double value) {
                        setState(() {
                          maxWalkingDistance = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Apply Filters Button
                    ElevatedButton(
                      onPressed: () {
                        // Close the bottom sheet and apply the filters
                        Navigator.pop(context);
                        // Call _loadRidesAndDrivers with the selected filters
                        _loadRidesAndDrivers(maxWalkingDistance: maxWalkingDistance);
                      },
                      child: Text('Apply Filters'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildToggleButton(String label, int index, StateSetter setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTimeSlot = index; // Update to the selected index
        });
      },
      child: Container(
        width: 165, // Fixed width for each button
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: selectedTimeSlot == index ? Colors.lightBlueAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: selectedTimeSlot == index ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

}

