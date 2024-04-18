import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../models/find_ride.dart';

part 'find_ride_event.dart';
part 'find_ride_state.dart';

class FindRideBloc extends Bloc<FindRideEvent, FindRideState> {

  FindRide ride = FindRide();

  FindRideBloc() : super(FindRideInitial()) {
    // on<FindRideEvent>((event, emit) {
    //   // TODO: implement event handler
    // });

    on<FindRidePickupNavigateMapEvent>(findRidePickupMapNavBtnClicked);

    on<FindRideDropoffNavigateMapEvent>(findRideDropoffMapNavBtnClicked);

    on<FindRidePickupLocationResultEvent>(findRidePickupLocation);

    on<FindRideDropoffLocationResultEvent>(findRideDropLocation);

    on<FindRideSelectDateEvent>(findRideSelectDate);

    on<FindRideSelectTimeEvent>(findRideSelectTime);

    on<FindRideBtnNavigateEvent>(findRideNavBtnClicked);


  }

  FutureOr<void> findRidePickupMapNavBtnClicked(FindRidePickupNavigateMapEvent event, Emitter<FindRideState> emit) {
    print("redirect to map page for pickup location");
    emit(FindRideNavToPickupMapPageActionState());

  }

  FutureOr<void> findRideDropoffMapNavBtnClicked(FindRideDropoffNavigateMapEvent event, Emitter<FindRideState> emit) {
    print("redirect to map page for drop off location");
    emit(FindRideNavToDropoffMapPageActionState());

  }

  FutureOr<void> findRidePickupLocation(FindRidePickupLocationResultEvent event, Emitter<FindRideState> emit) {
    final Map<String, dynamic> locationResult = event.locationResult;

    double lat = locationResult['lat'];
    double lng = locationResult['lng'];
    String locationName = locationResult['locationName'];
    String cityName = locationResult['cityName'];

    print("INSIDEEEE EMITTEEEERRRR EVENT: $lat, $lng, $locationName, $cityName");

    ride.setPickupLocation(lat, lng, locationName, cityName);

    // Emit a new state with the updated Ride object
    emit(FindRidePickupLocationUpdatedState(ride));


  }

  FutureOr<void> findRideDropLocation(FindRideDropoffLocationResultEvent event, Emitter<FindRideState> emit) {
    final Map<String, dynamic> locationResult = event.locationResult;

    double lat = locationResult['lat'];
    double lng = locationResult['lng'];
    String locationName = locationResult['locationName'];
    String cityName = locationResult['cityName'];

    print("INSIDEEEE DROOOOOOOOOOOPPPPPPPPPPP EMITTEEEERRRR EVENT: $lat, $lng, $locationName, $cityName");

    ride.setDropoffLocation(lat, lng, locationName, cityName);

    // Emit a new state with the updated Ride object
    emit(FindRideDropoffLocationUpdatedState(ride));

  }

  Future<FutureOr<void>> findRideSelectDate(FindRideSelectDateEvent event, Emitter<FindRideState> emit) async {
    final DateTime? pickedDate = await showDatePicker(
      context: event.context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null) {
      final selectedDate = pickedDate;
      ride.setDate(selectedDate);
      emit(FindRideDateSelectedState(ride)); // Emit a state with the updated ride
    }
  }

  Future<FutureOr<void>> findRideSelectTime(FindRideSelectTimeEvent event, Emitter<FindRideState> emit) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: event.context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final selectedTime = pickedTime;
      // Update the time in the Ride class
      ride.setTime(selectedTime);
      emit(FindRideTimeSelectedState(ride));
    }
  }

  FutureOr<void> findRideNavBtnClicked(FindRideBtnNavigateEvent event, Emitter<FindRideState> emit) {
    print("FIND RIDE proceed button clicked");
    emit(FindRideNavToAvailableRidesPageActionState());
  }
}
