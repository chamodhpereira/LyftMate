part of 'confirm_route_bloc.dart';

@immutable
sealed class ConfirmRouteEvent {}

class FetchRoutePolylinePointsEvent extends ConfirmRouteEvent{
  final LatLng pickupLocation;
  final LatLng dropoffLocation;

  FetchRoutePolylinePointsEvent({required this.pickupLocation, required this.dropoffLocation});
}
