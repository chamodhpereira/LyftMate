part of 'offer_ride_bloc.dart';

@immutable
sealed class OfferRideEvent {}

class OfferRidePickupNavigateMapEvent extends OfferRideEvent{

}

class OfferRideDropoffNavigateMapEvent extends OfferRideEvent{

}

class OfferRidePickupLocationResultEvent extends OfferRideEvent{
  final Map<String, dynamic> locationResult;

  OfferRidePickupLocationResultEvent({required this.locationResult});

}

class OfferRideDropoffLocationResultEvent extends OfferRideEvent{
  final Map<String, dynamic> locationResult;

  OfferRideDropoffLocationResultEvent({required this.locationResult});

}

class OfferRideSelectDateEvent extends OfferRideEvent {
  final BuildContext context;

  OfferRideSelectDateEvent(this.context);
}

class OfferRideSelectTimeEvent extends OfferRideEvent {
  final BuildContext context;

  OfferRideSelectTimeEvent(this.context);
}

class OfferRideBtnNavigateEvent extends OfferRideEvent {

}