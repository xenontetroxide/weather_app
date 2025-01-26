import 'package:http/http.dart' as http;
import 'dart:convert';

class City {
  final String name;
  final double lat;
  final double lon;
  final String country;

  const City({
    required this.name,
    required this.lat,
    required this.lon,
    required this.country
  });
}

class GeoParser {
  static List<City> cities = [];

  static List<City> parse(http.Response response) {
    if (response.statusCode == 400){
      // Bad request is acceptable when the query is empty,
      // but there's no meaningful data to return
      return [];
    }
    try {
      final List<dynamic> json = jsonDecode(response.body);
      cities = json.map((cityData) {
        return City(
            name: cityData['name'] ?? 'Unknown',
            lat: cityData['lat']?.toDouble() ?? 0.0,
            lon: cityData['lon']?.toDouble() ?? 0.0,
            country: cityData['country']  ?? 'Unknown'
        );
      }).toList();
      return cities;
    } catch (e) {
      throw FormatException('Failed to parse JSON: $e \n Response body:\n ${jsonDecode(response.body)}');
    }
  }
}

class WeatherParser {
  static (String, String, double, int, int, double, int, int) parse(http.Response response) {
    try {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data
          case {
            "weather": [
              {
                "main": String name,
                "icon": String icon
              }
            ],
            "main" : {
              "temp": double temperature,
              "pressure": int pressure,
              "humidity": int humidity
            },
            "visibility": int visibility,
            "wind": {
              "speed": double windSpeed,
              "deg": int windDegree,
            }
          }
      ) {
        return (icon, name, temperature, pressure, humidity, windSpeed, windDegree, visibility);
      } else {
        throw FormatException('Unexpected JSON: ${data}');
      }
    } catch (e) {
      throw FormatException('Failed to parse JSON: $e');
    }
  }
}

class MapsParser {}