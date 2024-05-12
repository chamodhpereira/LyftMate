import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lyft_mate/screens/find_ride/ride_request_sent_screen.dart';
import 'package:lyft_mate/screens/find_ride/ride_route.dart';

import '../../widgets/icon_preference.dart';
import '../chat/dash_chatpage.dart';
import '../profile/other_userprofile.dart';
import 'confirm_booking.dart';

class RideDetailsScreen extends StatelessWidget {
  final DocumentSnapshot ride;

  final String pickupDistance;
  final String dropoffDistance;

  final GeoPoint closestCoordinateToPickup;
  final GeoPoint closestCoordinateToDropoff;
  final GeoPoint userPickupLocation;
  final GeoPoint userDropoffLocation;
  final DocumentSnapshot driverDetails;

  const RideDetailsScreen({
    super.key,
    required this.ride,
    required this.pickupDistance,
    required this.dropoffDistance,
    required this.closestCoordinateToPickup,
    required this.driverDetails,
    required this.closestCoordinateToDropoff,
    required this.userPickupLocation,
    required this.userDropoffLocation,
    // required this.startTime,
    // required this.endTime,
  });

  Duration parseDuration(String durationStr) {
    List<String> parts = durationStr.split(' ');
    int hours = 0;
    int minutes = 0;

    for (int i = 0; i < parts.length; i += 2) {
      int value = int.parse(parts[i]);
      if (parts[i + 1] == 'hours' || parts[i + 1] == 'hour') {
        hours = value;
      } else if (parts[i + 1] == 'minutes' || parts[i + 1] == 'minute') {
        minutes = value;
      }
    }

    return Duration(hours: hours, minutes: minutes);
  }

  // Helper function to format DateTime object as string
  String formatTime(DateTime time) {
    String period = time.hour < 12 ? 'AM' : 'PM';
    int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";
  }


  @override
  Widget build(BuildContext context) {

    var rideData = ride.data() as Map<String, dynamic>?;

    Timestamp rideDate = rideData?['date'];

    // Convert the timestamp to a DateTime object
    DateTime dateTime = rideDate.toDate();

    // Format the DateTime object into a human-readable date string
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    debugPrint('Formatted Date: $formattedDate');

    debugPrint("Driver Deets: ${driverDetails['firstName']}");


    // Parse start time and duration
    DateTime rideStartTime = (ride['time'] as Timestamp).toDate();
    Duration duration = parseDuration(ride['rideDuration']);

    // Calculate end time by adding duration to start time
    DateTime rideEndTime = rideStartTime.add(duration);


    // Retrieve the rideBookingType from Firestore data
    String rideBookingType = rideData?['rideApproval'] ?? "instant"; // Default to "instant"
    String bookingButtonText = (rideBookingType == "Request") ? "Request Ride" : "Continue";

    debugPrint("---------Rideeee Approval----------");
    debugPrint("$rideBookingType");


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text('Ride Details'),
        // titleSpacing: 0,
        // leadingWidth: 60.0,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Trip Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              // shape: const RoundedRectangleBorder(),
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.green,
                              // side: const BorderSide(color: kSecondaryColor),
                              // padding: const EdgeInsets.symmetric(vertical: 15.0),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RideMapScreen(
                                    ride: ride,
                                    closestCoordinateToPickup:
                                    closestCoordinateToPickup,
                                    closestCoordinateToDropoff:
                                    closestCoordinateToDropoff,
                                    userPickupLocation: userPickupLocation,
                                    userDropoffLocation: userDropoffLocation,
                                  ),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Text('View in Map',),
                                SizedBox(width: 2,),
                                Icon(Icons.map),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18.0),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 20.0,
                          ),
                          SizedBox(width: 8.0),
                          // Text('Saturday, 15 May 2024'),
                          Text("$formattedDate"),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 20.0),
                          SizedBox(width: 8.0),
                          Text('${rideData?['rideDuration']} (Estimated)'),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.route, size: 20.0),
                          SizedBox(width: 8.0),
                          Text('${rideData?['rideDistance']}km'),
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
                                "${rideData?["pickupLocationName"]}",
                                style: TextStyle(fontSize: 12.0),
                              ),
                              // Text(
                              //   '11.30 AM',
                              //   style: TextStyle(fontSize: 12.0),
                              // ),
                              Text('${formatTime(rideStartTime)}', style: TextStyle(fontSize: 12.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.directions_walk,
                                    color: Colors.green,
                                    size: 18.0,
                                  ), // Human walking icon
                                  Text(
                                    '- $pickupDistance from your pickup location',
                                    style: TextStyle(fontSize: 12.0),
                                  ), // Distance
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height:
                                50.0, // Height of the dashed line container
                                child: CustomPaint(
                                  painter: VerticalDashedLinePainter(),
                                ),
                              ),
                              const Icon(Icons.location_on),
                            ],
                          ),
                          const SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ride['dropoffCityName']),
                              Text(
                                "${rideData?['dropoffLocationName']}",
                                style: TextStyle(fontSize: 12.0),
                              ),
                              // Text(
                              //   '02.15 PM',
                              //   style: TextStyle(fontSize: 12.0),
                              // ),
                              Text('${formatTime(rideEndTime)}', style: TextStyle(fontSize: 12.0)),
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
                          Text('Seats Left: ${rideData?['seats']}'),
                          SizedBox(width: 16.0),
                          Text(
                              'Price per Seat: LKR ${rideData?['pricePerSeat']}'),
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
                                backgroundImage: driverDetails != null &&
                                    driverDetails['profileImageUrl'] != null &&
                                    driverDetails['profileImageUrl'].isNotEmpty
                                    ? NetworkImage(driverDetails['profileImageUrl'])
                                    : null,
                                child: driverDetails == null ||
                                    driverDetails['profileImageUrl'] == null ||
                                    driverDetails['profileImageUrl'].isEmpty
                                    ? const Icon(
                                  Icons.person,
                                  size: 20.0,
                                )
                                    : null,
                              ),
                              Positioned(
                                bottom: -2, // Adjust as needed to move towards the bottom
                                right:-2, // Adjust as needed to move towards the right
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.green.shade700,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),



                          SizedBox(width: 8.0),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Text('${driverDetails['firstName']} ${driverDetails['lastName']}',
                          //         style: TextStyle(fontSize: 16.0)),
                          //     Row(
                          //       children: [
                          //         Text('${driverDetails['ratings']}', style: TextStyle(fontSize: 12.0)),
                          //         Icon(
                          //           Icons.star,
                          //           color: Colors.orangeAccent.shade200,
                          //           size: 15.0,
                          //         ),
                          //         SizedBox(
                          //           width: 10.0,
                          //         ),
                          //         Text('${driverDetails['reviews'].length} Reviews',
                          //             style: TextStyle(fontSize: 12.0)),
                          //       ],
                          //     ),
                          //   ],
                          // ),
                          GestureDetector(
                            onTap: () {
                              // Replace with the appropriate way to access driver ID
                              final String driverId = rideData?['driverId'];

                              // Navigate to the other user's profile screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtherUserProfileScreen(userId: driverId,),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${driverDetails['firstName']} ${driverDetails['lastName']}',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                Row(
                                  children: [
                                    Text('${driverDetails['ratings']}', style: const TextStyle(fontSize: 12.0)),
                                    Icon(
                                      Icons.star,
                                      color: Colors.orangeAccent.shade200,
                                      size: 15.0,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      '${driverDetails['reviews'].length} Reviews',
                                      style: const TextStyle(fontSize: 12.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                                '${rideData?['vehicle']}',
                                style: TextStyle(fontSize: 12.0),
                              ),
                              // Text(
                              //   'Toyota Prius (2018)',
                              //   style: TextStyle(fontSize: 12.0),
                              // ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              // debugPrint("Driver Details: ${driverDetails.data()}");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DashChatPage(
                                    receiverUserEmail: driverDetails['email'] ?? "",
                                    receiverUserID: ride['driverId'],
                                  ),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Text('Contact Driver', style: TextStyle(color: Colors.black),),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Icon(
                                  Icons.send,
                                  size: 18.0,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ride Preferences',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          const SizedBox(height: 18.0),
                          // Render ride preferences dynamically
                          if (rideData?['ridePreferences'] != null)
                            for (var preference in rideData?['ridePreferences'])
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      getIconForPreference(preference),
                                      // You can use a suitable icon based on the preference
                                      const SizedBox(width: 8.0),
                                      Text(preference),
                                    ],
                                  ),
                                  SizedBox(height: 18.0),
                                  // Add space between preferences
                                ],
                              ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.luggage),
                                  SizedBox(width: 8.0),
                                  Text("Luggage Allowance: "),
                                  Text(ride["luggageAllowance"]),
                                ],
                              ),
                              const SizedBox(height: 18.0),
                              Row(
                                children: [
                                  const Icon(Icons.money_outlined),
                                  SizedBox(width: 8.0),
                                  Text("Payment: "),
                                  Text(ride["paymentMode"]),
                                ],
                              )
                            ],
                          )
                        ],
                      ),

                      SizedBox(height: 18.0),
                      Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Co-passengers',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          const SizedBox(height: 18.0),
                          if (rideData?['passengers'] != null && rideData?['passengers'].isNotEmpty)
                            StreamBuilder(
                              stream: FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: rideData?['passengers'].map((passenger) => passenger['userId']).toList()).snapshots(),
                              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator(); // Placeholder while loading data
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: snapshot.data!.docs.map((document) {
                                      var passengerData = document.data() as Map<String, dynamic>?;
                                      var firstName = passengerData?['firstName'];
                                      var lastName = passengerData?['lastName'];
                                      var passengerId = document.id; // Assuming the document ID is the user ID
                                      var profileImageUrl = passengerData?['profileImageUrl'];

                                      return GestureDetector(
                                        onTap: () {
                                          // Navigate to the other user's profile screen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OtherUserProfileScreen(userId: passengerId),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 20.0, // Adjust the radius as per your design
                                                  backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                                      ? NetworkImage(profileImageUrl)
                                                      : null, // Use the image URL if available
                                                  child: profileImageUrl == null || profileImageUrl.isEmpty
                                                      ? const Icon(Icons.person, size: 20.0) // Default icon when no profile image
                                                      : null,
                                                ),
                                                const SizedBox(width: 8.0),
                                                Text('$firstName $lastName'), // Display passenger name
                                              ],
                                            ),
                                            const SizedBox(height: 18.0), // Add space between each passenger
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  );
                                } else {
                                  return const Text('User data not found');
                                }
                              },
                            )
                          else
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No co-passengers',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
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
        // availableSeats: int.parse(ride['seats'] ?? '4'),
        availableSeats: ride['seats'],
        ride: ride,
        bookingButtonText: bookingButtonText, // Pass the button text here
        rideBookingType: rideBookingType, // Pass the booking type here
        userPickupCoordinate: closestCoordinateToPickup,
        userDropoffCoordinate: closestCoordinateToDropoff, driver: driverDetails,
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

    const double dashHeight = 5.0;
    const double dashSpace = 5.0;

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

// class BottomSeatSelectionContainer extends StatefulWidget {
//   final int availableSeats;
//   final DocumentSnapshot ride;
//   final DocumentSnapshot driver;
//   final GeoPoint userPickupCoordinate;
//   final GeoPoint userDropoffCoordinate;
//
//   const BottomSeatSelectionContainer(
//       {super.key, required this.availableSeats, required this.ride, required this.userPickupCoordinate, required this.userDropoffCoordinate, required this.driver});
//
//   @override
//   _BottomSeatSelectionContainerState createState() =>
//       _BottomSeatSelectionContainerState();
// }

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
//                     const Icon(Icons.keyboard_arrow_down),
//                   ],
//                 ),
//               )
//             ],
//           ),
//           ElevatedButton(
//             style: ButtonStyle(
//               backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
//               foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//             ),
//             // onPressed: () {
//             //   // Navigate to ConfirmBookingPage with necessary parameters
//             //   Navigator.push(
//             //     context,
//             //     MaterialPageRoute(
//             //       builder: (context) => ConfirmBookingPage(
//             //         ride: widget.ride,
//             //         // Pass the ride details to the confirm booking page
//             //         selectedSeats:
//             //         selectedSeats, // Pass the selected number of seats
//             //         userPickupCoordinate: widget.userPickupCoordinate,
//             //         userDropoffCoordinate: widget.userDropoffCoordinate,
//             //       ),
//             //     ),
//             //   );
//             // },
//             onPressed: () {
//               if (selectedSeats > 0) {
//                 // Navigate to ConfirmBookingPage with necessary parameters
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ConfirmBookingPage(
//                       ride: widget.ride,
//                       driverDetails: widget.driver,
//                       // Pass the ride details to the confirm booking page
//                       selectedSeats:
//                       selectedSeats, // Pass the selected number of seats
//                       userPickupCoordinate: widget.userPickupCoordinate,
//                       userDropoffCoordinate: widget.userDropoffCoordinate,
//                     ),
//                   ),
//                 );
//               } else {
//                 // Show a scaffold message
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Please select at least one seat.'),
//                   ),
//                 );
//               }
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
  final DocumentSnapshot driver;
  final GeoPoint userPickupCoordinate;
  final GeoPoint userDropoffCoordinate;
  final String bookingButtonText; // Add this field
  final String rideBookingType; // Add the booking type

  const BottomSeatSelectionContainer({
    super.key,
    required this.availableSeats,
    required this.ride,
    required this.userPickupCoordinate,
    required this.userDropoffCoordinate,
    required this.driver,
    required this.bookingButtonText,
    required this.rideBookingType,
  });

  @override
  _BottomSeatSelectionContainerState createState() =>
      _BottomSeatSelectionContainerState();
}

class _BottomSeatSelectionContainerState extends State<BottomSeatSelectionContainer> {
  int selectedSeats = 0;
  bool isLoading = false; // Track loading state

  void updateSelectedSeats(int count) {
    setState(() {
      selectedSeats = count;
    });
  }

  void handleRequestRide(BuildContext context) async {
    double amountToBePaid = widget.ride['pricePerSeat'] * selectedSeats;
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('Current User ID: $currentUserId');

    var requestData = {
      'passengerId': currentUserId,
      'seatsRequested': selectedSeats,
      'pickupCoordinate': widget.userPickupCoordinate,
      'dropoffCoordinate': widget.userDropoffCoordinate,
      'amount': amountToBePaid,
      'paidStatus': false,
    };

    var rideRef = FirebaseFirestore.instance.collection('rides').doc(widget.ride.id);

    try {
      setState(() {
        isLoading = true; // Start loading
      });

      await rideRef.update({
        'rideRequests': FieldValue.arrayUnion([requestData]),
      });

      debugPrint("Ride request successfully added.");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RideRequestSentPage()), // Replace with your page
      );
    } catch (e) {
      debugPrint("Failed to add ride request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send ride request. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
                  children: [
                    Text(selectedSeats >= 1
                        ? "Seats Selected: ${selectedSeats.toString()}"
                        : "Select Seats"),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            onPressed: () {
              if (selectedSeats > 0) {
                if (widget.rideBookingType == "Request") {
                  handleRequestRide(context);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfirmBookingPage(
                        ride: widget.ride,
                        driverDetails: widget.driver,
                        selectedSeats: selectedSeats,
                        userPickupCoordinate: widget.userPickupCoordinate,
                        userDropoffCoordinate: widget.userDropoffCoordinate,
                      ),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select at least one seat.')),
                );
              }
            },
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white) // Show a progress indicator
                : Text(widget.bookingButtonText), // Show button text if not loading
          ),
        ],
      ),
    );
  }
}




// class _BottomSeatSelectionContainerState
//     extends State<BottomSeatSelectionContainer> {
//   int selectedSeats = 0;
//
//   void updateSelectedSeats(int count) {
//     setState(() {
//       selectedSeats = count;
//     });
//   }
//
//   void handleRequestRide(BuildContext context) async {
//     double amountToBePaid = widget.ride['pricePerSeat'] * selectedSeats;
//
//     String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
//     debugPrint('Current User ID: $currentUserId');
//
//     // Prepare the request data
//     var requestData = {
//       'passengerId': currentUserId, // Replace with actual current user ID
//       'seatsRequested': selectedSeats,
//       'pickupCoordinate': widget.userPickupCoordinate,
//       'dropoffCoordinate': widget.userDropoffCoordinate,
//       'amount': amountToBePaid, // Store the amount
//       'paidStatus': false,
//     };
//
//     // Add to "ride requests" array in Firestore
//     var rideRef = FirebaseFirestore.instance.collection('rides').doc(widget.ride.id);
//
//     try {
//       await rideRef.update({
//         'rideRequests': FieldValue.arrayUnion([requestData]),
//       });
//       debugPrint("Ride request successfully added.");
//       // Redirect to the Request Sent page
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(builder: (context) => RequestSentPage()),
//       // );
//
//       debugPrint("Redirecting to Request sent page.....");
//     } catch (e) {
//       debugPrint("Failed to add ride request: $e");
//       // Optionally, show an error message to the user
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to send ride request. Please try again.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Seat selection button logic
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
//                   children: [
//                     Text(selectedSeats >= 1
//                         ? "Seats Selected: ${selectedSeats.toString()}"
//                         : "Select Seats"),
//                     const Icon(Icons.keyboard_arrow_down),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//
//           // Main action button
//           ElevatedButton(
//             style: ButtonStyle(
//               backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
//               foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//             ),
//             onPressed: () {
//               if (selectedSeats > 0) {
//                 // Determine the action based on rideBookingType
//                 if (widget.rideBookingType == "Request") {
//                   handleRequestRide(context);
//                 } else {
//                   // Proceed to the confirmation page for instant booking
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ConfirmBookingPage(
//                         ride: widget.ride,
//                         driverDetails: widget.driver,
//                         selectedSeats: selectedSeats,
//                         userPickupCoordinate: widget.userPickupCoordinate,
//                         userDropoffCoordinate: widget.userDropoffCoordinate,
//                       ),
//                     ),
//                   );
//                 }
//               } else {
//                 // Show a warning message
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Please select at least one seat.')),
//                 );
//               }
//             },
//             child: Text(widget.bookingButtonText),
//           ),
//         ],
//       ),
//     );
//   }
// }


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