import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lyft_mate/screens/offer_ride/bloc/offer_ride_bloc.dart';

import '../../../models/offer_ride.dart';
import '../../home/bloc/home_bloc.dart';
import '../../map/map_screen.dart';
import 'confirm_route_screen.dart';
import 'multi_route_screen.dart';
import 'new_confirm_route_screen.dart';

class OfferRideScreen extends StatefulWidget {
  final HomeBloc homeBloc; // TODO: inject this instead of this
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
                      onTap: () => _selectVehicle(context),
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
                          ride.setSeats(value);
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
                  onPressed: () {
                    // widget.homeBloc.add(HomeOfferRideBtnNavigateEvent());
                    offerRideBloc.add(OfferRideBtnNavigateEvent());

                    // _handlePublishRideButtonPress();
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
