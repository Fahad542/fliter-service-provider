import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesService {
  final String apiKey;
  static const String _autocompleteUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String _detailsUrl = 'https://maps.googleapis.com/maps/api/place/details/json';

  GooglePlacesService(this.apiKey);

  Future<List<Map<String, dynamic>>> getSuggestions(String input) async {
    if (input.isEmpty) return [];

    final url = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
      'input': input,
      'key': apiKey,
    });
    
    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['predictions']);
        } else {
          print('Google Places Error: ${data['status']}');
          print('Error Message: ${data['error_message']}');
        }
      } else {
        print('Google Places HTTP Error: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final url = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
      'place_id': placeId,
      'fields': 'geometry',
      'key': apiKey,
    });
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['result']['geometry']['location'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
