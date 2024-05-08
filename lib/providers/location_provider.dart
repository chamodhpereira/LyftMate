import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationProvider extends ChangeNotifier {
  late LocationData _currentLocation;

  LocationData get currentLocation => _currentLocation;

  void updateLocation(LocationData locationData) {
    _currentLocation = locationData;
    notifyListeners();
  }
}