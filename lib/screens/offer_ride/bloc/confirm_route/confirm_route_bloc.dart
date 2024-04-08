import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

import '../../../../services/directions/directions_service.dart';

part 'confirm_route_event.dart';
part 'confirm_route_state.dart';

class ConfirmRouteBloc extends Bloc<ConfirmRouteEvent, ConfirmRouteState> {

  DirectionsService directionsService = DirectionsService();

  ConfirmRouteBloc() : super(ConfirmRouteInitial()) {
    // on<ConfirmRouteEvent>((event, emit) {
    //   // TODO: implement event handler
    // });

    on<FetchRoutePolylinePointsEvent>(fetchRoutePolylinePointsEvent);
  }

  Future<FutureOr<void>> fetchRoutePolylinePointsEvent(FetchRoutePolylinePointsEvent event, Emitter<ConfirmRouteState> emit) async {

    print("fetching route polylines");

    List<LatLng> polylineCoordinates = await directionsService.getPolylinePoints(event.pickupLocation, event.dropoffLocation);

    print("POLYLINESSS : $polylineCoordinates");

    emit(RoutePolylineLoadedState(polylineCoordinates));

  }
}
