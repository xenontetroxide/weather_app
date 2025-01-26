import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';

class KeyStorage {
  static File get _localFile {
    return File('api_key.txt');
  }

  static String readKey() {
    try {
      final file = _localFile;
      final contents = file.readAsLinesSync();
      return contents.first;
    } catch (e) {
      return '';
    }
  }
}

class Response {
  static String? _apiKey;
  static const resultsLimit = 5;  // up to 5 results can be returned in the API response

  static void _init() {
    Response._apiKey = KeyStorage.readKey();
  }

  static Future<http.Response> fetchLocation(String cityName) async {
    if (_apiKey == null) {
      _init();
    }
    var url = Uri.https(
        'api.openweathermap.org',
        '/geo/1.0/direct',
        {
          'q': cityName,
          'limit': '$resultsLimit',
          'appid': _apiKey
        }
    );
    try {
      return await http.get(url);
    } catch (e) {
      throw Exception('Failed to fetch location: $e');
    }
  }

  static Future<http.Response> fetchWeather(double lat, double lon) async {
    if (_apiKey == null) {
      _init();
    }
    var url = Uri.https(
        'api.openweathermap.org',
        '/data/2.5/weather',
        {
          'lat': '$lat',
          'lon': '$lon',
          'appid': _apiKey
        }
    );
    try {
      return await http.get(url);
    } catch (e) {
      throw Exception('Failed to fetch current weather data: $e');
    }
  }
}
