import 'package:flutter/material.dart';

import '../../models/ride.dart';

class OfferRideScreen extends StatefulWidget {
  const OfferRideScreen({super.key});

  @override
  State<OfferRideScreen> createState() => _OfferRideScreenState();
}

class _OfferRideScreenState extends State<OfferRideScreen> {
  Ride ride = Ride();

  TextEditingController _pickupLocationController = TextEditingController();
  TextEditingController _dropoffLocationController = TextEditingController();
  double? pickupLat;
  double? pickupLng;
  double? dropoffLat;
  double? dropoffLng;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? selectedVehicle;
  String? selectedSeats;

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
        // Update the date in the Ride class
        ride.setDate(_selectedDate!);
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
        // Update the time in the Ride class
        ride.setTime(_selectedTime!);
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
        ride.setVehicle(selected);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            readOnly: true,
            controller: _pickupLocationController,
            onTap: () async {
              // final result = await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => MapScreen(
              //       locType: 'pickup',
              //     ),
              //   ),
              // );
              // if (result != null) {
              //   double lat = result['lat'];
              //   double lng = result['lng'];
              //   String locationName = result['locationName'];
              //   String cityName = result['cityName'];
              //
              //   ride.updatePickupCoordinates(lat, lng);
              //   ride.pickupCityName = cityName;
              //   ride.pickupLocationName = locationName;
              //   setState(() {
              //     _pickupLocationController.text = locationName;
              //     pickupLat = lat;
              //     pickupLng = lng;
              //   });
              // }
            },
            decoration: const InputDecoration(
              labelText: 'Pickup Location',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            readOnly: true,
            controller: _dropoffLocationController,
            onTap: () async {
              // final result = await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => MapScreen(
              //       locType: 'dropoff',
              //     ),
              //   ),
              // );
              // if (result != null) {
              //   double lat = result['lat'];
              //   double lng = result['lng'];
              //   String locationName = result['locationName'];
              //   String cityName = result['cityName'];
              //   ride.updateDropoffCoordinates(lat, lng);
              //   ride.dropoffCityName = cityName;
              //   ride.dropoffLocationName = locationName;
              //   setState(() {
              //     _dropoffLocationController.text = locationName;
              //     dropoffLat = lat;
              //     dropoffLng = lng;
              //   });
              // }
            },
            decoration: const InputDecoration(
              labelText: 'Drop off Location',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
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
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      controller: TextEditingController(
                        text: _selectedTime != null
                            ? '${_selectedTime!.hourOfPeriod}:${_selectedTime!.minute} ${_selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}'
                            : '',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
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
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      selectedSeats = value;
                      ride.setSeats(value);
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
          const SizedBox(height: 20),
          Container(
            // PROCEED Button - Offer Ride
            height: 50.0,
            color: Colors.transparent,
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                _handlePublishRideButtonPress();
              },
              child: const Text(
                'Proceed',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to handle button press
  void _handlePublishRideButtonPress() {
    if (pickupLat != null &&
        pickupLng != null &&
        dropoffLat != null &&
        dropoffLng != null) {
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
    } else {
      // Show an error or prompt the user to select locations
      // before publishing the ride.
    }
  }
}
