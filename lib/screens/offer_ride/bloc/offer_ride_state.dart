part of 'offer_ride_bloc.dart';

@immutable
sealed class OfferRideState {}

sealed class OfferRideActionState extends OfferRideState {}

final class OfferRideInitial extends OfferRideState {}

class OfferRideNavToPickupMapPageActionState extends OfferRideActionState {}

class OfferRideNavToDropoffMapPageActionState extends OfferRideActionState {}

class OfferRidePickupLocationUpdatedState extends OfferRideState {
  final OfferRide ride; // Updated ride object

  OfferRidePickupLocationUpdatedState(this.ride); // Constructor to initialize with updated ride

  List<Object?> get props => [ride]; // For equatable
}

class OfferRideDropoffLocationUpdatedState extends OfferRideState {
  final OfferRide ride; // Updated ride object

  OfferRideDropoffLocationUpdatedState(this.ride); // Constructor to initialize with updated ride

  List<Object?> get props => [ride]; // For equatable
}

class OfferRideDateSelectedState extends OfferRideState {
  final OfferRide ride; // Updated ride object

  OfferRideDateSelectedState(this.ride); // Constructor to initialize with updated ride

  List<Object?> get props => [ride]; // For equatable
}

class OfferRideTimeSelectedState extends OfferRideState {
  final OfferRide ride; // Updated ride object

  OfferRideTimeSelectedState(this.ride); // Constructor to initialize with updated ride

  List<Object?> get props => [ride]; // For equatable
}

class OfferRideNavToConfirmRoutePageActionState extends OfferRideActionState {

}