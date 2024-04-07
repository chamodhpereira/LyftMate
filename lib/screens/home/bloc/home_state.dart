part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

sealed class HomeActionState extends HomeState {}

final class HomeInitial extends HomeState {}

class HomeNavToNotificationPageActionState extends HomeActionState {}

class HomeNavToFindRidePageActionState extends HomeActionState {}

class HomeNavToOfferRidePageActionState extends HomeActionState {}

class HomeDisplayOfferRideScreen extends HomeState {}

class HomeDisplayFindRideScreen extends HomeState {}


