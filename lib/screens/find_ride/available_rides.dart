import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:lyft_mate/screens/find_ride/ride_route.dart';
import '../../services/ride_matching_service.dart';
import 'carpool_ride_card_widget.dart';
import 'confirm_booking.dart';

class RideMatchingScreen extends StatelessWidget {
  final GeoPoint userPickupLocation;
  final GeoPoint userDropoffLocation;

  RideMatchingScreen(
      {required this.userPickupLocation, required this.userDropoffLocation, });

  @override
  Widget build(BuildContext context) {
    RideMatching rideMatching = RideMatching();

    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Rides'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: rideMatching.findRidesWithDistances(LatLng(userPickupLocation.latitude, userPickupLocation.longitude), LatLng(userDropoffLocation.latitude, userDropoffLocation.longitude)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No rides found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var rideData = snapshot.data![index];
                var ride = rideData['ride'];
                // double pickupDistance = rideData['pickupDistance'];
                String pickupDistance = rideData['pickupDistanceText'];
                String dropoffDistance = rideData['dropoffDistanceText'];

                // double dropoffDistance = rideData['dropoffDistance'];
                // GeoPoint closestCoordinateToPickup =
                // rideData['closestCoordinateToPickup'];
                // GeoPoint closestCoordinateToDropoff =
                // rideData['closestCoordinateToDropoff'];

                LatLng closestCoordinateToPickupLatLng =
                rideData['closestSnappedPickupCoordinate'];
                LatLng closestCoordinateToDropoffLatLng =
                rideData['closestSnappedDropoffCoordinate'];

                GeoPoint closestCoordinateToPickup = GeoPoint(
                  rideData['closestSnappedPickupCoordinate'].latitude,
                  rideData['closestSnappedPickupCoordinate'].longitude,
                );

                GeoPoint closestCoordinateToDropoff = GeoPoint(
                  rideData['closestSnappedDropoffCoordinate'].latitude,
                  rideData['closestSnappedDropoffCoordinate'].longitude,
                );

                // Get the driver ID from the ride
                String driverId = ride['driverId'];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(driverId).get(),
                  builder: (context, driverSnapshot) {
                    if (driverSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (driverSnapshot.hasError) {
                      return Text('Error: ${driverSnapshot.error}');
                    } else if (!driverSnapshot.hasData || driverSnapshot.data!.data() == null) {
                      return Text('No driver data found');
                    } else {
                      var driverData = driverSnapshot.data!;
                      // Now you have driver details, you can display them as needed
                      // For example, you can access driverData['name'], driverData['age'], etc.
                      print("DRriveeeeeeeeer nameeee: ${driverData["firstName"]}");
                      return GestureDetector(
                        onTap: () {
                          // Navigate to ride details screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RideDetailsScreen(
                                ride: ride,
                                pickupDistance: pickupDistance,
                                dropoffDistance: dropoffDistance,
                                closestCoordinateToPickup: closestCoordinateToPickup,
                                closestCoordinateToDropoff: closestCoordinateToDropoff,
                                userPickupLocation: userPickupLocation,
                                userDropoffLocation: userDropoffLocation,
                                driverDetails: driverData,
                              ),
                            ),
                          );
                        },
                        child: CarpoolRideCard(
                          ride: ride,
                          pickupDistance: pickupDistance,
                          dropoffDistance: dropoffDistance,
                          closestCoordinateToPickup: closestCoordinateToPickup,
                          driver: driverData,
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
  // void _showFilterOptions(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         padding: EdgeInsets.all(16.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           // mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             Text(
  //               'Filter Options',
  //               style: TextStyle(
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             SizedBox(height: 16),
  //             // Add your filter options widgets here
  //             // For example, DropdownButton, SwitchListTile, etc.
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

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Filter Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              // Filter by Date
              Text(
                'Date:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Add your date filter widget here
              // For example, a DatePicker
              ElevatedButton(
                onPressed: () {
                  // Show date picker
                },
                child: Text('Select Date'),
              ),
              SizedBox(height: 16),
              // Filter by Time
              Text(
                'Time:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Add your time filter widget here
              // For example, a TimePicker
              ElevatedButton(
                onPressed: () {
                  // Show time picker
                },
                child: Text('Select Time'),
              ),
              SizedBox(height: 16),
              // Filter by Price Per Seat
              Text(
                'Price Per Seat:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Add your price per seat filter widget here
              // For example, a Slider or TextFormField
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Price',
                ),
              ),
              SizedBox(height: 16),
              // Filter by Maximum Walking Distance
              Text(
                'Maximum Walking Distance:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Add your maximum walking distance filter widget here
              // For example, a Slider or TextFormField
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Maximum Distance',
                ),
              ),
            ],
          ),
        );
      },
    );
  }


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



class RideDetailsScreen extends StatelessWidget {
  final DocumentSnapshot ride;
  // final double pickupDistance;
  final String pickupDistance;
  final String dropoffDistance;
  // final double dropoffDistance;
  final GeoPoint closestCoordinateToPickup;
  final GeoPoint closestCoordinateToDropoff;
  final GeoPoint userPickupLocation;
  final GeoPoint userDropoffLocation;
  final Object driverDetails;

  RideDetailsScreen({super.key,
    required this.ride,
    required this.pickupDistance,
    required this.dropoffDistance,
    required this.closestCoordinateToPickup,
    required this.driverDetails, required this.closestCoordinateToDropoff, required this.userPickupLocation, required this.userDropoffLocation,
  });

  @override
  Widget build(BuildContext context) {
    // Build UI for ride details screen
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigator.pop(
              //   context,
              //   MaterialPageRoute(builder: (context) => AvailableRides()),
              // );
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text('Ride Details'),
        titleSpacing: 0,
        leadingWidth: 60.0,
        backgroundColor: Colors.green,
      ),
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Text('Ride ID: ${ride.id}'),
      //       Text('Seats: ${ride['seats']}'),
      //       Text('Vehicle: ${ride['vehicle']}'),
      //       Text('Pickup Distance: $pickupDistance meters'),
      //       Text('Dropoff Distance: $dropoffDistance meters'),
      //       // Add more details here as needed
      //       ElevatedButton(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => RideMapScreen(
      //                 ride: ride,
      //                 closestCoordinateToPickup: closestCoordinateToPickup,
      //                 userLocation: userLocation,
      //               ),
      //             ),
      //           );
      //         },
      //         child: Text('View in Map'),
      //       )
      //     ],
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trip Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RideMapScreen(
                                    ride: ride,
                                    closestCoordinateToPickup:
                                        closestCoordinateToPickup,
                                    closestCoordinateToDropoff: closestCoordinateToDropoff,
                                    userPickupLocation: userPickupLocation,
                                    userDropoffLocation: userDropoffLocation,
                                  ),
                                ),
                              );
                            },
                            child: Text('View in Map'),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.0),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 20.0,
                          ),
                          SizedBox(width: 8.0),
                          Text('Saturday, 15 May 2024'),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 20.0),
                          SizedBox(width: 8.0),
                          Text(' (Estimated)'),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.route, size: 20.0),
                          SizedBox(width: 8.0),
                          Text('110km'),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 15.0),
                      // Text("Pickup Location"),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.location_on),
                              Container(
                                height:
                                    50.0, // Height of the dashed line container
                                child: CustomPaint(
                                  painter: VerticalDashedLinePainter(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ride['pickupCityName']),
                              Text(
                                "Fort Station, Colombo Fort",
                                style: TextStyle(fontSize: 12.0),
                              ),
                              Text(
                                '11.30 AM',
                                style: TextStyle(fontSize: 12.0),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.directions_walk,
                                    color: Colors.green,
                                    size: 18.0,
                                  ), // Human walking icon
                                  Text(
                                    '- ${pickupDistance} from your pickup location',
                                    style: TextStyle(fontSize: 12.0),
                                  ), // Distance
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 20.0),
                      // SizedBox(height: 5.0), // Add some space between texts and dashed line
                      //
                      // Container(
                      //   height: 50.0, // Height of the dashed line container
                      //   child: CustomPaint(
                      //     painter: VerticalDashedLinePainter(),
                      //   ),
                      // ),
                      // SizedBox(height: 5.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                height:
                                    50.0, // Height of the dashed line container
                                child: CustomPaint(
                                  painter: VerticalDashedLinePainter(),
                                ),
                              ),
                              Icon(Icons.location_on),
                            ],
                          ),
                          SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ride['dropoffCityName']),
                              Text(
                                "Kandy Station, Kandy",
                                style: TextStyle(fontSize: 12.0),
                              ),
                              Text(
                                '02.15 PM',
                                style: TextStyle(fontSize: 12.0),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.directions_walk,
                                    color: Colors.red,
                                    size: 18.0,
                                  ), // Human walking icon
                                  Text(
                                    '- $dropoffDistance from your dropoff location',
                                    style: TextStyle(fontSize: 12.0),
                                  ), // Distance
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 15.0),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Seats Left: 2'),
                          SizedBox(width: 16.0),
                          Text('Price per Seat: LKR 300'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.0),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driver Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 30.0,
                                child: Icon(
                                  Icons.person,
                                  size: 20.0,
                                ),
                              ),
                              Icon(Icons.verified_user,
                                  color: Colors.green, size: 20),
                            ],
                          ),
                          SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('John Doe',
                                  style: TextStyle(fontSize: 16.0)),
                              Row(
                                children: [
                                  Text('4.5', style: TextStyle(fontSize: 12.0)),
                                  Icon(
                                    Icons.star,
                                    color: Colors.blueGrey,
                                    size: 14.0,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text('25 Reviews',
                                      style: TextStyle(fontSize: 12.0)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.directions_car,
                                size: 24.0,
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'Toyota Prius (2018)',
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              // Add functionality to contact driver
                            },
                            child: Row(
                              children: [
                                Text('Contact Driver'),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Icon(
                                  Icons.call,
                                  size: 18.0,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Divider(),
                      Text(
                        'Ride Preferences',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(height: 18.0),
                      Row(
                        children: [
                          Icon(Icons.flash_on),
                          SizedBox(width: 8.0),
                          Text('Instant Approval'),
                        ],
                      ),
                      SizedBox(height: 18.0),
                      Row(
                        children: [
                          Icon(Icons.smoking_rooms),
                          SizedBox(width: 8.0),
                          Text('Smoking is Allowed'),
                        ],
                      ),
                      SizedBox(height: 18.0),
                      Row(
                        children: [
                          Icon(Icons.pets),
                          SizedBox(width: 8.0),
                          Text('Pets are Allowed'),
                        ],
                      ),
                      SizedBox(height: 18.0),
                      Divider(),
                      Text(
                        'Co-passengers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          CircleAvatar(),
                          SizedBox(width: 8.0),
                          Text('Jane Smith'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomSeatSelectionContainer(availableSeats: ride['seats'] ?? 4, ride: ride,),
      bottomNavigationBar: BottomSeatSelectionContainer(
        availableSeats: int.parse(ride['seats'] ?? '4'),
        ride: ride,
      ),
    );
  }




}

class VerticalDashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double dashHeight = 5.0;
    final double dashSpace = 5.0;

    double startY = 0.0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(0.0, startY),
        Offset(0.0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double dashWidth = 5.0;
    final double dashSpace = 5.0;

    double startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0.0),
        Offset(startX + dashWidth, 0.0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// class BottomSeatSelectionContainer extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // color: Colors.grey[200],
//       padding: EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               // Show seat selection screen
//               showModalBottomSheet(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return SeatSelectionBottomSheet();
//                 },
//               );
//             },
//             child: Text('Select Seats'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Continue button functionality
//             },
//             child: Text('Continue'),
//           ),
//         ],
//       ),
//     );
//   }
// }

class BottomSeatSelectionContainer extends StatefulWidget {
  final int availableSeats;
  final DocumentSnapshot ride;

  const BottomSeatSelectionContainer({super.key, required this.availableSeats, required this.ride});

  @override
  _BottomSeatSelectionContainerState createState() =>
      _BottomSeatSelectionContainerState();
}

class _BottomSeatSelectionContainerState
    extends State<BottomSeatSelectionContainer> {
  int selectedSeats = 0;

  void updateSelectedSeats(int count) {
    print("updateee method: $count");
    setState(() {
      selectedSeats = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SeatSelectionBottomSheet(
                        availableSeats: widget.availableSeats,
                        initialSeats: selectedSeats,
                        onUpdate: updateSelectedSeats,
                      );
                    },
                  );
                },
                child: Row(
                  // children: [
                  //   Text("Select Seats"),
                  //   Icon(Icons.keyboard_arrow_down),
                  // ],
                  children: [
                    Text(selectedSeats >= 1 ? "Seats Selected: ${selectedSeats.toString()}" : "Select Seats"),
                    Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              )
            ],
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () {
              // Navigate to ConfirmBookingPage with necessary parameters
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmBookingPage(
                    ride: widget.ride, // Pass the ride details to the confirm booking page
                    selectedSeats: selectedSeats, // Pass the selected number of seats
                  ),
                ),
              );
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class SeatSelectionBottomSheet extends StatefulWidget {
  final int availableSeats;
  final int initialSeats;
  final Function(int) onUpdate;

  SeatSelectionBottomSheet({
    required this.availableSeats,
    required this.initialSeats,
    required this.onUpdate,
  });

  @override
  _SeatSelectionBottomSheetState createState() =>
      _SeatSelectionBottomSheetState();
}

class _SeatSelectionBottomSheetState extends State<SeatSelectionBottomSheet> {
  late int selectedSeats;

  @override
  void initState() {
    super.initState();
    selectedSeats = widget.initialSeats;
  }

  void increaseSeats() {
    setState(() {
      if (selectedSeats < widget.availableSeats) {
        selectedSeats++;
        widget.onUpdate(selectedSeats);
        print(selectedSeats);
      }
    });
  }

  void decreaseSeats() {
    setState(() {
      if (selectedSeats > 1) {
        selectedSeats--;
        widget.onUpdate(selectedSeats);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Number of Seats',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: decreaseSeats,
                icon: Icon(Icons.remove),
              ),
              Text(
                '$selectedSeats',
                style: TextStyle(fontSize: 16.0),
              ),
              IconButton(
                onPressed: increaseSeats,
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



