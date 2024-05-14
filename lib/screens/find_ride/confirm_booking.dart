import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'package:lyft_mate/screens/find_ride/ride_booked_screen.dart';
import 'package:lyft_mate/services/payment/payment_service.dart';
import 'package:geocoding/geocoding.dart';

class ConfirmBookingPage extends StatefulWidget {
  final DocumentSnapshot ride;
  final DocumentSnapshot driverDetails;
  final int selectedSeats;
  final GeoPoint userPickupCoordinate;
  final GeoPoint userDropoffCoordinate;

  ConfirmBookingPage({
    required this.ride,
    required this.selectedSeats, required this.userPickupCoordinate, required this.userDropoffCoordinate, required this.driverDetails,
  });

  @override
  _ConfirmBookingPageState createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  String? _paymentMethod;
  bool _isButtonDisabled = true;
  bool _isLoading = false;
  String _pickupLocationName = "";
  String _dropoffLocationName = "";
  User? currentUser = FirebaseAuth.instance.currentUser;
  String userEmail = '';
  String userFirstName = '';
  String userLastName = '';

  final client = Client();


  String _getApiKey() {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_DEFAULT_API_KEY';
  }


  Future<String> getLocationName(GeoPoint coordinates) async {
    final apiKey = _getApiKey();
    String baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
    String url = '$baseUrl?latlng=${coordinates.latitude},${coordinates.longitude}&key=$apiKey';

    try {
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          // Typically, the formatted address is quite reliable
          return data['results'][0]['formatted_address'];
        } else {
          return "No address available";
        }
      } else {
        return "Failed to fetch address";
      }
    } catch (e) {
      return "Error occurred: $e";
    }
  }

  Future<void> fetchUserData() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      setState(() {
        userEmail = userDoc.get('email');
        userFirstName = userDoc.get('firstName');
        userLastName = userDoc.get('lastName');
      });
    }
  }


  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchLocationNames();
  }

  void fetchLocationNames() async {
    String pickupLocationName = await getLocationName(widget.userPickupCoordinate);
    String dropoffLocationName = await getLocationName(widget.userDropoffCoordinate);

    setState(() {
      // Update your UI with these location names
      _pickupLocationName = pickupLocationName;
      _dropoffLocationName = dropoffLocationName;
    });
  }


  @override
  Widget build(BuildContext context) {
    // Timestamp rideDate = widget.ride['date'];
    // DateTime dateTime = rideDate.toDate();
    // String formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(dateTime);
    // String formattedTime = DateFormat('HH:mm a').format(dateTime);

    // Getting date from 'date' field
    Timestamp rideDate = widget.ride['date'];
    DateTime dateTime = rideDate.toDate();
    String formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(dateTime);

    // Getting time from 'time' field
    Timestamp rideTime = widget.ride['time'];
    DateTime timeOnly = rideTime.toDate();
    String formattedTime = DateFormat('HH:mm a').format(timeOnly);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Ride Booking'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              '$formattedDate at $formattedTime',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Ride ID: ${widget.ride.id}',
              style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'From: $_pickupLocationName',
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'To: $_dropoffLocationName',
              style: const TextStyle(fontSize: 14.0),
            ),
            const Divider(height: 30),
            ListTile(
              title: Text(
                '${widget.driverDetails['firstName']} ${widget.driverDetails['lastName']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${widget.driverDetails['ratings']} - ${widget.driverDetails['reviews'].length} Reviews',
                style: const TextStyle(color: Colors.grey),
              ),
              leading: CircleAvatar(
                radius: 30.0,
                backgroundImage: widget.driverDetails != null &&
                    widget.driverDetails['profileImageUrl'] != null &&
                    widget.driverDetails['profileImageUrl'].isNotEmpty
                    ? NetworkImage(widget.driverDetails['profileImageUrl'])
                    : null,
                child: widget.driverDetails == null ||
                    widget.driverDetails['profileImageUrl'] == null ||
                    widget.driverDetails['profileImageUrl'].isEmpty
                    ? const Icon(
                  Icons.person,
                  size: 20.0,
                )
                    : null,
              ),
            ),
            const Divider(height: 30),
            Text(
              'Booked seats: ${widget.selectedSeats}',
              style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Total amount: LKR ${widget.ride['pricePerSeat'] * widget.selectedSeats}',
              style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),
            const SizedBox(height: 10),
            _buildPaymentMethodSelection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 0, right: 12.0, bottom: 30.0),
        child: ElevatedButton(
          onPressed: _isButtonDisabled || _isLoading
              ? null
              : () async {
            // setState(() {
            //   _isLoading = true;
            // });

            if (_paymentMethod != null) {
              double amountToBePaid = widget.ride['pricePerSeat'] * widget.selectedSeats;
              bool result = false;

              if (_paymentMethod == 'cash') {
                setState(() {
                  _isLoading = true;
                });
                result = await _bookRide();
              } else if (_paymentMethod == 'card') {
                try {
                  String? paymentId = await PaymentService.makePayment(amountToBePaid, userEmail, '$userFirstName $userLastName');
                  if (paymentId != null) {
                    setState(() {
                      _isLoading = true;
                    });
                    result = await _bookRide(paymentId: paymentId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment failed. Please try again.')),
                    );
                  }

                } catch (e) {
                  print('An error occurred during payment: $e');
                  // Optionally show an error message to the user
                  if(context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('An error occurred. Please try again.')),
                    );
                  }
                }

              }

              if (result) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RideBookedPage()),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a payment method.')),
              );
            }

            setState(() {
              _isLoading = false;
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
              : const Text(
            "Book Ride",
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),

    );
  }



  Widget _buildPaymentMethodSelection() {
    String paymentMode = widget.ride['paymentMode']; // Assuming 'paymentMode' is the field containing payment mode


    if (paymentMode == 'Cash') {
      return Row(
        children: [
          const Text('Payment method', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          Radio<String>(
            value: 'cash',
            groupValue: _paymentMethod,
            onChanged: (value) {
              setState(() {
                _paymentMethod = value;
                _isButtonDisabled = false;
              });
            },
          ),
          const Text('Cash'),
          const SizedBox(width: 10,),
          const Icon(Icons.money),
        ],
      );
    } else if (paymentMode == 'Card') {
      return Row(
        children: [
          const Text('Payment method', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          Radio<String>(
            value: 'card',
            groupValue: _paymentMethod,
            onChanged: (value) {
              setState(() {
                _paymentMethod = value;
                _isButtonDisabled = false;
              });
            },
          ),
          const Text('Card'),
          const SizedBox(width: 10,),
          const Icon(Icons.credit_card),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment method', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Radio<String>(
                value: 'cash',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value;
                    _isButtonDisabled = false;
                  });
                },
              ),
              const Text('Cash'),
              const SizedBox(width: 10,),
              const Icon(Icons.money),
            ],
          ),
          Row(
            children: [
              Radio<String>(
                value: 'card',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value;
                    _isButtonDisabled = false;
                  });
                },
              ),
              const Text('Card'),
              const SizedBox(width: 10,),
              const Icon(Icons.credit_card),
            ],
          ),
        ],
      );
    }
  }


  // Future<bool> _bookRide({String? paymentId}) async {
  //   try {
  //     int selectedSeats = widget.selectedSeats;
  //     double amountToBePaid = widget.ride['pricePerSeat'] * selectedSeats;
  //
  //     // Get current user ID
  //     String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  //     print('Current User ID: $currentUserId');
  //
  //     // Create a passenger object
  //     Map<String, dynamic> passenger = {
  //       'userId': currentUserId, // Use current user ID
  //       'seats': selectedSeats,
  //       'pickupCoordinate': widget.userPickupCoordinate,
  //       'dropoffCoordinate': widget.userDropoffCoordinate,
  //       'amount': amountToBePaid, // Store the amount
  //       'paidStatus': _paymentMethod == 'cash' ? false : true, // Set paid status based on payment method
  //     };
  //
  //     // Add the payment ID if it exists (when payment method is card)
  //     if (paymentId != null) {
  //       passenger['paymentId'] = paymentId;
  //     }
  //
  //     // Update ride document with new passenger, reduced available seats, amount, and paid status
  //     await FirebaseFirestore.instance.collection('rides').doc(widget.ride.id).update({
  //       'passengers': FieldValue.arrayUnion([passenger]),
  //       'seats': FieldValue.increment(-selectedSeats), // Reduce available seats
  //     });
  //
  //     // Add booked ride to the user's ridesBooked array
  //     await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
  //       'ridesBooked': FieldValue.arrayUnion([widget.ride.id]),
  //     });
  //
  //     print('Booking successful');
  //     return true; // Booking successful
  //   } catch (e) {
  //     print('Error booking ride: $e');
  //     return false; // Booking failed
  //   }
  // }
  Future<bool> _bookRide({String? paymentId}) async {
    try {
      int selectedSeats = widget.selectedSeats;
      double amountToBePaid = widget.ride['pricePerSeat'] * selectedSeats;

      // Get current user ID and email
      var currentUser = FirebaseAuth.instance.currentUser;
      String? currentUserId = currentUser?.uid;
      String? currentUserEmail = currentUser?.email;  // Retrieve current user's email
      print('Current User ID: $currentUserId');
      print('Current User Email: $currentUserEmail');

      // Create a passenger object including the user's email
      Map<String, dynamic> passenger = {
        'userId': currentUserId, // Use current user ID
        'email': currentUserEmail, // Store the user's email
        'seats': selectedSeats,
        'pickupCoordinate': widget.userPickupCoordinate,
        'dropoffCoordinate': widget.userDropoffCoordinate,
        'amount': amountToBePaid, // Store the amount
        'paidStatus': _paymentMethod == 'cash' ? false : true, // Set paid status based on payment method
      };

      // Add the payment ID if it exists (when payment method is card)
      if (paymentId != null) {
        passenger['paymentId'] = paymentId;
      }

      // Update ride document with new passenger, reduced available seats, amount, and paid status
      await FirebaseFirestore.instance.collection('rides').doc(widget.ride.id).update({
        'passengers': FieldValue.arrayUnion([passenger]),
        'seats': FieldValue.increment(-selectedSeats), // Reduce available seats
      });

      // Add booked ride to the user's ridesBooked array
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'ridesBooked': FieldValue.arrayUnion([widget.ride.id]),
      });

      print('Booking successful');
      return true; // Booking successful
    } catch (e) {
      print('Error booking ride: $e');
      return false; // Booking failed
    }
  }



}






// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:lyft_mate/screens/find_ride/ride_booked_screen.dart';
// import 'package:lyft_mate/screens/payment/payment_screen.dart';
// import 'package:lyft_mate/services/payment/payment_service.dart';
//
// class ConfirmBookingPage extends StatefulWidget {
//   final DocumentSnapshot ride;
//   final int selectedSeats;
//   final GeoPoint userPickupCoordinate;
//   final GeoPoint userDropoffCoordinate;
//
//   ConfirmBookingPage({
//     required this.ride,
//     required this.selectedSeats, required this.userPickupCoordinate, required this.userDropoffCoordinate,
//   });
//
//   @override
//   _ConfirmBookingPageState createState() => _ConfirmBookingPageState();
// }
//
// class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
//   String? _paymentMethod; // Variable to store the selected payment method
//   bool _isButtonDisabled = true;
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     Timestamp rideDate = widget.ride['date'];
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
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Confirm Booking'),
//         backgroundColor: Colors.green,
//       ),
//       body: Column(  // Changed from SingleChildScrollView to Column
//         children: [
//           Expanded(  // This will take all available space
//             child: SingleChildScrollView(  // Now SingleChildScrollView is the child of Expanded
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                           'Ride Details',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18.0,
//                           ),
//                         ),
//                         SizedBox(height: 16.0),
//                         _buildRideDetailsCard(),
//                         SizedBox(height: 16.0),
//                         Text("Booking Details", style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18.0,
//                         ),),
//                         SizedBox(height: 16.0),
//                         _buildBookingDetailsCard(),
//
//                         SizedBox(height: 16.0),
//                         Text(
//                           'Payment Method',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18.0,
//                           ),
//                         ),
//                   const SizedBox(height: 16.0),
//                   _buildPaymentMethodSelection(),
//                   SizedBox(height: 32.0), // Give some spacing at the end of the scroll view
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 12.0, top: 0, right: 12.0, bottom: 12.0),
//             child: ElevatedButton(  // This is now directly in the Column, outside of the SingleChildScrollView
//               onPressed: _isButtonDisabled ? null : () async {
//             // Implement book ride functionality
//             if (_paymentMethod != null) {
//               double amountToBePaid = widget.ride['pricePerSeat'] * widget.selectedSeats;
//               if (_paymentMethod == 'cash') {
//                 bool result = await _bookRide();
//                 // bool result = true;
//                 if (result) {
//                   if(context.mounted){
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => RideBookedPage(),
//                         // builder: (context) => const PaymentScreen(),
//                       ),
//                     );
//                   }
//                 }
//                 print("HEEEEEHEEEEEEE CASHHH");
//               } else if (_paymentMethod == 'card') {
//                 // Call payment service
//                 // _callPaymentService();
//                 double amountToBePaid = widget.ride['pricePerSeat'] * widget.selectedSeats;
//                 bool paymentSuccessful = await PaymentService.makePayment(amountToBePaid, "hppppp@mail.com", "hpotter");
//
//                 debugPrint("----------------------------------------------");
//                 debugPrint("IS PAYEMENT SUCCESSSS FULLLL: $paymentSuccessful");
//                 debugPrint("----------------------------------------------");
//
//                 if (paymentSuccessful) {
//                   // Redirect user after payment
//                   debugPrint("----------------------------------------------");
//                   debugPrint("PAYEMENT ISSSSSSS SUCCESSSS FULLLL: $paymentSuccessful");
//                   debugPrint("----------------------------------------------");
//                   bool result = await _bookRide();
//                   if (result) {
//                    if(context.mounted){
//                      Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                          builder: (context) => const PaymentScreen(),
//                        ),
//                      );
//                    }
//                   }
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Payment failed. Please try again.'),
//                     ),
//                   );
//                 }
//               }
//             } else {
//               // Show error message or prevent booking without selecting payment method
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Please select a payment method.'),
//                 ),
//               );
//               print('Please select a payment method.');
//             }
//           },
//               style: ElevatedButton.styleFrom(
//                   foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
//                   minimumSize: Size(double.infinity, 50)  // Set the button to take the full width and 50 height
//               ),
//               child: Text(
//                 "Book Ride",
//                 style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//       );
//
//   }
//
//   Widget _buildRideDetailsCard() {
//     Timestamp rideDate = widget.ride['date'];
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
//     return Card(
//       elevation: 2.0,
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Ride ID: ${widget.ride.id}',
//               style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'From: ${widget.ride['pickupLocationName']}',
//               style: TextStyle(fontSize: 14.0),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'To: ${widget.ride['dropoffLocationName']}',
//               style: TextStyle(fontSize: 14.0),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'Date: $formattedDate',
//               style: TextStyle(fontSize: 14.0),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'Price per Seat: LKR ${widget.ride['pricePerSeat']}',
//               style: TextStyle(fontSize: 14.0),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBookingDetailsCard() {
//     Timestamp rideDate = widget.ride['date'];
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
//     return Card(
//       elevation: 2.0,
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Text(
//             //   'Ride ID: ${widget.ride.id}',
//             //   style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold),
//             // ),
//             // SizedBox(height: 8.0),
//             Text(
//               'From: ${widget.ride['pickupLocationName']}',
//               style: TextStyle(fontSize: 14.0),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'To: ${widget.ride['dropoffLocationName']}',
//               style: TextStyle(fontSize: 14.0),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'Date: $formattedDate',
//               style: TextStyle(fontSize: 14.0),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'Price per Seat: LKR ${widget.ride['pricePerSeat']}',
//               style: TextStyle(fontSize: 14.0),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//                 'Seats: ${widget.selectedSeats}',
//               style: TextStyle(fontSize: 14.0),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildPaymentMethodSelection() {
//     String paymentMode = widget.ride[
//         'paymentMode']; // Assuming 'paymentMode' is the field containing payment mode
//
//     if (paymentMode == 'Cash') {
//       return Row(
//         children: [
//           Radio<String>(
//             value: 'cash',
//             groupValue: _paymentMethod,
//             onChanged: (value) {
//               setState(() {
//                 _paymentMethod = value;
//                 _isButtonDisabled = false;
//               });
//             },
//           ),
//           Text('Cash'),
//           Icon(Icons.money),
//         ],
//       );
//     } else if (paymentMode == 'Card') {
//       return Row(
//         children: [
//           Radio<String>(
//             value: 'card',
//             groupValue: _paymentMethod,
//             onChanged: (value) {
//               setState(() {
//                 _paymentMethod = value;
//                 _isButtonDisabled = false;
//               });
//             },
//           ),
//           Text('Card'),
//           Icon(Icons.credit_card),
//         ],
//       );
//     } else {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Radio<String>(
//                 value: 'cash',
//                 groupValue: _paymentMethod,
//                 onChanged: (value) {
//                   setState(() {
//                     _paymentMethod = value;
//                     _isButtonDisabled = false;
//                   });
//                 },
//               ),
//               Text('Cash'),
//               Icon(Icons.money),
//             ],
//           ),
//           Row(
//             children: [
//               Radio<String>(
//                 value: 'card',
//                 groupValue: _paymentMethod,
//                 onChanged: (value) {
//                   setState(() {
//                     _paymentMethod = value;
//                     _isButtonDisabled = false;
//                   });
//                 },
//               ),
//               Text('Card'),
//               Icon(Icons.credit_card),
//             ],
//           ),
//         ],
//       );
//     }
//   }
//   // Future<bool> _bookRide() async {
//   //   try {
//   //     int selectedSeats = widget.selectedSeats;
//   //
//   //     // Get current user ID
//   //     String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
//   //     print('Current User ID: $currentUserId');
//   //
//   //     // Update ride document with new passenger and reduced available seats
//   //     await FirebaseFirestore.instance.collection('rides').doc(widget.ride.id).update({
//   //       'passengers': FieldValue.arrayUnion([
//   //         {
//   //           'userId': currentUserId, // Use current user ID
//   //           'pickupCoordinate': widget.userPickupCoordinate,
//   //           'dropoffCoordinate': widget.userDropoffCoordinate,
//   //         }
//   //       ]),
//   //       'seats': FieldValue.increment(-selectedSeats), // Reduce available seats
//   //     });
//   //
//   //     // Add booked ride to the user's ridesBooked array
//   //     // await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
//   //     //   'ridesBooked': FieldValue.arrayUnion([
//   //     //     {
//   //     //       'rideId': widget.ride.id,
//   //     //       'pickupCoordinate': widget.userPickupCoordinate,
//   //     //       'dropoffCoordinate': widget.userDropoffCoordinate,
//   //     //       'seatsBooked': selectedSeats,
//   //     //     }
//   //     //   ]),
//   //     // });
//   //     await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
//   //       'ridesBooked': FieldValue.arrayUnion([widget.ride.id]),
//   //     });
//   //
//   //     print('Booking successful');
//   //     return true; // Booking successful
//   //   } catch (e) {
//   //     print('Error booking ride: $e');
//   //     return false; // Booking failed
//   //   }
//   // }
//
//   Future<bool> _bookRide() async {
//     try {
//       int selectedSeats = widget.selectedSeats;
//       double amountToBePaid = widget.ride['pricePerSeat'] * selectedSeats;
//
//       // Get current user ID
//       String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
//       print('Current User ID: $currentUserId');
//
//       // Update ride document with new passenger, reduced available seats, amount, and paid status
//       await FirebaseFirestore.instance.collection('rides').doc(widget.ride.id).update({
//         'passengers': FieldValue.arrayUnion([
//           {
//             'userId': currentUserId, // Use current user ID
//             'seats': selectedSeats,
//             'pickupCoordinate': widget.userPickupCoordinate,
//             'dropoffCoordinate': widget.userDropoffCoordinate,
//             'amount': amountToBePaid, // Store the amount
//             'paidStatus': _paymentMethod == 'cash' ? false : true, // Set paid status based on payment method
//           }
//         ]),
//         'seats': FieldValue.increment(-selectedSeats), // Reduce available seats
//
//       });
//
//       // Add booked ride to the user's ridesBooked array
//       await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
//         'ridesBooked': FieldValue.arrayUnion([widget.ride.id]),
//       });
//
//       print('Booking successful');
//       return true; // Booking successful
//     } catch (e) {
//       print('Error booking ride: $e');
//       return false; // Booking failed
//     }
//   }
//
//
// }
