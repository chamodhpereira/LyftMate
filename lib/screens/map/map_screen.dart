import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lyft_mate/screens/map/places_search_screen.dart';
// import 'address_search.dart';
// import 'place_service.dart';
import 'package:uuid/uuid.dart';

import '../../services/map/place_service.dart';

class MapScreen extends StatefulWidget {
  final String? locType;


  MapScreen({super.key, this.locType,});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  late double pickedLongitude;
  late double pickedLatitude;
  late String pickedLocation;
  late String pickedCity;

  final client = Client();


  final Completer<GoogleMapController> _controller = Completer();
  final _textController = TextEditingController();

  static const CameraPosition _kGooglePlex = CameraPosition(target: LatLng(37.4223, -122.0848), zoom: 14);

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  List<LatLng> polygonLatLngs = <LatLng>[];

  int _polygonIdCounter = 1;

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: const MarkerId("_currentLocation"), position: point));
    });
  }

  late String locationType;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locationType = widget.locType!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {
          Navigator.pop(context);
        },),
        title: Text("Enter $locationType location"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  _controller.complete(controller)),
              initialCameraPosition: _kGooglePlex,
              markers: _markers,
              // onTap: _handleTap,
            ),
            Positioned(
              top: 8.0,
              left: 8.0,
              right: 8.0,
              child: Container(
                color: Colors.white.withOpacity(0.9),
                child: TextField(
                  readOnly: true,
                  controller: _textController,
                  onTap: () async {
                    final sessionToken = const Uuid().v4();
                    final Suggestion? result = await showSearch(
                      context: context,
                      delegate: AddressSearch(sessionToken),
                    );
                    if (result != null) {
                      // pickedLocation = result.description;
                      var place = await PlaceApiProvider(sessionToken)
                          .getPlaceDetailFromId(result.placeId);
                      _goToPlace(place);
                      setState(() {
                        _textController.text = result.description;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter a location',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50.0,
                  color: Colors.transparent,
                  child: ElevatedButton(
                    onPressed: () {
                      _confirmPickupLocation(pickedLatitude, pickedLongitude  , _textController.text, pickedCity);
                    },
                    style: ButtonStyle(
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                    ),
                    child: Text("Confirm Pickup Location", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _handleTap(LatLng tappedPoint) async {
  //   setState(() {
  //     _markers.clear();
  //     _markers.add(Marker(
  //       markerId: MarkerId(tappedPoint.toString()),
  //       position: tappedPoint,
  //     ));
  //     pickedLatitude = tappedPoint.latitude;
  //     pickedLongitude = tappedPoint.longitude;
  //   });
  // }
  String _getApiKey() {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_DEFAULT_API_KEY';
  }
  //
  // Future<void> _handleTap(LatLng tappedPoint) async {
  //   setState(() {
  //     _markers.clear();
  //     _markers.add(Marker(
  //       markerId: MarkerId(tappedPoint.toString()),
  //       position: tappedPoint,
  //     ));
  //     pickedLatitude = tappedPoint.latitude;
  //     pickedLongitude = tappedPoint.longitude;
  //   });
  //
  //   // Reverse geocoding to get the address
  //   final apiKey = _getApiKey();
  //   final request = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=${tappedPoint.latitude},${tappedPoint.longitude}&key=$apiKey');
  //
  //   final response = await client.get(request);
  //
  //   if (response.statusCode == 200) {
  //     final jsonData = json.decode(response.body);
  //     if (jsonData['results'] != null && jsonData['results'].isNotEmpty) {
  //       final address = jsonData['results'][0]['formatted_address'];
  //       setState(() {
  //         pickedLocation = address;
  //       });
  //       _textController.text = address;
  //     }
  //   } else {
  //     print('Failed to fetch address: ${response.statusCode}');
  //   }
  // }

  void _confirmPickupLocation(double lat, double lng, String locationName, String cityName) {
    Navigator.pop(context, {'lat': lat, 'lng': lng, 'locationName': locationName, 'cityName': cityName});
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    if (place != null &&
        place.containsKey('latitude') &&
        place.containsKey('longitude')) {
      final double lat = place['latitude'];
      final double lng = place['longitude'];
      final String city = place['city'];

      pickedLatitude = lat;
      pickedLongitude = lng;
      pickedCity = city;

      final GoogleMapController controller = await _controller.future;
      CameraPosition _newCameraPosition = CameraPosition(
        target: LatLng(lat, lng),
        zoom: 13,
      );

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(_newCameraPosition),
      );

      _setMarker(LatLng(lat, lng));
    } else {
      print("Some properties are missing or null in the place object.");
    }
  }


// Future<void> _goToPlace(Map<String, dynamic> place) async {
  //   if (place != null &&
  //       place.containsKey('result') &&
  //       place['result'] != null &&
  //       place['result'].containsKey('geometry') &&
  //       place['result']['geometry'] != null &&
  //       place['result']['geometry'].containsKey('location') &&
  //       place['result']['geometry']['location'] != null) {
  //     final double lat = place['result']['geometry']['location']['lat'];
  //     final double lng = place['result']['geometry']['location']['lng'];
  //
  //     pickedLatitude = lat;
  //     pickedLongitude = lng;
  //
  //     final GoogleMapController controller = await _controller.future;
  //     CameraPosition _newCameraPosition = CameraPosition(
  //       target: LatLng(lat, lng),
  //       zoom: 13,
  //     );
  //
  //     await controller.animateCamera(
  //       CameraUpdate.newCameraPosition(_newCameraPosition),
  //     );
  //
  //     _setMarker(LatLng(lat, lng));
  //   } else {
  //     print("Some properties are missing or null in the place object.");
  //   }
  // }
}