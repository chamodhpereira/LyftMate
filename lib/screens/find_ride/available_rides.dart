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
  // void _loadRidesAndDrivers({double maxWalkingDistance = 0.0}) {
  //   debugPrint("CALLLLEDDDD LOADDD RIDE AND DRIVERS"); // Debug statement added
  //   setState(() {
  //     debugPrint("Inside setState"); // Debug statement added
  //     _ridesAndDriversFuture = rideMatching.findRidesWithDistances(
  //       LatLng(widget.userPickupLocation.latitude, widget.userPickupLocation.longitude),
  //       LatLng(widget.userDropoffLocation.latitude, widget.userDropoffLocation.longitude),
  //       _selectedDate,
  //       walkingDistance: maxWalkingDistance,
  //       preferences: selectedPreferences.isNotEmpty ? selectedPreferences : null,
  //     ).then((rides) async {
  //       debugPrint("Rides fetched"); // Debug statement added
  //       debugPrint("Rides: $rides");
  //       List<RideAndDriver> ridesAndDrivers = [];
  //       // for (var rideData in rides) {
  //       //   var driverSnapshot = await FirebaseFirestore.instance
  //       //       .collection('users')
  //       //       .doc(rideData['ride']['driverId'])
  //       //       .get();
  //
  //       for (DocumentSnapshot rideData in rides) {
  //         print("Ride data snapshot: $rideData");
  //         var driverId = rideData.data()!['driverId'] as String;
  //         print("Fetching driver data for ID: $driverId");
  //
  //         var driverSnapshot = await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(driverId)
  //             .get();
  //
  //         print("Driver snapshot exists: ${driverSnapshot.exists}");
  //         if (driverSnapshot.exists) {
  //           ridesAndDrivers.add(RideAndDriver(rideData, driverSnapshot));
  //         }
  //       }
  //         debugPrint("Driver snapshot fetched"); // Debug statement added
  //
  //         // Debugging right after fetching the data
  //         print("Ride data type after fetching: ${rideData['ride'].runtimeType}");
  //         print("Driver snapshot type after fetching: ${driverSnapshot.runtimeType}");
  //
  //         if (driverSnapshot.exists) {
  //           ridesAndDrivers.add(RideAndDriver(rideData['ride'], driverSnapshot));
  //           debugPrint("Ride and driver added"); // Debug statement added
  //
  //
  //         }
  //       }
  //       debugPrint("Returning rides and drivers"); // Debug statement added
  //       return ridesAndDrivers; // This will be the combined data structure for rides and drivers
  //     });
  //   });
  // }
  // void _loadRidesAndDrivers({double maxWalkingDistance = 0.0}) {
  //   debugPrint("CALLLLEDDDD LOADDD RIDE AND DRIVERS");
  //   setState(() {
  //     _ridesAndDriversFuture = rideMatching.findRidesWithDistances(
  //       LatLng(widget.userPickupLocation.latitude, widget.userPickupLocation.longitude),
  //       LatLng(widget.userDropoffLocation.latitude, widget.userDropoffLocation.longitude),
  //       _selectedDate,
  //       walkingDistance: maxWalkingDistance,
  //       preferences: selectedPreferences.isNotEmpty ? selectedPreferences : null,
  //     ).then((rides) async {
  //       debugPrint("Found ${rides.length} rides matching the criteria");
  //       List<RideAndDriver> ridesAndDrivers = [];
  //       for (var rideData in rides) {
  //         debugPrint("Processing ride data: $rideData");
  //         var driverSnapshot = await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(rideData['ride']['driverId'])
  //             .get();
  //
  //         if (driverSnapshot.exists) {
  //           debugPrint("Driver snapshot exists for ride with driver ID: ${rideData['ride']['driverId']}");
  //           ridesAndDrivers.add(RideAndDriver(rideData, driverSnapshot));
  //         } else {
  //           debugPrint("Driver snapshot does not exist for ride with driver ID: ${rideData['ride']['driverId']}");
  //         }
  //       }
  //       debugPrint("Total rides and drivers found: ${ridesAndDrivers.length}");
  //       return ridesAndDrivers; // This will be the combined data structure for rides and drivers
  //     });
  //   });
  // }

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
      // body: FutureBuilder<List<Map<String, dynamic>>>(
      //   future: _ridesFuture,
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(child: CircularProgressIndicator());
      //     } else if (snapshot.hasError) {
      //       return Center(child: Text('Error: ${snapshot.error}'));
      //     } else if (snapshot.data == null || snapshot.data!.isEmpty) {
      //       return Center(child: Text('No rides found.'));
      //     } else {
      //       return ListView.builder(
      //         itemCount: snapshot.data!.length,
      //         itemBuilder: (context, index) {
      //           var rideData = snapshot.data![index];
      //           var ride = rideData['ride'];
      //           // double pickupDistance = rideData['pickupDistance'];
      //           String pickupDistance = rideData['pickupDistanceText'];
      //           String dropoffDistance = rideData['dropoffDistanceText'];
      //
      //           // double dropoffDistance = rideData['dropoffDistance'];
      //           // GeoPoint closestCoordinateToPickup =
      //           // rideData['closestCoordinateToPickup'];
      //           // GeoPoint closestCoordinateToDropoff =
      //           // rideData['closestCoordinateToDropoff'];
      //
      //           LatLng closestCoordinateToPickupLatLng =
      //               rideData['closestSnappedPickupCoordinate'];
      //           LatLng closestCoordinateToDropoffLatLng =
      //               rideData['closestSnappedDropoffCoordinate'];
      //
      //           GeoPoint closestCoordinateToPickup = GeoPoint(
      //             rideData['closestSnappedPickupCoordinate'].latitude,
      //             rideData['closestSnappedPickupCoordinate'].longitude,
      //           );
      //
      //           GeoPoint closestCoordinateToDropoff = GeoPoint(
      //             rideData['closestSnappedDropoffCoordinate'].latitude,
      //             rideData['closestSnappedDropoffCoordinate'].longitude,
      //           );
      //
      //           // Get the driver ID from the ride
      //           String driverId = ride['driverId'];
      //
      //           return FutureBuilder<DocumentSnapshot>(
      //             future: FirebaseFirestore.instance
      //                 .collection('users')
      //                 .doc(driverId)
      //                 .get(),
      //             builder: (context, driverSnapshot) {
      //               if (driverSnapshot.connectionState ==
      //                   ConnectionState.waiting) {
      //                 return CircularProgressIndicator();
      //               } else if (driverSnapshot.hasError) {
      //                 return Text('Error: ${driverSnapshot.error}');
      //               } else if (!driverSnapshot.hasData ||
      //                   driverSnapshot.data!.data() == null) {
      //                 return Text('No driver data found');
      //               } else {
      //                 var driverData = driverSnapshot.data!;
      //                 // Now you have driver details, you can display them as needed
      //                 // For example, you can access driverData['name'], driverData['age'], etc.
      //                 print(
      //                     "DRriveeeeeeeeer nameeee: ${driverData["firstName"]}");
      //                 return GestureDetector(
      //                   onTap: () {
      //                     // Navigate to ride details screen
      //                     Navigator.push(
      //                       context,
      //                       MaterialPageRoute(
      //                         builder: (context) => RideDetailsScreen(
      //                           ride: ride,
      //                           pickupDistance: pickupDistance,
      //                           dropoffDistance: dropoffDistance,
      //                           closestCoordinateToPickup:
      //                               closestCoordinateToPickup,
      //                           closestCoordinateToDropoff:
      //                               closestCoordinateToDropoff,
      //                           userPickupLocation: widget.userPickupLocation,
      //                           userDropoffLocation: widget.userDropoffLocation,
      //                           driverDetails: driverData,
      //                         ),
      //                       ),
      //                     );
      //                   },
      //                   child: CarpoolRideCard(
      //                     ride: ride,
      //                     pickupDistance: pickupDistance,
      //                     dropoffDistance: dropoffDistance,
      //                     closestCoordinateToPickup: closestCoordinateToPickup,
      //                     closestCoordinateToDropoff:
      //                     closestCoordinateToDropoff,
      //                     userPickupLocation: widget.userPickupLocation,
      //                     userDropoffLocation: widget.userDropoffLocation,
      //                     driver: driverData,
      //                   ),
      //                 );
      //               }
      //             },
      //           );
      //         },
      //       );
      //     }
      //   },
      // ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    // Initialize the states for departure time options
    // List<bool> selectedDepartureTimes = [false, false, false, false]; // Corresponds to each time slot

    // Initialize the maximum walking distance
    double maxWalkingDistance = 0.0;

    // Selected date variable
    // DateTime selectedDate = DateTime.now();
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

  // Widget _buildToggleButton(String label, List<bool> isSelected, int index, StateSetter setState) {
  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         isSelected[index] = !isSelected[index]; // Toggle the selected state
  //       });
  //     },
  //     child: Container(
  //       width: 165, // Fixed width for each button
  //       padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
  //       decoration: BoxDecoration(
  //         color: isSelected[index] ? Colors.lightBlueAccent : Colors.grey[200],
  //         borderRadius: BorderRadius.circular(8.0),
  //       ),
  //       child: Text(
  //         label,
  //         textAlign: TextAlign.center,
  //         style: TextStyle(
  //           fontSize: 12.0,
  //           fontWeight: FontWeight.bold,
  //           color: isSelected[index] ? Colors.white : Colors.black,
  //         ),
  //       ),
  //     ),
  //   );
  // }



// Helper function for creating an equally sized toggle button
//   Widget _buildToggleButton(String label, List<bool> isSelected, int index, StateSetter setState) {
//     return GestureDetector(
//       onTap: () {
//         // Toggle the selected state
//         setState(() {
//           isSelected[index] = !isSelected[index];
//         });
//       },
//       child: Container(
//         width: 165, // Set a fixed width for all buttons
//         padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
//         decoration: BoxDecoration(
//           color: isSelected[index] ? Colors.lightBlueAccent : Colors.grey[200],
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         child: Text(
//           label,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 12.0,
//             fontWeight: FontWeight.bold,
//             color: isSelected[index] ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }



  /// workinggggggggggggggggggggg
  // void _previousSshowFilterOptions(BuildContext context) {
  //   // Define variables to hold the selected date and time
  //   DateTime selectedDate = DateTime.now();
  //   TimeOfDay selectedTime = TimeOfDay.now();
  //   // Define a variable to hold the maximum walking distance
  //   double maxWalkingDistance = 0.0;
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true, // Set to true to allow more height
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return SingleChildScrollView(
  //             child: Container(
  //               padding: EdgeInsets.all(16.0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: <Widget>[
  //                   Text(
  //                     'Filter Options',
  //                     style: TextStyle(
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   SizedBox(height: 16),
  //                   // Filter by Date
  //                   // Add your date filter widget here
  //                   // For example, a DatePicker
  //                   ElevatedButton(
  //                     onPressed: () async {
  //                       // Show date picker
  //                       final DateTime? pickedDate = await showDatePicker(
  //                         context: context,
  //                         initialDate: selectedDate,
  //                         firstDate: DateTime.now(),
  //                         lastDate: DateTime(2101),
  //                       );
  //                       if (pickedDate != null && pickedDate != selectedDate) {
  //                         setState(() {
  //                           selectedDate = pickedDate;
  //                           _selectedDate = selectedDate;
  //                         });
  //                       }
  //                     },
  //                     child: Text('Select Date'),
  //                   ),
  //                   SizedBox(height: 16),
  //                   // Filter by Time
  //                   // Add your time filter widget here
  //                   // For example, a TimePicker
  //                   OutlinedButton(
  //                     onPressed: () async {
  //
  //                       // Show time picker
  //                       final TimeOfDay? pickedTime = await showTimePicker(
  //                         context: context,
  //                         initialTime: selectedTime,
  //                       );
  //                       if (pickedTime != null && pickedTime != selectedTime) {
  //                         setState(() {
  //                           selectedTime = pickedTime;
  //                         });
  //                       }
  //                     },
  //                     child: Text('Select Time'),
  //                   ),
  //                   SizedBox(height: 16),
  //                   // Filter by Price Per Seat
  //                   // Add your price per seat filter widget here
  //                   // For example, a TextFormField
  //                   TextFormField(
  //                     keyboardType: TextInputType.number,
  //                     decoration: InputDecoration(
  //                       labelText: 'Enter Price',
  //                     ),
  //                   ),
  //                   SizedBox(height: 16),
  //                   // Filter by Preferences
  //                   // Text(
  //                   //   'Preferences:',
  //                   //   style: TextStyle(
  //                   //     fontWeight: FontWeight.bold,
  //                   //   ),
  //                   // ),
  //                   // // Add your preference filter widget here
  //                   // Column(
  //                   //   children: availablePreferences.map((preference) {
  //                   //     return CheckboxListTile(
  //                   //       title: Text(preference),
  //                   //       value: selectedPreferences.contains(preference),
  //                   //       onChanged: (bool? value) {
  //                   //         setState(() {
  //                   //           if (value != null && value) {
  //                   //             selectedPreferences.add(preference);
  //                   //           } else {
  //                   //             selectedPreferences.remove(preference);
  //                   //           }
  //                   //         });
  //                   //       },
  //                   //     );
  //                   //   }).toList(),
  //                   // ),
  //
  //                   // Ride Preferences Section
  //                   Divider(),
  //                   Text('Ride Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
  //                   Column(
  //                     children: availablePreferences.map((preference) {
  //                       bool isSelected = selectedPreferences.contains(preference);
  //                       return SwitchListTile(
  //                         title: Text(preference),
  //                         value: isSelected,
  //                         onChanged: (bool value) {
  //                           setState(() {
  //                             if (value) {
  //                               // Add to selectedPreferences if not already present
  //                               if (!selectedPreferences.contains(preference)) {
  //                                 selectedPreferences.add(preference);
  //                               }
  //                             } else {
  //                               // Remove from selectedPreferences if unselected
  //                               selectedPreferences.remove(preference);
  //                             }
  //                           });
  //                         },
  //                       );
  //                     }).toList(),
  //                   ),
  //
  //                   // Maximum Walking Distance Slider
  //                   Divider(),
  //                   Text(
  //                     'Maximum Walking Distance: ${maxWalkingDistance.toStringAsFixed(1)} km',
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   // Add your maximum walking distance filter widget here
  //                   Slider(
  //                     value: maxWalkingDistance,
  //                     min: 0,
  //                     max: 10,
  //                     divisions: 100,
  //                     label: maxWalkingDistance.toStringAsFixed(1),
  //                     onChanged: (double value) {
  //                       setState(() {
  //                         maxWalkingDistance = value;
  //                       });
  //                     },
  //                   ),
  //                   SizedBox(height: 16),
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       // Close the bottom sheet and trigger the method to reload rides with new filters
  //                       Navigator.pop(context);
  //                       // _loadRides(maxWalkingDistance: maxWalkingDistance);
  //                       _loadRidesAndDrivers(maxWalkingDistance: maxWalkingDistance);
  //                     },
  //                     child: Text('Apply Filters'),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//   void _showFilterOptions(BuildContext context) {
//     // Define variables to hold the selected date and time
//     DateTime selectedDate = DateTime.now();
//     TimeOfDay selectedTime = TimeOfDay.now();
//     // Define a variable to hold the maximum walking distance
//     double maxWalkingDistance = 0.0;
//
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return Container(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   Text(
//                     'Filter Options',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   // Filter by Date
//                   Text(
//                     'Date:',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   // Add your date filter widget here
//                   // For example, a DatePicker
//                   ElevatedButton(
//                     onPressed: () async {
//                       // Show date picker
//                       final DateTime? pickedDate = await showDatePicker(
//                         context: context,
//                         initialDate: selectedDate,
//                         firstDate: DateTime.now(),
//                         lastDate: DateTime(2101),
//                       );
//                       if (pickedDate != null && pickedDate != selectedDate) {
//                         setState(() {
//                           selectedDate = pickedDate;
//                           _selectedDate = selectedDate;
//                         });
//                       }
//                     },
//                     child: Text('Select Date'),
//                   ),
//                   SizedBox(height: 16),
//                   // Filter by Time
//                   Text(
//                     'Time:',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   // Add your time filter widget here
//                   // For example, a TimePicker
//                   ElevatedButton(
//                     onPressed: () async {
//                       // Show time picker
//                       final TimeOfDay? pickedTime = await showTimePicker(
//                         context: context,
//                         initialTime: selectedTime,
//                       );
//                       if (pickedTime != null && pickedTime != selectedTime) {
//                         setState(() {
//                           selectedTime = pickedTime;
//                         });
//                       }
//                     },
//                     child: Text('Select Time'),
//                   ),
//                   SizedBox(height: 16),
//                   // Filter by Price Per Seat
//                   Text(
//                     'Price Per Seat:',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   // Add your price per seat filter widget here
//                   // For example, a Slider or TextFormField
//                   TextFormField(
//                     keyboardType: TextInputType.number,
//                     decoration: InputDecoration(
//                       labelText: 'Enter Price',
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'Preferences:',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
// // Add your preference filter widget here
//                   Column(
//                     children: availablePreferences.map((preference) {
//                       return CheckboxListTile(
//                         title: Text(preference),
//                         value: selectedPreferences.contains(preference),
//                         onChanged: (bool? value) {
//                           setState(() {
//                             if (value != null && value) {
//                               selectedPreferences.add(preference);
//                             } else {
//                               selectedPreferences.remove(preference);
//                             }
//                           });
//                         },
//                       );
//                     }).toList(),
//                   ),
//                   // Filter by Maximum Walking Distance
//                   Text(
//                     'Maximum Walking Distance: ${maxWalkingDistance.toStringAsFixed(1)} km',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   // Add your maximum walking distance filter widget here
//                   // For example, a Slider or TextFormField
//                   Slider(
//                     value: maxWalkingDistance,
//                     min: 0,
//                     max: 10,
//                     // Set your desired maximum walking distance
//                     divisions: 100,
//                     label: maxWalkingDistance.toStringAsFixed(1),
//                     onChanged: (double value) {
//                       setState(() {
//                         maxWalkingDistance = value;
//                       });
//                     },
//                   ),
//                   SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Close the bottom sheet and trigger the method to reload rides with new filters
//                       Navigator.pop(context);
//                       _loadRides(maxWalkingDistance: maxWalkingDistance);
//                     },
//                     child: Text('Apply Filters'),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

// void _showFilterOptions(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     builder: (BuildContext context) {
//       return Container(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Text(
//               'Filter Options',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16),
//             // Filter by Date
//             Text(
//               'Date:',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             // Add your date filter widget here
//             // For example, a DatePicker
//             ElevatedButton(
//               onPressed: () {
//                 // Show date picker
//               },
//               child: Text('Select Date'),
//             ),
//             SizedBox(height: 16),
//             // Filter by Time
//             Text(
//               'Time:',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             // Add your time filter widget here
//             // For example, a TimePicker
//             ElevatedButton(
//               onPressed: () {
//                 // Show time picker
//               },
//               child: Text('Select Time'),
//             ),
//             SizedBox(height: 16),
//             // Filter by Price Per Seat
//             Text(
//               'Price Per Seat:',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             // Add your price per seat filter widget here
//             // For example, a Slider or TextFormField
//             TextFormField(
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Enter Price',
//               ),
//             ),
//             SizedBox(height: 16),
//             // Filter by Maximum Walking Distance
//             Text(
//               'Maximum Walking Distance:',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             // Add your maximum walking distance filter widget here
//             // For example, a Slider or TextFormField
//             TextFormField(
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Enter Maximum Distance',
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Close the bottom sheet and trigger the method to reload rides with new filters
//                 Navigator.pop(context);
//                 // _loadRides();
//               },
//               child: Text('Apply Filters'),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
}

// class RideMatchingScreen extends StatelessWidget {
//   final GeoPoint userPickupLocation;
//   final GeoPoint userDropoffLocation;
//
//   RideMatchingScreen(
//       {required this.userPickupLocation, required this.userDropoffLocation});
//
//   @override
//   Widget build(BuildContext context) {
//     RideMatching rideMatching = RideMatching();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Filtered Rides'),
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: rideMatching.findRidesWithDistances(userPickupLocation, userDropoffLocation),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.data == null || snapshot.data!.isEmpty) {
//             return Center(child: Text('No rides found.'));
//           } else {
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 var rideData = snapshot.data![index];
//                 var ride = rideData['ride'];
//                 double pickupDistance = rideData['pickupDistance'];
//                 double dropoffDistance = rideData['dropoffDistance'];
//                 GeoPoint closestCoordinateToPickup =
//                     rideData['closestCoordinateToPickup'];
//
//                 return GestureDetector(
//                   onTap: () {
//                     // Navigate to ride details screen
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => RideDetailsScreen(
//                           ride: ride,
//                           pickupDistance: pickupDistance,
//                           dropoffDistance: dropoffDistance,
//                           closestCoordinateToPickup: closestCoordinateToPickup,
//                           userLocation: userPickupLocation,
//                         ),
//                       ),
//                     );
//                   },
//                   child: CarpoolRideCard(
//                     ride: ride,
//                     pickupDistance: pickupDistance,
//                     dropoffDistance: dropoffDistance,
//                     closestCoordinateToPickup: closestCoordinateToPickup,
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// return ListView.builder(
//   itemCount: snapshot.data!.length,
//   itemBuilder: (context, index) {
//     var rideData = snapshot.data![index];
//     var ride = rideData['ride'];
//     double pickupDistance = rideData['pickupDistance'];
//     double dropoffDistance = rideData['dropoffDistance'];
//     GeoPoint closestCoordinateToPickup = rideData['closestCoordinateToPickup'];
//
//     return GestureDetector(
//       onTap: () {
//         // Navigate to ride details screen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => RideDetailsScreen(
//               ride: ride,
//               pickupDistance: pickupDistance,
//               dropoffDistance: dropoffDistance,
//               closestCoordinateToPickup: closestCoordinateToPickup,
//               userLocation: userPickupLocation,
//             ),
//           ),
//         );
//       },
//       child: ListTile(
//         title: Text('Ride ID: ${ride.id}'),
//         subtitle: Text('Seats: ${ride['seats']}, Vehicle: ${ride['vehicle']}, Pickup Distance: $pickupDistance meters, Dropoff Distance: $dropoffDistance meters'),
//         // Add more details here as needed
//       ),
//     );
//   },
// );

// class RideDetailsScreen extends StatelessWidget {
//   final DocumentSnapshot ride;
//
//   // final double pickupDistance;
//   final String pickupDistance;
//   final String dropoffDistance;
//
//   // final double dropoffDistance;
//   final GeoPoint closestCoordinateToPickup;
//   final GeoPoint closestCoordinateToDropoff;
//   final GeoPoint userPickupLocation;
//   final GeoPoint userDropoffLocation;
//   final Object driverDetails;
//
//   RideDetailsScreen({
//     super.key,
//     required this.ride,
//     required this.pickupDistance,
//     required this.dropoffDistance,
//     required this.closestCoordinateToPickup,
//     required this.driverDetails,
//     required this.closestCoordinateToDropoff,
//     required this.userPickupLocation,
//     required this.userDropoffLocation,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Build UI for ride details screen
//
//     var rideData = ride.data() as Map<String, dynamic>?;
//
// // Access the value of the 'date' field
// //     print("THIS IS RIDE DATAAAAAAAAAAAAAAA: $rideData");
//     // var rideDate = rideData?["date"];
//     // print("THIS IS HTEEEE DATEEEE: $rideDate");
//
//     // Assuming rideDate is of type Timestamp
//     Timestamp rideDate = rideData?['date'];
//
// // Convert the timestamp to a DateTime object
//     DateTime dateTime = rideDate.toDate();
//
// // Format the DateTime object into a human-readable date string
//     String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
//
// // Print the formatted date
//     print('Formatted Date: $formattedDate');
//
//     print("DRIVWEEEEEEEEEEEEEER AIYYAGEE DEETSSS TIKA: ${driverDetails['firstName']}");
//
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//               // Navigator.pop(
//               //   context,
//               //   MaterialPageRoute(builder: (context) => AvailableRides()),
//               // );
//             },
//             icon: Icon(Icons.arrow_back_ios)),
//         title: Text('Ride Details'),
//         titleSpacing: 0,
//         leadingWidth: 60.0,
//         backgroundColor: Colors.green,
//       ),
//       // body: Center(
//       //   child: Column(
//       //     mainAxisAlignment: MainAxisAlignment.center,
//       //     children: [
//       //       Text('Ride ID: ${ride.id}'),
//       //       Text('Seats: ${ride['seats']}'),
//       //       Text('Vehicle: ${ride['vehicle']}'),
//       //       Text('Pickup Distance: $pickupDistance meters'),
//       //       Text('Dropoff Distance: $dropoffDistance meters'),
//       //       // Add more details here as needed
//       //       ElevatedButton(
//       //         onPressed: () {
//       //           Navigator.push(
//       //             context,
//       //             MaterialPageRoute(
//       //               builder: (context) => RideMapScreen(
//       //                 ride: ride,
//       //                 closestCoordinateToPickup: closestCoordinateToPickup,
//       //                 userLocation: userLocation,
//       //               ),
//       //             ),
//       //           );
//       //         },
//       //         child: Text('View in Map'),
//       //       )
//       //     ],
//       //   ),
//       // ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Trip Information',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18.0,
//                             ),
//                           ),
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => RideMapScreen(
//                                     ride: ride,
//                                     closestCoordinateToPickup:
//                                         closestCoordinateToPickup,
//                                     closestCoordinateToDropoff:
//                                         closestCoordinateToDropoff,
//                                     userPickupLocation: userPickupLocation,
//                                     userDropoffLocation: userDropoffLocation,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Text('View in Map'),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 18.0),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.calendar_today,
//                             size: 20.0,
//                           ),
//                           SizedBox(width: 8.0),
//                           // Text('Saturday, 15 May 2024'),
//                           Text("$formattedDate"),
//                         ],
//                       ),
//                       SizedBox(height: 8.0),
//                       Row(
//                         children: [
//                           Icon(Icons.access_time, size: 20.0),
//                           SizedBox(width: 8.0),
//                           Text('${rideData?['rideDuration']} (Estimated)'),
//                         ],
//                       ),
//                       SizedBox(height: 8.0),
//                       Row(
//                         children: [
//                           Icon(Icons.route, size: 20.0),
//                           SizedBox(width: 8.0),
//                           Text('${rideData?['rideDistance']}km'),
//                         ],
//                       ),
//                       Divider(),
//                       SizedBox(height: 15.0),
//                       // Text("Pickup Location"),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Column(
//                             children: [
//                               Icon(Icons.location_on),
//                               Container(
//                                 height:
//                                     50.0, // Height of the dashed line container
//                                 child: CustomPaint(
//                                   painter: VerticalDashedLinePainter(),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(width: 8.0),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(ride['pickupCityName']),
//                               Text(
//                                 "${rideData?["pickupLocationName"]}",
//                                 style: TextStyle(fontSize: 12.0),
//                               ),
//                               Text(
//                                 '11.30 AM',
//                                 style: TextStyle(fontSize: 12.0),
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Icon(
//                                     Icons.directions_walk,
//                                     color: Colors.green,
//                                     size: 18.0,
//                                   ), // Human walking icon
//                                   Text(
//                                     '- ${pickupDistance} from your pickup location',
//                                     style: TextStyle(fontSize: 12.0),
//                                   ), // Distance
//                                 ],
//                               )
//                             ],
//                           )
//                         ],
//                       ),
//                       SizedBox(height: 20.0),
//                       // SizedBox(height: 5.0), // Add some space between texts and dashed line
//                       //
//                       // Container(
//                       //   height: 50.0, // Height of the dashed line container
//                       //   child: CustomPaint(
//                       //     painter: VerticalDashedLinePainter(),
//                       //   ),
//                       // ),
//                       // SizedBox(height: 5.0),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Column(
//                             children: [
//                               Container(
//                                 height:
//                                     50.0, // Height of the dashed line container
//                                 child: CustomPaint(
//                                   painter: VerticalDashedLinePainter(),
//                                 ),
//                               ),
//                               Icon(Icons.location_on),
//                             ],
//                           ),
//                           SizedBox(width: 8.0),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(ride['dropoffCityName']),
//                               // Text(
//                               //   "Kandy Station, Kandy",
//                               //   style: TextStyle(fontSize: 12.0),
//                               // ),
//                               Text(
//                                 "${rideData?['dropoffLocationName']}",
//                                 style: TextStyle(fontSize: 12.0),
//                               ),
//                               Text(
//                                 '02.15 PM',
//                                 style: TextStyle(fontSize: 12.0),
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Icon(
//                                     Icons.directions_walk,
//                                     color: Colors.red,
//                                     size: 18.0,
//                                   ), // Human walking icon
//                                   Text(
//                                     '- $dropoffDistance from your dropoff location',
//                                     style: TextStyle(fontSize: 12.0),
//                                   ), // Distance
//                                 ],
//                               )
//                             ],
//                           )
//                         ],
//                       ),
//                       SizedBox(height: 15.0),
//                       Divider(),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Seats Left: ${rideData?['seats']}'),
//                           SizedBox(width: 16.0),
//                           Text(
//                               'Price per Seat: LKR ${rideData?['pricePerSeat']}'),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 2.0),
//               Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Driver Information',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18.0,
//                         ),
//                       ),
//                       SizedBox(height: 8.0),
//                       Row(
//                         children: [
//                           Stack(
//                             alignment: Alignment.bottomRight,
//                             children: [
//                               CircleAvatar(
//                                 radius: 30.0,
//                                 child: Icon(
//                                   Icons.person,
//                                   size: 20.0,
//                                 ),
//                               ),
//                               Icon(Icons.verified_user,
//                                   color: Colors.green, size: 20),
//                             ],
//                           ),
//                           SizedBox(width: 8.0),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('John Doe',
//                                   style: TextStyle(fontSize: 16.0)),
//                               Row(
//                                 children: [
//                                   Text('4.5', style: TextStyle(fontSize: 12.0)),
//                                   Icon(
//                                     Icons.star,
//                                     color: Colors.blueGrey,
//                                     size: 14.0,
//                                   ),
//                                   SizedBox(
//                                     width: 10.0,
//                                   ),
//                                   Text('25 Reviews',
//                                       style: TextStyle(fontSize: 12.0)),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8.0),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.directions_car,
//                                 size: 24.0,
//                               ),
//                               SizedBox(width: 8.0),
//                               Text(
//                                 'Toyota Prius (2018)',
//                                 style: TextStyle(fontSize: 12.0),
//                               ),
//                             ],
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               // Add functionality to contact driver
//                             },
//                             child: Row(
//                               children: [
//                                 Text('Contact Driver'),
//                                 SizedBox(
//                                   width: 5.0,
//                                 ),
//                                 Icon(
//                                   Icons.call,
//                                   size: 18.0,
//                                   color: Colors.black,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8.0),
//                       Divider(),
//                       // Text(
//                       //   'Ride Preferences',
//                       //   style: TextStyle(
//                       //     fontWeight: FontWeight.bold,
//                       //     fontSize: 18.0,
//                       //   ),
//                       // ),
//                       // SizedBox(height: 18.0),
//                       // Row(
//                       //   children: [
//                       //     Icon(Icons.flash_on),
//                       //     SizedBox(width: 8.0),
//                       //     Text('Instant Approval'),
//                       //   ],
//                       // ),
//                       // SizedBox(height: 18.0),
//                       // Row(
//                       //   children: [
//                       //     Icon(Icons.smoking_rooms),
//                       //     SizedBox(width: 8.0),
//                       //     Text('Smoking is Allowed'),
//                       //   ],
//                       // ),
//                       // SizedBox(height: 18.0),
//                       // Row(
//                       //   children: [
//                       //     Icon(Icons.pets),
//                       //     SizedBox(width: 8.0),
//                       //     Text('Pets are Allowed'),
//                       //   ],
//                       // ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Ride Preferences',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18.0,
//                             ),
//                           ),
//                           SizedBox(height: 18.0),
//                           // Render ride preferences dynamically
//                           if (rideData?['ridePreferences'] != null)
//                             for (var preference in rideData?['ridePreferences'])
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       getIconForPreference(preference),
//                                       // You can use a suitable icon based on the preference
//                                       SizedBox(width: 8.0),
//                                       Text(preference),
//                                     ],
//                                   ),
//                                   SizedBox(height: 18.0),
//                                   // Add space between preferences
//                                 ],
//                               ),
//                         ],
//                       ),
//                       SizedBox(height: 18.0),
//                       Divider(),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Co-passengers',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18.0,
//                             ),
//                           ),
//                           SizedBox(height: 18.0),
//                           // Render ride preferences dynamically
//                           if (rideData?['passengers'] != null && rideData?['passengers'].isNotEmpty)
//                             StreamBuilder(
//                               stream: FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: rideData?['passengers']).snapshots(),
//                               builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                                 if (snapshot.connectionState == ConnectionState.waiting) {
//                                   return CircularProgressIndicator(); // Placeholder while loading data
//                                 }
//                                 if (snapshot.hasError) {
//                                   return Text('Error: ${snapshot.error}');
//                                 }
//                                 if (snapshot.hasData && snapshot.data != null) {
//                                   return Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: snapshot.data!.docs.map((document) {
//                                       var passengerData = document.data() as Map<String, dynamic>?;
//                                       var firstName = passengerData?['firstName'];
//                                       var lastName = passengerData?['lastName'];
//                                       return Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Row(
//                                             children: [
//                                               CircleAvatar(), // You can set the avatar image here
//                                               SizedBox(width: 8.0),
//                                               Text('$firstName $lastName'), // Display passenger name
//                                             ],
//                                           ),
//                                           SizedBox(height: 18.0), // Add space between preferences
//                                         ],
//                                       );
//                                     }).toList(),
//                                   );
//                                 } else {
//                                   return Text('User data not found');
//                                 }
//                               },
//                             )
//                           else
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'No co-passengers',
//                                   style: TextStyle(
//                                     fontStyle: FontStyle.italic,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                       // Column(
//                       //   crossAxisAlignment: CrossAxisAlignment.start,
//                       //   children: [
//                       //     Text(
//                       //       'Co-passengers',
//                       //       style: TextStyle(
//                       //         fontWeight: FontWeight.bold,
//                       //         fontSize: 18.0,
//                       //       ),
//                       //     ),
//                       //     SizedBox(height: 18.0),
//                       //     // Render ride preferences dynamically
//                       //     if (rideData?['passengers'] != null && rideData?['passengers'].isNotEmpty)
//                       //       for (var passenger in rideData?['passengers'])
//                       //         Column(
//                       //           crossAxisAlignment: CrossAxisAlignment.start,
//                       //           children: [
//                       //             Row(
//                       //               children: [
//                       //                 // getIconForPreference(preference),
//                       //                 // You can use a suitable icon based on the preference
//                       //                 SizedBox(width: 8.0),
//                       //                 Text(passenger),
//                       //               ],
//                       //             ),
//                       //             SizedBox(height: 18.0), // Add space between preferences
//                       //           ],
//                       //         )
//                       //     else
//                       //       Column(
//                       //         crossAxisAlignment: CrossAxisAlignment.start,
//                       //         children: [
//                       //           Text(
//                       //             'No co-passengers',
//                       //             style: TextStyle(
//                       //               fontStyle: FontStyle.italic,
//                       //             ),
//                       //           ),
//                       //         ],
//                       //       ),
//                       //   ],
//                       // ),
//
//                       // Text(
//                       //   'Co-passengers',
//                       //   style: TextStyle(
//                       //     fontWeight: FontWeight.bold,
//                       //     fontSize: 18.0,
//                       //   ),
//                       // ),
//                       // SizedBox(height: 8.0),
//                       // Row(
//                       //   children: [
//                       //     CircleAvatar(),
//                       //     SizedBox(width: 8.0),
//                       //     Text('Jane Smith'),
//                       //   ],
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       // bottomNavigationBar: BottomSeatSelectionContainer(availableSeats: ride['seats'] ?? 4, ride: ride,),
//       bottomNavigationBar: BottomSeatSelectionContainer(
//         availableSeats: int.parse(ride['seats'] ?? '4'),
//         ride: ride,
//       ),
//     );
//   }
// }
//
// class VerticalDashedLinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 1.0
//       ..style = PaintingStyle.stroke;
//
//     final double dashHeight = 5.0;
//     final double dashSpace = 5.0;
//
//     double startY = 0.0;
//     while (startY < size.height) {
//       canvas.drawLine(
//         Offset(0.0, startY),
//         Offset(0.0, startY + dashHeight),
//         paint,
//       );
//       startY += dashHeight + dashSpace;
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }
//
// class DashedLinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 1.0
//       ..style = PaintingStyle.stroke;
//
//     final double dashWidth = 5.0;
//     final double dashSpace = 5.0;
//
//     double startX = 0.0;
//     while (startX < size.width) {
//       canvas.drawLine(
//         Offset(startX, 0.0),
//         Offset(startX + dashWidth, 0.0),
//         paint,
//       );
//       startX += dashWidth + dashSpace;
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }
//
// // class BottomSeatSelectionContainer extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       // color: Colors.grey[200],
// //       padding: EdgeInsets.all(16.0),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           ElevatedButton(
// //             onPressed: () {
// //               // Show seat selection screen
// //               showModalBottomSheet(
// //                 context: context,
// //                 builder: (BuildContext context) {
// //                   return SeatSelectionBottomSheet();
// //                 },
// //               );
// //             },
// //             child: Text('Select Seats'),
// //           ),
// //           ElevatedButton(
// //             onPressed: () {
// //               // Continue button functionality
// //             },
// //             child: Text('Continue'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// class BottomSeatSelectionContainer extends StatefulWidget {
//   final int availableSeats;
//   final DocumentSnapshot ride;
//
//   const BottomSeatSelectionContainer(
//       {super.key, required this.availableSeats, required this.ride});
//
//   @override
//   _BottomSeatSelectionContainerState createState() =>
//       _BottomSeatSelectionContainerState();
// }
//
// class _BottomSeatSelectionContainerState
//     extends State<BottomSeatSelectionContainer> {
//   int selectedSeats = 0;
//
//   void updateSelectedSeats(int count) {
//     print("updateee method: $count");
//     setState(() {
//       selectedSeats = count;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               TextButton(
//                 onPressed: () {
//                   showModalBottomSheet(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return SeatSelectionBottomSheet(
//                         availableSeats: widget.availableSeats,
//                         initialSeats: selectedSeats,
//                         onUpdate: updateSelectedSeats,
//                       );
//                     },
//                   );
//                 },
//                 child: Row(
//                   // children: [
//                   //   Text("Select Seats"),
//                   //   Icon(Icons.keyboard_arrow_down),
//                   // ],
//                   children: [
//                     Text(selectedSeats >= 1
//                         ? "Seats Selected: ${selectedSeats.toString()}"
//                         : "Select Seats"),
//                     Icon(Icons.keyboard_arrow_down),
//                   ],
//                 ),
//               )
//             ],
//           ),
//           ElevatedButton(
//             style: ButtonStyle(
//               backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
//             ),
//             onPressed: () {
//               // Navigate to ConfirmBookingPage with necessary parameters
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ConfirmBookingPage(
//                     ride: widget.ride,
//                     // Pass the ride details to the confirm booking page
//                     selectedSeats:
//                         selectedSeats, // Pass the selected number of seats
//                   ),
//                 ),
//               );
//             },
//             child: Text('Continue'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class SeatSelectionBottomSheet extends StatefulWidget {
//   final int availableSeats;
//   final int initialSeats;
//   final Function(int) onUpdate;
//
//   SeatSelectionBottomSheet({
//     required this.availableSeats,
//     required this.initialSeats,
//     required this.onUpdate,
//   });
//
//   @override
//   _SeatSelectionBottomSheetState createState() =>
//       _SeatSelectionBottomSheetState();
// }
//
// class _SeatSelectionBottomSheetState extends State<SeatSelectionBottomSheet> {
//   late int selectedSeats;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedSeats = widget.initialSeats;
//   }
//
//   void increaseSeats() {
//     setState(() {
//       if (selectedSeats < widget.availableSeats) {
//         selectedSeats++;
//         widget.onUpdate(selectedSeats);
//         print(selectedSeats);
//       }
//     });
//   }
//
//   void decreaseSeats() {
//     setState(() {
//       if (selectedSeats > 1) {
//         selectedSeats--;
//         widget.onUpdate(selectedSeats);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Select Number of Seats',
//             style: TextStyle(
//               fontSize: 18.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 16.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               IconButton(
//                 onPressed: decreaseSeats,
//                 icon: Icon(Icons.remove),
//               ),
//               Text(
//                 '$selectedSeats',
//                 style: TextStyle(fontSize: 16.0),
//               ),
//               IconButton(
//                 onPressed: increaseSeats,
//                 icon: Icon(Icons.add),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
