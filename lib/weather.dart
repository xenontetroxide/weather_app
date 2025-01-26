import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/response.dart';
import 'package:weather_app/parse.dart';


class CurrentWeather extends StatefulWidget{
  final double lat;
  final double lon;

  const CurrentWeather({
    super.key,
    required this.lat,
    required this.lon,
  });

  @override
  State<CurrentWeather> createState() => _CurrentWeatherState();
}

class _CurrentWeatherState extends State<CurrentWeather> {
  // Cached future
  late Future<(String, String, double, int, int, double, int, int)> _weather;

  Future<(String, String, double, int, int, double, int, int)> _getWeather() async {
    return WeatherParser.parse(await Response.fetchWeather(widget.lat, widget.lon));
  }

  @override
  void initState() {
    super.initState();
    _weather = _getWeather();  // Fetch the data only once
  }

  @override
  void didUpdateWidget(covariant CurrentWeather oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.lat != oldWidget.lat) || (widget.lon != oldWidget.lon)) {
      _weather = _getWeather();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _weather,  // use the cached future
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load weather data.'),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _weather = _getWeather(); // Retry fetching data
                      });
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          else if (snapshot.hasData) {
            final (String weatherIcon,
            String weatherCondition,
            double temperature,
            int pressure,
            int humidity,
            double windSpeed,
            int windDegree,
            int visibility) = snapshot.data!;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12.0)
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Image.network('https://openweathermap.org/img/wn/${weatherIcon}@2x.png'),
                        SizedBox(height: 8.0),
                        Text(
                          weatherCondition,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          else {
            return Center(
              child: Text('No weather data available.'),
            );
          }
        }
    );
  }
}