import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'find_ride_event.dart';
part 'find_ride_state.dart';

class FindRideBloc extends Bloc<FindRideEvent, FindRideState> {
  FindRideBloc() : super(FindRideInitial()) {
    on<FindRideEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
