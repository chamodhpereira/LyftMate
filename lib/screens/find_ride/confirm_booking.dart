import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmBookingPage extends StatefulWidget {
  final DocumentSnapshot ride;
  final int selectedSeats;

  ConfirmBookingPage({
    required this.ride,
    required this.selectedSeats,
  });

  @override
  _ConfirmBookingPageState createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  String? _paymentMethod; // Variable to store the selected payment method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Booking'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ride Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildRideDetailsCard(),
            const SizedBox(height: 16.0),
            const Text(
              'Selected Seats',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildSelectedSeatsCard(),
            const SizedBox(height: 16.0),
            const Text(
              'Payment Method',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 16.0),
            _buildPaymentMethodSelection(),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Implement book ride functionality
                if (_paymentMethod != null) {
                  // Proceed with booking using selected payment method
                  print('Selected Payment Method: $_paymentMethod');
                  _bookRide();
                } else {
                  // Show error message or prevent booking without selecting payment method
                  print('Please select a payment method.');
                }
              },
              child: Text('Book Ride'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideDetailsCard() {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From: ${widget.ride.id}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'From: ${widget.ride['pickupCityName']}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'To: ${widget.ride['dropoffCityName']}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Date: Saturday, 15 May 2024',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Price per Seat: LKR 300',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedSeatsCard() {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Seats: ${widget.selectedSeats}',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio<String>(
              value: 'cash',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value;
                });
              },
            ),
            Text('Cash'),
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
                });
              },
            ),
            Text('Card'),
          ],
        ),
      ],
    );
  }

  void _bookRide() async {
    try {
      // Update ride document with new passenger
      await FirebaseFirestore.instance.collection('rides').doc(widget.ride.id).update({
        'passengers': FieldValue.arrayUnion(['namaaal-baba-gay']), // Replace 'passengerID' with actual passenger ID
      });
      print('Booking successful');
    } catch (e) {
      print('Error booking ride: $e');
    }
  }
}



























// import 'package:flutter/material.dart';
//
// class ConfirmBookingPage extends StatelessWidget {
//   final DocumentSnapshot ride;
//   final int selectedSeats;
//
//   ConfirmBookingPage({
//     required this.ride,
//     required this.selectedSeats,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Build UI for confirm booking page
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Confirm Booking'),
//         backgroundColor: Colors.green,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Display ride details
//               Text('Ride ID: ${ride.id}'),
//               Text('Seats: $selectedSeats'),
//               // Add more ride details as needed
//               // Payment method selection
//               // Book Ride button
//               ElevatedButton(
//                 onPressed: () {
//                   // Implement book ride functionality
//                 },
//                 child: Text('Book Ride'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }