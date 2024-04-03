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

  //// workinggggggggggggggggg
  // Future<Map<String, dynamic>> getPlaceDetailFromId(String placeId) async {
  //   final apiKey = _getApiKey();
  //   final request = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey');
  //   final response = await client.get(request);
  //
  //   if (response.statusCode == 200) {
  //     final result = json.decode(response.body);
  //     if (result['status'] == 'OK') {
  //       // print(result);
  //       final location = result['result']['geometry']['location'];
  //       print("QQQQLOOOOOOOOCATTTIOMMMMM: $location");
  //       final latitude = location['lat'];
  //       final longitude = location['lng'];
  //       print("LLAAAAAAAAAAAAAAAAAAAAAT $latitude");
  //       // return Suggestion(placeId, '', latitude, longitude);
  //       return result;
  //     } else {
  //       throw Exception(result['error_message']);
  //     }
  //   } else {
  //     throw Exception('Failed to fetch place details');
  //   }
  // }


  Future<Map<String, dynamic>> getPlaceDetailFromId(String placeId) async {
    final apiKey = _getApiKey();
    final request = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey');
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final location = result['result']['geometry']['location'];
        final latitude = location['lat'];
        final longitude = location['lng'];

        // Reverse Geocoding to get city name
        final reverseGeocodingRequest = Uri.parse(
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey');
        final reverseGeocodingResponse =
        await client.get(reverseGeocodingRequest);

        if (reverseGeocodingResponse.statusCode == 200) {
          final reverseGeocodingResult =
          json.decode(reverseGeocodingResponse.body);
          if (reverseGeocodingResult['status'] == 'OK') {
            // Extract city name from the response
            final addressComponents =
            reverseGeocodingResult['results'][0]['address_components'];
            String cityName = '';
            for (var component in addressComponents) {
              if (component['types'].contains('locality')) {
                cityName = component['long_name'];
                break;
              }
            }
            print("CCCCCCCCCCCCCCCCITTTTTTTTTTTTTTTTTY  NAMEEEEEEEEEEE: $cityName");
            return {'city': cityName, 'latitude': latitude, 'longitude': longitude};
          } else {
            throw Exception(reverseGeocodingResult['error_message']);
          }
        } else {
          throw Exception(
              'Failed to fetch reverse geocoding details: ${reverseGeocodingResponse.statusCode}');
        }
      } else {
        throw Exception(result['error_message']);
      }
    } else {
      throw Exception('Failed to fetch place details');
    }
  }
}