import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider(this.sessionToken);

  final sessionToken;


  String _getApiKey() {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_DEFAULT_API_KEY';
  }


  // final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final apiKey = _getApiKey();
    final request = Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=$lang&components=country:lk&key=$apiKey&sessiontoken=$sessionToken');

    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return (result['predictions'] as List<dynamic>).map<Suggestion>((prediction) {
          // print(prediction);
          final placeId = prediction['place_id'];
          final description = prediction['description'];
          // final lat = prediction['geometry']['location']['lat'];
          // final lng = prediction['geometry']['location']['lng'];
          return Suggestion(placeId, description);
        }).toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }


  Future<Map<String, dynamic>> getPlaceDetailFromId(String placeId) async {
    final apiKey = _getApiKey();
    final request = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey');
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // print(result);
        final location = result['result']['geometry']['location'];
        print("QQQQLOOOOOOOOCATTTIOMMMMM: $location");
        final latitude = location['lat'];
        final longitude = location['lng'];
        print("LLAAAAAAAAAAAAAAAAAAAAAT $latitude");
        // return Suggestion(placeId, '', latitude, longitude);
        return result;
      } else {
        throw Exception(result['error_message']);
      }
    } else {
      throw Exception('Failed to fetch place details');
    }
  }
}