import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';


class Suggestion {
  final String placeId;
  final String description;
  // final double latitude;
  // final double longitude;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}
