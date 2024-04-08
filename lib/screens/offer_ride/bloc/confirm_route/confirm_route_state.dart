part of 'confirm_route_bloc.dart';

@immutable
sealed class ConfirmRouteState {}

sealed class ConfirmRouteActionState extends ConfirmRouteState {}


final class ConfirmRouteInitial extends ConfirmRouteState {}


class RoutePolylineLoadedState extends ConfirmRouteState {
  final List<LatLng> polylineCoordinates;

  RoutePolylineLoadedState(this.polylineCoordinates);
}
