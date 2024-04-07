part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class HomeInitialEvent extends HomeEvent{

}

class HomeNotificationNavBtnNavigateEvent extends HomeEvent{

}

class HomeFindRideNavBtnNavigateEvent extends HomeEvent{

}

class HomeOfferRideBtnNavigateEvent extends HomeEvent{

}

class HomeDisplayFindRideScreenBtnEvent extends HomeEvent{

}

class HomeDisplayOfferRideScreenBtnEvent extends HomeEvent{

}
