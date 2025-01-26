import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weather_app/parse.dart';
import 'package:weather_app/response.dart';
import 'package:weather_app/weather.dart';

void main() {
  runApp(MyApp());
}

class MyAppState extends ChangeNotifier {
  void refreshResults(){
    // NEED TO DO a button to refresh results
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey.shade50,
            // surface: Colors.blueGrey.shade50,
            dynamicSchemeVariant: DynamicSchemeVariant.neutral,
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // createState() is overridden to return an instance (=>) of a class
  // that extends State. Flutter is told which state object to use for
  // managing UI and behaviour of the MyHomePage widget
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _cityName = 'London';
  double _lat = 51.5073219;
  double _lon = -0.1276474;

  var _selectedIndex = 0;
  String _lastQuery = "";
  List<ListTile> _lastOptions = [];
  bool _isDialogOpen = false;

  void _handleScreenChanged(int selectedScreen){
    setState(() {
      _selectedIndex = selectedScreen;
    });
  }

  void _handleSelection(City city){
    setState(() {
      _cityName = city.name;
      _lat = city.lat;
      _lon = city.lon;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    String pageName = '';

    switch (_selectedIndex){
      case 0:
        page = CurrentWeather(lat: _lat, lon: _lon);
        pageName = 'Current Weather';
      // case 1:
        // page = Forecast(apiKey: _apiKey);
      // case 2:
        // page = Maps(apiKey: _apiKey);
      default:
        throw UnimplementedError('No widget for $_selectedIndex');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          TextButton.icon(
              icon: const Icon(Icons.location_on_outlined),
              label: Text(_cityName),
              onPressed: () {
                setState(() {
                  _isDialogOpen = true;
                });
                showDialog(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                    child: SearchAnchor.bar(
                      suggestionsBuilder:
                        (BuildContext context, SearchController controller) async {
                          if (!_isDialogOpen) {
                            return _lastOptions;
                          }
                          final String input = controller.value.text;
                          if (input.isEmpty) {
                            _lastOptions = [];
                            return [];
                          }
                          if (_lastQuery == input){
                            return _lastOptions;
                          }
                          try {
                            _lastQuery = input;
                            final List<City> options = GeoParser.parse(await Response.fetchLocation(input));
                            if (options.isEmpty) {
                              _lastOptions = [];
                              return [];
                            }
                            final queryResults = List<ListTile>.generate(
                                Response.resultsLimit.clamp(0, options.length),
                                (index) {
                                  final city = options[index];
                                  return ListTile(
                                    title: Text(city.name),
                                    subtitle: Text(city.country),
                                    onTap: () {
                                      _handleSelection(city);
                                      controller.closeView(city.name);
                                      Navigator.pop(context);
                                    },
                                  );
                                }
                            );
                            _lastOptions = queryResults;
                            return queryResults;
                          } catch (e) {
                            debugPrint('Error fetching suggestions: $e');
                            return [];
                          }
                      },
                    ),
                  )
                ).then((_) {
                  setState(() {
                    _isDialogOpen = false;
                  });
                });
              },
          ),
          SizedBox(width: 12.0),
        ],
      ),
      drawer: NavigationDrawer(
          backgroundColor: Theme.of(context).colorScheme.surface,
          onDestinationSelected: _handleScreenChanged,
          selectedIndex: _selectedIndex,
          tilePadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          children: [
            SizedBox(height: 12.0),
            NavigationDrawerDestination(
                icon: Icon(Icons.wb_cloudy_outlined),
                label: Text('Current Weather'),
            ),
            NavigationDrawerDestination(
                icon: Icon(Icons.wb_sunny_outlined),
                label: Text('Forecast'),
            ),
            NavigationDrawerDestination(
                icon: Icon(Icons.map_outlined),
                label: Text('Maps'),
            ),
          ]
      ),
      body: page,
    );
  }
}