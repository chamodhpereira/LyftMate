import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
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

  late double? pickedLatitude = 0;
  late double? pickedLongitude = 0;
  late String pickedLocation;
  late String pickedCity;

  final client = Client();


  final Completer<GoogleMapController> _controller = Completer();
  final _textController = TextEditingController();

  // static const CameraPosition _kGooglePlex = CameraPosition(target: LatLng(37.4223, -122.0848), zoom: 14);
  CameraPosition _kUserLocation = CameraPosition(target: LatLng(7.872090899526995, 80.79122432719277), zoom:7);


  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  List<LatLng> polygonLatLngs = <LatLng>[];

  int _polygonIdCounter = 1;

  void _setMarker(LatLng point) {
    setState(() {
      _markers.clear();
      _markers.add(Marker(markerId: const MarkerId("_currentLocation"), position: point));
    });
  }

  Future<void> _getCurrentLocation() async {
    LocationData? locationData;
    var location = Location();

    try {
      locationData = await location.getLocation();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to retrieve your location. Please make sure location services are enabled.'),
        ),
      );
      print('Failed to get location: $e');
    }

    if (locationData != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(locationData.latitude!, locationData.longitude!),
          zoom: 14,
        ),
      ));
    }
  }

  late String locationType;

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
    locationType = widget.locType!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
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
              // onMapCreated: (GoogleMapController controller) {
              //   _controller.complete(controller);
              //   _getCurrentLocation(); // Call _getCurrentLocation here
              // },
              initialCameraPosition: _kUserLocation,
              myLocationEnabled: true, // Enable my location button
              myLocationButtonEnabled: true,

              markers: _markers,
              padding: EdgeInsets.symmetric(vertical: 55.0),
              onTap: _handleTap,
              onCameraMoveStarted: () {
                // When camera movement starts, get the camera position and perform reverse geocoding
                // _getCurrentLocation();
              },
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
                  child:
                  ElevatedButton(
                    onPressed: () {
                      if (pickedLatitude == 0 || pickedLongitude == 0) {
                        debugPrint("Insideeee IFFFFFFFFFFFFFF BLOCCCCCCCCCCCCCK");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please choose a location on the map.'),
                          ),
                        );
                      } else {
                        debugPrint("Insideeee ELSEEEEEEEEEEE BLOCCCCCCCCCCCCCK");
                        _confirmPickupLocation(pickedLatitude, pickedLongitude, _textController.text, pickedCity);
                      }
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                    ),
                    child: Text(
                        widget.locType == 'dropoff' ? "Confirm Dropoff Location" : "Confirm Pickup Location",
                        // style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)
                    ),
                  ),

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getApiKey() {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_DEFAULT_API_KEY';
  }
  //
  Future<void> _handleTap(LatLng tappedPoint) async {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId(tappedPoint.toString()),
        position: tappedPoint,
      ));
      pickedLatitude = tappedPoint.latitude;
      pickedLongitude = tappedPoint.longitude;
    });

    // Reverse geocoding to get the address
    final apiKey = _getApiKey();
    final request = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=${tappedPoint.latitude},${tappedPoint.longitude}&key=$apiKey');

    final response = await client.get(request);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['results'] != null && jsonData['results'].isNotEmpty) {
        debugPrint("this is the debuggggggggg results: ${jsonData['results'][0]["address_components"]}");

        final addressComponents = jsonData['results'][0]['address_components'];

        String cityName = '';
        for (var component in addressComponents) {
          if (component['types'].contains('locality')) {
            cityName = component['long_name'];
            break;
          }
        }

        debugPrint("this is the debuggggggggg CITYYYY: $cityName");

        final address = jsonData['results'][0]['formatted_address'];
        setState(() {
          pickedLocation = address;
          // debugPrint("PCKEDDDDDDDDDD LOCATIOMMMMMMMMMM: $pickedLocation");
          pickedCity = cityName;
        });
        _textController.text = address;

        // Get the GoogleMapController from the Completer
        final GoogleMapController controller = await _controller.future;

        // Animate camera to the tapped location
        controller.animateCamera(
          CameraUpdate.newLatLng(tappedPoint),
        );
      }
    } else {
      print('Failed to fetch address: ${response.statusCode}');
    }
  }

  void _confirmPickupLocation(double? lat, double? lng, String locationName, String cityName) {
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please choose a location on the map.'),
        ),
      );
    } else {
      Navigator.pop(context, {'lat': lat, 'lng': lng, 'locationName': locationName, 'cityName': cityName});
    }
  }

  Future<void> _goToPlace(Map<String, dynamic>? place) async {
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

      // setState(() {
      //   _markers.clear();
      //   _markers.add(Marker(
      //     markerId: MarkerId(tappedPoint.toString()),
      //     position: tappedPoint,
      //   ));

      _setMarker(LatLng(lat, lng));
    } else {
      print("Some properties are missing or null in the place object.");
    }
  }
}