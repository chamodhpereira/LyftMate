part of 'find_ride_bloc.dart';

@immutable
sealed class FindRideEvent {}


class FindRidePickupNavigateMapEvent extends FindRideEvent{

}

class FindRideDropoffNavigateMapEvent extends FindRideEvent{

}

class FindRidePickupLocationResultEvent extends FindRideEvent{
  final Map<String, dynamic> locationResult;

  FindRidePickupLocationResultEvent({required this.locationResult});

}

class FindRideDropoffLocationResultEvent extends FindRideEvent{
  final Map<String, dynamic> locationResult;

  FindRideDropoffLocationResultEvent({required this.locationResult});

}

class FindRideSelectDateEvent extends FindRideEvent {
  final BuildContext context;

  FindRideSelectDateEvent(this.context);
}

class FindRideSelectTimeEvent extends FindRideEvent {
  final BuildContext context;

  FindRideSelectTimeEvent(this.context);
}

class FindRideBtnNavigateEvent extends FindRideEvent {

}