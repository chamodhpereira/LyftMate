part of 'find_ride_bloc.dart';

@immutable
sealed class FindRideState {}

sealed class FindRideActionState extends FindRideState {}

final class FindRideInitial extends FindRideState {}


class FindRideNavToPickupMapPageActionState extends FindRideActionState {}

class FindRideNavToDropoffMapPageActionState extends FindRideActionState {}

class FindRidePickupLocationUpdatedState extends FindRideState {
  final FindRide ride; // Updated ride object

  FindRidePickupLocationUpdatedState(this.ride); // Constructor to initialize with updated ride

  List<Object?> get props => [ride]; // For equatable
}

class FindRideDropoffLocationUpdatedState extends FindRideState {
  final FindRide ride; // Updated ride object

  FindRideDropoffLocationUpdatedState(this.ride); // Constructor to initialize with updated ride

  List<Object?> get props => [ride]; // For equatable
}

class FindRideDateSelectedState extends FindRideState {
  final FindRide ride; // Updated ride object

  FindRideDateSelectedState(this.ride); // Constructor to initialize with updated ride

  List<Object?> get props => [ride]; // For equatable
}

class FindRideTimeSelectedState extends FindRideState {
  final FindRide ride; // Updated ride object

  FindRideTimeSelectedState(this.ride); // Constructor to initialize with updated ride

  List<Object?> get props => [ride]; // For equatable
}

class FindRideNavToAvailableRidesPageActionState extends FindRideActionState {

}
