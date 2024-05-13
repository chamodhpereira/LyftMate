import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lyft_mate/screens/offer_ride/bloc/offer_ride_bloc.dart';
import 'package:lyft_mate/screens/vehicles/vehicle_screen.dart';

import '../../../models/offer_ride.dart';
import '../../home/bloc/home_bloc.dart';
import '../../map/map_screen.dart';
import 'confirm_route_screen.dart';
import 'multi_route_screen.dart';

class OfferRideScreen extends StatefulWidget {
  final HomeBloc homeBloc;
  const OfferRideScreen({super.key, required this.homeBloc});

  @override
  State<OfferRideScreen> createState() => _OfferRideScreenState();
}

class _OfferRideScreenState extends State<OfferRideScreen> {
  final OfferRideBloc offerRideBloc = OfferRideBloc();

  OfferRide ride = OfferRide();

  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _dropoffLocationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String? selectedVehicle;
  String? selectedSeats;

  List<String> vehicleList = [];

  @override
  void initState() {
    super.initState();
    _loadUserVehicles();
  }

  void _loadUserVehicles() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch the vehicles from Firestore
      var vehiclesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('vehicles')
          .get();

      // Extract vehicle names and update the state
      setState(() {
        vehicleList = vehiclesSnapshot.docs
            .map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            final make = data['make'] as String? ?? 'Unknown make';
            final model = data['model'] as String? ?? 'Unknown model';
            final licensePlate = data['licensePlate'] as String? ?? 'Unknown license';
            return '$make $model - $licensePlate';
          }
          return null;  // Explicitly handling null here
        })
            .where((vehicleDescription) => vehicleDescription != null) // Remove null entries
            .cast<String>() // Safely cast to non-nullable String
            .toList();
      });
    }
  }

  void _showVehicleSelection() async {
    // Proceed with displaying the updated bottom sheet
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return vehicleList.isEmpty
            ? Center(
          child: TextButton.icon(
            icon: const Icon(Icons.add, color: Colors.green),
            label: const Text(
              'Add Vehicle',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
            onPressed: () async {
              final bool? vehicleAdded = await Navigator.push<bool?>(
                context,
                MaterialPageRoute(
                  builder: (context) => VehicleScreen(),
                ),
              );

              if (vehicleAdded == true) {
                _loadUserVehicles(); // Refresh the list after vehicle addition
              }

              Navigator.pop(context);
            },
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
              const Text(
                'Select Vehicle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10,),
              // const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: vehicleList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.directions_car, color: Colors.green),
                        title: Text(
                          vehicleList[index],
                          style: const TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedVehicle = vehicleList[index];
                            ride.setVehicle(selectedVehicle!);
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }





  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OfferRideBloc, OfferRideState>(
      bloc: offerRideBloc,
      listenWhen: (prev, curr) => curr is OfferRideActionState, //Take action if ActionState
      buildWhen: (prev, curr) => curr is! OfferRideActionState, //Build ui if not ActionState
      listener: (context, state) async {
        if (state is OfferRideNavToPickupMapPageActionState) {                    // get user pickup location
          final result = await Navigator.push(
            context, MaterialPageRoute(builder: (context) => MapScreen(locType: 'pickup')));

          if (result != null) {
            // context.read<OfferRideBloc>().add(LocationResultEvent(result));
            offerRideBloc.add(OfferRidePickupLocationResultEvent(locationResult: result));
            print("this is the resultsssss: $result");
          }
        } else if (state is OfferRideNavToDropoffMapPageActionState) { // get user drop-off location
          final result = await Navigator.push(
              context, MaterialPageRoute(
              builder: (context) => MapScreen(locType: 'dropoff')));

          if (result != null) {
            offerRideBloc.add(
                OfferRideDropoffLocationResultEvent(locationResult: result));
            print("this is the DROPPPPPP resultsssss: $result");
          }
        } else if (state is OfferRideNavToConfirmRoutePageActionState) {
          if (ride.pickupLocation != null && ride.dropoffLocation != null ) {
            Navigator.push(
              context, MaterialPageRoute(
                builder: (context) => NewMapsRoute(pickupLocation: ride.pickupLocation, dropoffLocation: ride.dropoffLocation)));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select pickup and dropoff locations.'),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is OfferRidePickupLocationUpdatedState) {                       // Update _pickupLocationController with the new location name
          _pickupLocationController.text = state.ride.pickupLocationName ?? '';
        } else if (state is OfferRideDropoffLocationUpdatedState) {               // Update _dropoffLocationController with the new location name
          _dropoffLocationController.text = state.ride.dropoffLocationName ?? '';
        } else if (state is OfferRideDateSelectedState) {
          final formattedDate = state.ride.date != null
              ? DateFormat('dd/MM/yyyy').format(state.ride.date!) : '';           // Handle the case when the DateTime object is null
          _dateController.text = formattedDate;
        } else if (state is OfferRideTimeSelectedState) {
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
                  offerRideBloc.add(OfferRidePickupNavigateMapEvent());
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
                  offerRideBloc.add(OfferRideDropoffNavigateMapEvent());
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
                        offerRideBloc.add(OfferRideSelectDateEvent(context));
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
                      onTap: () => offerRideBloc.add(OfferRideSelectTimeEvent(context)),
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Select Time',
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showVehicleSelection(),
                      // onTap: () => _selectVehicle(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
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
                          ride.setSeats(int.parse(value));
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
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
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  // onPressed: () {
                  //   // widget.homeBloc.add(HomeOfferRideBtnNavigateEvent());
                  //   offerRideBloc.add(OfferRideBtnNavigateEvent());
                  //
                  //   // _handlePublishRideButtonPress();
                  // },
                  onPressed: () {
                    // Check if all fields are filled
                    if (_pickupLocationController.text.isNotEmpty &&
                        _dropoffLocationController.text.isNotEmpty &&
                        _dateController.text.isNotEmpty &&
                        _timeController.text.isNotEmpty &&
                        selectedVehicle != null &&
                        selectedSeats != null && selectedSeats!.isNotEmpty) {
                      // All fields are filled, proceed with navigation
                      offerRideBloc.add(OfferRideBtnNavigateEvent());
                    } else {
                      // One or more fields are empty, show an error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
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
