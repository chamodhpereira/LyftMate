

import 'dart:math';
import 'package:flutter/material.dart';

class PolylineEncodingPage extends StatefulWidget {
  @override
  _PolylineEncodingPageState createState() => _PolylineEncodingPageState();
}

class _PolylineEncodingPageState extends State<PolylineEncodingPage> {
  String encodedPolyline = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Polyline Encoding Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Encoded Polyline:',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              encodedPolyline,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _encodePolyline,
              child: Text('Encode Polyline'),
            ),
          ],
        ),
      ),
    );
  }

  void _encodePolyline() {
    List<List<double>> coordinates = [
      [37.7749, -122.4194], // San Francisco, CA
      [34.0522, -118.2437], // Los Angeles, CA
      [40.7128, -74.0060], // New York City, NY
    ];

    setState(() {
      encodedPolyline = encodePolyline(coordinates);
    });
  }

  String encodePolyline(List<List<double>> coordinates) {
    List<int> polyline = [];

    for (var coordinate in coordinates) {
      int lat = (coordinate[0] * 1e5).round();
      int lng = (coordinate[1] * 1e5).round();

      _encodeSignedNumber(lat, polyline);
      _encodeSignedNumber(lng, polyline);
    }

    String result = '';
    for (var value in polyline) {
      result += _encodeValue(value);
    }

    return result;
  }

  void _encodeSignedNumber(int num, List<int> result) {
    int sgnNum = num << 1;
    if (num < 0) {
      sgnNum = ~sgnNum;
    }
    _encodeNumber(sgnNum, result);
  }

  void _encodeNumber(int num, List<int> result) {
    while (num >= 0x20) {
      result.add((0x20 | (num & 0x1f)) + 63);
      num >>= 5;
    }
    result.add(num + 63);
  }

  String _encodeValue(int value) {
    if (value >= 63) {
      return String.fromCharCode(value + 6);
    } else {
      return String.fromCharCode(value + 63);
    }
  }
}