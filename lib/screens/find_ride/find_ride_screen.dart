import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lyft_mate/screens/find_ride/available_rides.dart';

import '../../models/find_ride.dart';
import '../../models/offer_ride.dart';
import '../home/bloc/home_bloc.dart';
import '../map/map_screen.dart';
import '../offer_ride/ui/multi_route_screen.dart';
import 'bloc/find_ride_bloc.dart';

class FindRideScreen extends StatefulWidget {
  final HomeBloc homeBloc;

  const FindRideScreen({super.key, required this.homeBloc});

  @override
  State<FindRideScreen> createState() => _FindRideScreenState();
}

class _FindRideScreenState extends State<FindRideScreen> {

  final FindRideBloc findRideBloc = FindRideBloc();

  FindRide ride = FindRide();

  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _dropoffLocationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  // double? pickupLat;
  // double? pickupLng;
  // double? dropoffLat;
  // double? dropoffLng;
  // DateTime? _selectedDate;
  // TimeOfDay? _selectedTime;
  // String? selectedVehicle;
  // String? selectedSeats;

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(2101),
  //   );
  //   if (pickedDate != null && pickedDate != _selectedDate) {
  //     setState(() {
  //       _selectedDate = pickedDate;
  //       // Update the date in the Ride class
  //       ride.setDate(_selectedDate!);
  //     });
  //   }
  // }
  //
  // Future<void> _selectTime(BuildContext context) async {
  //   final TimeOfDay? pickedTime = await showTimePicker(
  //     context: context,
  //     initialTime: _selectedTime ?? TimeOfDay.now(),
  //   );
  //   if (pickedTime != null && pickedTime != _selectedTime) {
  //     setState(() {
  //       _selectedTime = pickedTime;
  //       // Update the time in the Ride class
  //       ride.setTime(_selectedTime!);
  //     });
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FindRideBloc, FindRideState>(
      bloc: findRideBloc,
      listenWhen: (prev, curr) => curr is FindRideActionState, //Take action if ActionState
      buildWhen: (prev, curr) => curr is! FindRideActionState, //Build ui if not ActionState
      listener: (context, state) async {
        // TODO: implement listener
        if (state is FindRideNavToPickupMapPageActionState) {                    // get user pickup location
          final result = await Navigator.push(
              context, MaterialPageRoute(builder: (context) => MapScreen(locType: 'pickup')));

          if (result != null) {
            // context.read<OfferRideBloc>().add(LocationResultEvent(result));
            findRideBloc.add(FindRidePickupLocationResultEvent(locationResult: result));
            print("this is the resultsssss: $result");
          }
        } else if (state is FindRideNavToDropoffMapPageActionState) { // get user drop-off location
          final result = await Navigator.push(
              context, MaterialPageRoute(
              builder: (context) => MapScreen(locType: 'dropoff')));

          if (result != null) {
            findRideBloc.add(
                FindRideDropoffLocationResultEvent(locationResult: result));
            print("this is the DROPPPPPP resultsssss: $result");
          }
        } else if (state is FindRideNavToAvailableRidesPageActionState) {
          if (ride.pickupLocation != null && ride.dropoffLocation != null ) {
            LatLng pickupLatLng = ride.pickupLocation!;
            LatLng dropoffLatLng = ride.dropoffLocation!;
            print("RIDDDDDEEEEEEEEEEEEEEEEEEEEE DATEEEEEEEEEEEEEEEEEEEEEE IN STATE ACTION ${ride.date}");

            GeoPoint pickupGeoPoint = GeoPoint(pickupLatLng.latitude, pickupLatLng.longitude);
            GeoPoint dropoffGeoPoint = GeoPoint(dropoffLatLng.latitude, dropoffLatLng.longitude);
            Navigator.push(
                context, MaterialPageRoute(
                builder: (context) => RideMatchingScreen(userPickupLocation: pickupGeoPoint, userDropoffLocation: dropoffGeoPoint, userPickedDate: ride.date,)));
          } else {
            print("THIS IS THE STATEEEEEEE: $state");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select pickupppp and dropoff locations.'),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is FindRidePickupLocationUpdatedState) {                       // Update _pickupLocationController with the new location name
          _pickupLocationController.text = state.ride.pickupLocationName ?? '';
        } else if (state is FindRideDropoffLocationUpdatedState) {               // Update _dropoffLocationController with the new location name
          _dropoffLocationController.text = state.ride.dropoffLocationName ?? '';
        } else if (state is FindRideDateSelectedState) {
          final formattedDate = state.ride.date != null
              ? DateFormat('dd/MM/yyyy').format(state.ride.date!) : '';           // Handle the case when the DateTime object is null
          _dateController.text = formattedDate;
        } else if (state is FindRideTimeSelectedState) {
          final formattedTime = state.ride.time != null ? state.ride.time?.format(context) : ''; // Handle the case when the TimeOfDay object is null
          _timeController.text = formattedTime!;
        }


        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                readOnly: true,
                controller: _pickupLocationController,
                onTap: () {
                  findRideBloc.add(FindRidePickupNavigateMapEvent());
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
                  findRideBloc.add(FindRideDropoffNavigateMapEvent());
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
                      onTap: () {
                        findRideBloc.add(FindRideSelectDateEvent(context));
                      },
                      // onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Select Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: _dateController,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => findRideBloc.add(FindRideSelectTimeEvent(context)),
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Selected Time',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          controller: _timeController,
                        ),
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
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  // onPressed: () {
                  //   // widget.homeBloc.add(HomeOfferRideBtnNavigateEvent());
                  //   findRideBloc.add(FindRideBtnNavigateEvent());
                  //
                  //   // _handlePublishRideButtonPress();
                  // },
                  onPressed: () {
                    // Check if the text fields for pickup location, dropoff location, date, and time are not empty
                    if (_pickupLocationController.text.isNotEmpty &&
                        _dropoffLocationController.text.isNotEmpty &&
                        _dateController.text.isNotEmpty &&
                        _timeController.text.isNotEmpty) {
                      // All fields are filled, proceed with navigation
                      findRideBloc.add(FindRideBtnNavigateEvent());
                    } else {
                      // One or more fields are empty, show an error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill in all fields before proceeding.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Proceed',
                    style:
                    TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


}


// Padding(
// padding: const EdgeInsets.all(15.0),
// child: Column(
// mainAxisAlignment: MainAxisAlignment.center,
// crossAxisAlignment: CrossAxisAlignment.stretch,
// children: [
// TextField(
// readOnly: true,
// controller: _pickupLocationController,
// onTap: () async {
// // final result = await Navigator.push(
// //   context,
// //   MaterialPageRoute(
// //     builder: (context) => MapScreen(
// //       locType: 'pickup',
// //     ),
// //   ),
// // );
// // if (result != null) {
// //   double lat = result['lat'];
// //   double lng = result['lng'];
// //   String locationName = result['locationName'];
// //   String cityName = result['cityName'];
// //
// //   ride.updatePickupCoordinates(lat, lng);
// //   ride.pickupCityName = cityName;
// //   ride.pickupLocationName = locationName;
// //   setState(() {
// //     _pickupLocationController.text = locationName;
// //     pickupLat = lat;
// //     pickupLng = lng;
// //   });
// // }
// },
// decoration: const InputDecoration(
// labelText: 'Pickup Location',
// border: OutlineInputBorder(),
// ),
// ),
// const SizedBox(height: 10),
// TextField(
// readOnly: true,
// controller: _dropoffLocationController,
// onTap: () async {
// // final result = await Navigator.push(
// //   context,
// //   MaterialPageRoute(
// //     builder: (context) => MapScreen(
// //       locType: 'dropoff',
// //     ),
// //   ),
// // );
// // if (result != null) {
// //   double lat = result['lat'];
// //   double lng = result['lng'];
// //   String locationName = result['locationName'];
// //   String cityName = result['cityName'];
// //   ride.updateDropoffCoordinates(lat, lng);
// //   ride.dropoffCityName = cityName;
// //   ride.dropoffLocationName = locationName;
// //   setState(() {
// //     _dropoffLocationController.text = locationName;
// //     dropoffLat = lat;
// //     dropoffLng = lng;
// //   });
// // }
// },
// decoration: const InputDecoration(
// labelText: 'Drop off Location',
// border: OutlineInputBorder(),
// ),
// ),
// const SizedBox(height: 10),
// Row(
// mainAxisAlignment: MainAxisAlignment.center,
// children: [
// Expanded(
// child: GestureDetector(
// onTap: () => _selectDate(context),
// child: AbsorbPointer(
// child: TextFormField(
// readOnly: true,
// decoration: const InputDecoration(
// labelText: 'Select Date',
// border: OutlineInputBorder(),
// suffixIcon: Icon(Icons.calendar_today),
// ),
// controller: TextEditingController(
// text: _selectedDate != null
// ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
//     : '',
// ),
// ),
// ),
// ),
// ),
// const SizedBox(width: 10),
// Expanded(
// child: GestureDetector(
// onTap: () => _selectTime(context),
// child: AbsorbPointer(
// child: TextFormField(
// readOnly: true,
// decoration: const InputDecoration(
// labelText: 'Select Time',
// border: OutlineInputBorder(),
// suffixIcon: Icon(Icons.access_time),
// ),
// controller: TextEditingController(
// text: _selectedTime != null
// ? '${_selectedTime!.hourOfPeriod}:${_selectedTime!.minute} ${_selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}'
//     : '',
// ),
// ),
// ),
// ),
// ),
// ],
// ),
// // const SizedBox(
// //   height: 10,
// // ),
//
// const SizedBox(height: 20),
// Container(
// // PROCEED Button - Offer Ride
// height: 50.0,
// color: Colors.transparent,
// child: ElevatedButton(
// style: ButtonStyle(
// foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
// backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
// ),
// onPressed: () {
// widget.homeBloc.add(HomeFindRideNavBtnNavigateEvent());
// // _handlePublishRideButtonPress();
// },
// child: const Text(
// 'Find Ride',
// style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
// ),
// ),
// ),
// ],
// ),
// );
