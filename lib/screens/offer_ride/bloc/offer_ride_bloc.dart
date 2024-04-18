import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../models/offer_ride.dart';

part 'offer_ride_event.dart';
part 'offer_ride_state.dart';

class OfferRideBloc extends Bloc<OfferRideEvent, OfferRideState> {

  OfferRide ride = OfferRide();   // TODO : change the class name to OfferRide class

  OfferRideBloc() : super(OfferRideInitial()) {
    // on<OfferRideEvent>((event, emit) {
    //   // TODO: implement event handler
    // });

    on<OfferRidePickupNavigateMapEvent>(offerRidePickupMapNavBtnClicked);

    on<OfferRideDropoffNavigateMapEvent>(offerRideDropoffMapNavBtnClicked);

    on<OfferRidePickupLocationResultEvent>(offerRidePickupLocation);

    on<OfferRideDropoffLocationResultEvent>(offerRideDropLocation);

    on<OfferRideSelectDateEvent>(offerRideSelectDate);

    on<OfferRideSelectTimeEvent>(offerRideSelectTime);

    on<OfferRideBtnNavigateEvent>(offerRideNavBtnClicked);
  }

  FutureOr<void> offerRidePickupMapNavBtnClicked(OfferRidePickupNavigateMapEvent event, Emitter<OfferRideState> emit) {
    print("redirect to map page for pickup location");
    emit(OfferRideNavToPickupMapPageActionState());
  }

  FutureOr<void> offerRideDropoffMapNavBtnClicked(OfferRideDropoffNavigateMapEvent event, Emitter<OfferRideState> emit) {
    print("redirect to map page for drop off location");
    emit(OfferRideNavToDropoffMapPageActionState());
  }

  FutureOr<void> offerRidePickupLocation(OfferRidePickupLocationResultEvent event, Emitter<OfferRideState> emit) {
    final Map<String, dynamic> locationResult = event.locationResult;

    double lat = locationResult['lat'];
    double lng = locationResult['lng'];
    String locationName = locationResult['locationName'];
    String cityName = locationResult['cityName'];

    print("INSIDEEEE EMITTEEEERRRR EVENT: $lat, $lng, $locationName, $cityName");

    ride.setPickupLocation(lat, lng, locationName, cityName);

    // Emit a new state with the updated Ride object
    emit(OfferRidePickupLocationUpdatedState(ride));

  }

  FutureOr<void> offerRideDropLocation(OfferRideDropoffLocationResultEvent event, Emitter<OfferRideState> emit) {
    final Map<String, dynamic> locationResult = event.locationResult;

    double lat = locationResult['lat'];
    double lng = locationResult['lng'];
    String locationName = locationResult['locationName'];
    String cityName = locationResult['cityName'];

    print("INSIDEEEE DROOOOOOOOOOOPPPPPPPPPPP EMITTEEEERRRR EVENT: $lat, $lng, $locationName, $cityName");

    ride.setDropoffLocation(lat, lng, locationName, cityName);

    // Emit a new state with the updated Ride object
    emit(OfferRideDropoffLocationUpdatedState(ride));

  }

  Future<FutureOr<void>> offerRideSelectDate(OfferRideSelectDateEvent event, Emitter<OfferRideState> emit) async {
    final DateTime? pickedDate = await showDatePicker(
      context: event.context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null) {
      final selectedDate = pickedDate;
      ride.setDate(selectedDate);
      emit(OfferRideDateSelectedState(ride)); // Emit a state with the updated ride
    }
  }

  Future<FutureOr<void>> offerRideSelectTime(OfferRideSelectTimeEvent event, Emitter<OfferRideState> emit) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: event.context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
        final selectedTime = pickedTime;
        // Update the time in the Ride class
        ride.setTime(selectedTime);
        emit(OfferRideTimeSelectedState(ride));
    }
  }

  FutureOr<void> offerRideNavBtnClicked(OfferRideBtnNavigateEvent event, Emitter<OfferRideState> emit) {
    print("proceed herhe button clicked");
    emit(OfferRideNavToConfirmRoutePageActionState());
  }
}
