import 'package:flutter/material.dart';
// import 'package:lyft_mate/src/components/bottom_navbar.dart';
// import 'package:lyft_mate/src/screens/available_rides.dart';
// import 'package:lyft_mate/src/screens/chat_page_screen.dart';

// import 'notifications_screen.dart';
//
// import 'notifications_screen.dart';

import 'dart:math';

// import 'maps_screen.dart';
//
// import 'confirm_route.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _pickupLocationController = TextEditingController();
  TextEditingController _dropoffLocationController = TextEditingController();
  int _currentIndex = 0;
  bool isFindingRide = true; // Initially showing Find a Ride content
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? selectedVehicle;
  int? selectedSeats;
  double? pickupLat;
  double? pickupLng;
  double? dropoffLat;
  double? dropoffLng;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _selectVehicle(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Column(
            children: [
              ListTile(
                title: Text('Car'),
                onTap: () {
                  Navigator.pop(context, 'Car');
                },
              ),
              ListTile(
                title: Text('Motorcycle'),
                onTap: () {
                  Navigator.pop(context, 'Motorcycle');
                },
              ),
              ListTile(
                title: Text('Bicycle'),
                onTap: () {
                  Navigator.pop(context, 'Bicycle');
                },
              ),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      setState(() {
        selectedVehicle = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LyftMate'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => NotificationsPage(),
              //   ),
              // );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        isFindingRide = true;
                      });
                    },
                    style: isFindingRide
                        ? ButtonStyle(
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                    )
                        : ButtonStyle(
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                    ),
                    child: Text('Find a Ride', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        isFindingRide = false;
                      });
                    },
                    style: !isFindingRide
                        ? ButtonStyle(
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                    )
                        : ButtonStyle(
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                    ),
                    child: Text(
                        'Offer a Ride', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              readOnly: true,
              controller: _pickupLocationController,
              // onTap: () async {
              //   final result = await Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => MapSample(locType: 'pickup',)), // Navigate to MapPage
              //   );
              //   if (result != null) {
              //     double lat = result['lat'];
              //     double lng = result['lng'];
              //     String locationName = result['locationName'];
              //     setState(() {
              //       _pickupLocationController.text = locationName;
              //       pickupLat = lat;
              //       pickupLng = lng;
              //     });
              //   }
              // },
              decoration: InputDecoration(
                labelText: 'Pickup Location',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              readOnly: true,
              controller: _dropoffLocationController,
              // onTap: () async {
              //   final result = await Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => MapSample(locType: 'dropoff',)), // Navigate to MapPage
              //   );
              //   if (result != null) {
              //     double lat = result['lat'];
              //     double lng = result['lng'];
              //     String locationName = result['locationName'];
              //     setState(() {
              //       _dropoffLocationController.text = locationName;
              //       dropoffLat = lat;
              //       dropoffLng = lng;
              //     });
              //   }
              // },
              decoration: InputDecoration(
                labelText: 'Drop Location',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Select Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : '',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Select Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        controller: TextEditingController(
                          // text: _selectedTime != null
                          //     ? '${_selectedTime!.hourOfPeriod}:${_selectedTime!.minute} ${_selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}'
                          //     : '',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Visibility(
              visible: !isFindingRide,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectVehicle(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Select Vehicle',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.directions_car),
                          ),
                          controller: TextEditingController(
                            text: selectedVehicle ?? '',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          selectedSeats = int.tryParse(value);
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Select Seats',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 50.0,
              color: Colors.transparent,
              child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                ),
                onPressed: () {
                  if (isFindingRide) {
                    // Navigate to AvailableRides screen
                    print("navigate to avaialable rides pages");
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => AvailableRides(),
                    //   ),
                    // );
                  } else {
                    // Handle Publish Ride Button Press
                    _handlePublishRideButtonPress();
                  }
                },
                child: Text(
                  isFindingRide ? 'Search Ride' : 'Proceed',
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // ElevatedButton(
            //   onPressed: _handlePublishRideButtonPress,
            //   child: Text(isFindingRide ? 'Search Ride' : 'Publish Ride'),
            // ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.black,
      //   currentIndex: _currentIndex,
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //
      //     // Handle navigation to different tabs
      //     switch (index) {
      //       case 0:
      //       // Navigate to Home
      //         break;
      //       case 1:
      //       // Navigator.push(
      //       //   context,
      //       //   MaterialPageRoute(
      //       //     builder: (context) => RidesScreen(),
      //       //   ),
      //       // );
      //         break;
      //       case 2:
      //       // Navigate to Messages
      //         break;
      //       case 3:
      //       // Navigate to Profile
      //         break;
      //     }
      //   },
      //   items: [
      //     BottomNavigationBarItem(
      //       backgroundColor: Colors.yellow,
      //       icon: Icon(Icons.home, color: Colors.black),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.directions_car),
      //       label: 'Rides',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.message),
      //       label: 'Messages',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      // ),
    );
  }

  // Function to handle button press
  void _handlePublishRideButtonPress() {
    if (isFindingRide) {
      // Implement logic for finding a ride
    } else {
      print("publish ride was pressed");
      // Implement logic for offering a ride
      // if (pickupLat != null &&
      //     pickupLng != null &&
      //     dropoffLat != null &&
      //     dropoffLng != null) {
        // Navigate to the next screen with pickup and dropoff coordinates
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ConfirmRoute(
        //       pickupLat: pickupLat!,
        //       pickupLng: pickupLng!,
        //       dropoffLat: dropoffLat!,
        //       dropoffLng: dropoffLng!,
        //     ),
        //   ),
        // );
      // } else {
      //   // Show an error or prompt the user to select locations
      //   // before publishing the ride.
      // }
    }
  }
}