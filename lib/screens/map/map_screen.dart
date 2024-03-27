import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'address_search.dart';
// import 'place_service.dart';
import 'package:uuid/uuid.dart';

class MapScreen extends StatefulWidget {
  final String locType;


  MapScreen({super.key,
    required this.locType,

  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  late double pickedLongitude;
  late double pickedLatitude;
  late String pickedLocation;


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
    locationType = widget.locType;
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
                      pickedLocation = result.description;
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
                      _confirmPickupLocation(pickedLatitude, pickedLongitude  , _textController.text);
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

  void _confirmPickupLocation(double lat, double lng, String locationName) {
    Navigator.pop(context, {'lat': lat, 'lng': lng, 'locationName': locationName});
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    if (place != null &&
        place.containsKey('result') &&
        place['result'] != null &&
        place['result'].containsKey('geometry') &&
        place['result']['geometry'] != null &&
        place['result']['geometry'].containsKey('location') &&
        place['result']['geometry']['location'] != null) {
      final double lat = place['result']['geometry']['location']['lat'];
      final double lng = place['result']['geometry']['location']['lng'];

      pickedLatitude = lat;
      pickedLongitude = lng;

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
}