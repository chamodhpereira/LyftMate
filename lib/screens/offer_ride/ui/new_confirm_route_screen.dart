// import 'package:flutter/material.dart';
//
// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart'; // TODO - use Dio package
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:lyft_mate/screens/offer_ride/bloc/confirm_route/confirm_route_bloc.dart';
// import 'package:lyft_mate/services/directions/directions_service.dart';
//
// import '../../../models/offer_ride.dart';
//
// import '../../ride/ride_options_screen.dart';
//
// class NewConfirmRoute extends StatefulWidget {
//   final LatLng? pickupLocation;
//   final LatLng? dropoffLocation;
//
//   const NewConfirmRoute(
//       {super.key, required this.pickupLocation, required this.dropoffLocation});
//
//   @override
//   State<NewConfirmRoute> createState() => _NewConfirmRouteState();
// }
//
// class _NewConfirmRouteState extends State<NewConfirmRoute> {
//   OfferRide ride = OfferRide();
//
//   final client = Client();
//
//   final ConfirmRouteBloc confirmRouteBloc = ConfirmRouteBloc(); //not recommended
//
//   Location _locationController = new Location();
//
//   final Completer<GoogleMapController> _mapController =
//   Completer<GoogleMapController>();
//
//   late LatLng _kPickupLocation;
//   late LatLng _kDropLocation;
//   LatLng? _currentP = null;
//
//   Map<PolylineId, Polyline> polylines = {};
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _kPickupLocation = widget.pickupLocation!;
//     _kDropLocation = widget.dropoffLocation!;
//
//     confirmRouteBloc.add(FetchRoutePolylinePointsEvent(
//         pickupLocation: _kPickupLocation, dropoffLocation: _kDropLocation));
//
//     // RideProvider rideProvider = Provider.of<RideProvider>(context, listen: false);
//
//
//     // getTotalDistanceAndDuration();
//
//     // TODO - try to use traffic api??
//
//     // _initializeRideDistance();
//
//     DirectionsService directionsService = DirectionsService();
//     DateTime departureTime = DateTime.now();
//
//     directionsService.getDirections(_kPickupLocation, _kDropLocation);
//
//
//     // getDirections();
//     // _fetchDirectionsAndPolylines();
//     print("INSIDEEEEE Singleton CONFIRMMMM ROUTEEEEEEE${ride.pickupLocation}");
//
//     // getPolylinePoints().then((coordinates) {
//     //   // rideProvider.updatePolylinePoints(coordinates);
//     //   ride.polylinePoints = coordinates;
//     //   generatePolylineFromPoints(coordinates);
//     // });
//   }
//
//   // void _initializeRideDistance() async {    put in bloc
//   //   print("INITIAAAAAAAAAAAAAAAALIZEEE METHOD CALLEDdd");
//   //   // Map<String, dynamic> result = await getTotalDistanceAndDuration();
//   //   double distance =
//   //   result['distance']; // Assuming 'distance' is the key in the map
//   //   ride.rideDistance = distance;
//   //
//   //   // Get duration without converting
//   //   Map<String, int> duration = result['duration'];
//   //   int? hours = duration['hours'];
//   //   int? minutes = duration['minutes'];
//   //
//   //   ride.rideDuration = "${hours.toString()} ${minutes.toString()}";
//   //
//   //   print("ride from distance in ride: ${ride.rideDistance}");
//   //   print("ride from DURATION in ride: $hours hours and $minutes minutes");
//   // }
//
//   @override
//   void dispose() {
//     // Remove polyline points when the user goes back without confirming
//     ride.resetPolylinePoints();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<ConfirmRouteBloc, ConfirmRouteState>(
//       bloc: confirmRouteBloc,
//       listenWhen: (prev, curr) => curr is ConfirmRouteActionState,
//       buildWhen: (prev, curr) => curr is! ConfirmRouteActionState,
//       listener: (context, state) {
//
//       },
//       builder: (context, state) {
//         if (state is RoutePolylineLoadedState) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             generatePolylineFromPoints(state.polylineCoordinates);
//           });
//         }
//
//         return Scaffold(
//           appBar: AppBar(
//             backgroundColor: Colors.green,
//             foregroundColor: Colors.white,
//             elevation: 0.5,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_ios), // Back button icon
//               onPressed: () {
//                 Navigator.pop(context); // Handle back navigation
//               },
//             ),
//             title: const Text("Confirm Route"),
//           ),
//           body: SafeArea(
//             child: Stack(
//               children: [
//                 GoogleMap(
//                   onMapCreated: ((GoogleMapController controller) =>
//                       _mapController.complete(controller)),
//                   initialCameraPosition: CameraPosition(
//                     target: _kPickupLocation,
//                     zoom: 10.8,
//                   ),
//                   markers: {
//                     Marker(
//                       markerId: const MarkerId("_pickupLocation"),
//                       icon: BitmapDescriptor.defaultMarker,
//                       position: _kPickupLocation,
//                     ),
//                     Marker(
//                       markerId: const MarkerId("_dropLocation"),
//                       icon: BitmapDescriptor.defaultMarker,
//                       position: _kDropLocation,
//                     ),
//                   },
//                   polylines: Set<Polyline>.of(polylines.values),
//                 ),
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   bottom: 0,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       height: 50.0,
//                       color: Colors.transparent,
//                       child: ElevatedButton(
//                         style: ButtonStyle(
//                           foregroundColor:
//                           MaterialStateProperty.all<Color>(Colors.white),
//                           backgroundColor:
//                           MaterialStateProperty.all<Color>(Colors.green),
//                         ),
//                         onPressed: () {
//                           // _confirmPickupLocation(pickedLatitude, pickedLongitude  , _textController.text);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => RideOptions(),
//                             ),
//                           );
//                         },
//                         child: const Text("Confirm Route",
//                             style: TextStyle(
//                                 fontSize: 14.0, fontWeight: FontWeight.bold)),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
//     PolylineId id = const PolylineId("poly");
//     Polyline polyline = Polyline(
//       polylineId: id,
//       color: Colors.black,
//       points: polylineCoordinates,
//       width: 8,
//     );
//     setState(() {
//       polylines[id] = polyline;
//     });
//   }
//
// // void generatePolylineFromPoints(List<LatLng> polylineCoordinates, String id) async {
// //   PolylineId polylineId = PolylineId(id); // Unique PolylineId for each polyline
// //   Polyline polyline = Polyline(
// //     polylineId: polylineId,
// //     color: Colors.black,
// //     points: polylineCoordinates,
// //     width: 8,
// //   );
// //   setState(() {
// //     polylines[polylineId] = polyline; // Use polylineId instead of const PolylineId("poly")
// //   });
// // }
//
//
// }
