import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    // on<HomeEvent>((event, emit) {
    //   // TODO: implement event handler
    // });

    on<HomeInitialEvent>(homeInitialEvent);

    on<HomeDisplayFindRideScreenBtnEvent>(displayFindRideScreen);

    on<HomeDisplayOfferRideScreenBtnEvent>(displayOfferRideScreen);

    on<HomeFindRideNavBtnNavigateEvent>(homeFindRideNavBtnClicked);

    on<HomeOfferRideBtnNavigateEvent>(homeOfferRideNavBtnClicked);

    on<HomeNotificationNavBtnNavigateEvent>(homeNotificationNavBtnClicked);

  }

  FutureOr<void> homeInitialEvent(HomeInitialEvent event, Emitter<HomeState> emit) {
    emit(HomeDisplayFindRideScreen());
  }

  FutureOr<void> displayFindRideScreen(HomeDisplayFindRideScreenBtnEvent event, Emitter<HomeState> emit) {
    print("find ride screen button clicked");
    emit(HomeDisplayFindRideScreen());
  }

  FutureOr<void> displayOfferRideScreen(HomeDisplayOfferRideScreenBtnEvent event, Emitter<HomeState> emit) {
    print("offer ride screen button clicked");
    emit(HomeDisplayOfferRideScreen());
  }

  FutureOr<void> homeFindRideNavBtnClicked(HomeFindRideNavBtnNavigateEvent event, Emitter<HomeState> emit) {
    print("find ride button clicked");
    emit(HomeNavToFindRidePageActionState());
  }

  FutureOr<void> homeOfferRideNavBtnClicked(HomeOfferRideBtnNavigateEvent event, Emitter<HomeState> emit) {
    print("proceed button clicked");
    emit(HomeNavToOfferRidePageActionState());
  }

  FutureOr<void> homeNotificationNavBtnClicked(HomeNotificationNavBtnNavigateEvent event, Emitter<HomeState> emit) {
    print("notification button clicked");
    emit(HomeNavToNotificationPageActionState());
  }
}
