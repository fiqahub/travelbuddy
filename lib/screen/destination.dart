import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchResult {
  final String address;
  final LatLng location;
  String? selectedImageURL;

  SearchResult({required this.address, required this.location, this.selectedImageURL});
}

class DestinationSearchScreen extends StatefulWidget {
  @override
  _DestinationSearchScreenState createState() =>
      _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends State<DestinationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> searchResults = [];
  LatLng? selectedLocation;
  late MapController _mapController;
  GlobalKey<State<StatefulWidget>> _mapKey =
      GlobalKey<State<StatefulWidget>>();
  bool isDestinationSelected = false;
  double _currentZoom = 10.0;
  double _minZoom = 4.0;
  double _maxZoom = 18.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController(); // Initialize the map controller
  }

  void searchDestinations(String query) async {
    // Clear previous search results
    setState(() {
      searchResults = [];
    });

    if (query.isEmpty) {
      // Set the center of the map to the default location when the query is empty
      setState(() {
        selectedLocation = LatLng(0, 0);
      });
      return;
    }

    // Perform the search using Nominatim API
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5'));

    if (response.statusCode == 200) {
      final responseBody = response.body;
      final data = jsonDecode(responseBody) as List<dynamic>;

      try {
        // Filter out irrelevant results and extract valid coordinates
        final results = data
            .where((item) => item['lat'] != null && item['lon'] != null)
            .map((item) {
          final address = '${item['display_name']}';
          final lat = double.tryParse(item['lat'].toString()) ?? 0;
          final lon = double.tryParse(item['lon'].toString()) ?? 0;
          return SearchResult(address: address, location: LatLng(lat, lon));
        }).toList();

        // Update the search results
        setState(() {
          searchResults = results;
        });

        // Center the map on the first search result, if available
        if (results.isNotEmpty) {
          setState(() {
            selectedLocation = results[0].location;
          });
        }
      } catch (error) {
        print('Error parsing search results: $error');
      }
    } else {
      print('API request failed with status code: ${response.statusCode}');
    }
  }

  void selectDestination(SearchResult result) async {
    setState(() {
      selectedLocation = result.location;
      isDestinationSelected = true;
    });
    _mapController.move(result.location, _currentZoom);
  }


  void resetSearch() {
    setState(() {
      searchResults = [];
      selectedLocation = null;
      isDestinationSelected = false;
      _searchController.clear();
    });
  }

  void zoomIn() {
    if (selectedLocation != null && _currentZoom < _maxZoom) {
      setState(() {
        _currentZoom += 1.0;
      });
      _mapController.move(selectedLocation!, _currentZoom);
    }
  }

  void zoomOut() {
    if (selectedLocation != null && _currentZoom > _minZoom) {
      setState(() {
        _currentZoom -= 1.0;
      });
      _mapController.move(selectedLocation!, _currentZoom);
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Destination Search'),
    ),
    body: Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                key: _mapKey,
                mapController: _mapController,
                options: MapOptions(
                  center: selectedLocation ?? LatLng(0, 0),
                  zoom: _currentZoom,
                  minZoom: _minZoom,
                  maxZoom: _maxZoom,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(
                    markers: [
                      if (isDestinationSelected && selectedLocation != null)
                        Marker(
                          width: 30.0,
                          height: 30.0,
                          point: selectedLocation!,
                          builder: (ctx) => Container(
                            child: InkWell(
                              onTap: () => selectDestination(SearchResult(
                                address: '',
                                location: selectedLocation!,
                              )),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ...searchResults.map((result) => Marker(
                        width: 30.0,
                        height: 30.0,
                        point: result.location,
                        builder: (ctx) => Container(
                          child: InkWell(
                            onTap: () {
                              selectDestination(result);
                              setState(() {});
                            },
                            child: Icon(
                              Icons.location_on,
                              color: result.location == selectedLocation
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TypeAheadField<SearchResult>(
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Enter destination',
                                  border: InputBorder.none,
                                ),
                              ),
                              suggestionsCallback: (pattern) async {
                                final response = await http.get(
                                  Uri.parse('https://nominatim.openstreetmap.org/search?q=$pattern&format=json&limit=5'),
                                );

                                if (response.statusCode == 200) {
                                  final responseBody = response.body;
                                  final data = jsonDecode(responseBody) as List<dynamic>;

                                  try {
                                    final results = data
                                        .where((item) => item['lat'] != null && item['lon'] != null)
                                        .map((item) {
                                      final address = '${item['display_name']}';
                                      final lat = double.tryParse(item['lat'].toString()) ?? 0;
                                      final lon = double.tryParse(item['lon'].toString()) ?? 0;
                                      return SearchResult(address: address, location: LatLng(lat, lon));
                                    }).toList();
                                    return results;
                                  } catch (error) {
                                    print('Error parsing search results: $error');
                                  }
                                } else {
                                  print('API request failed with status code: ${response.statusCode}');
                                }

                                return []; // Return an empty list if there's an error or no results
                              },
                              itemBuilder: (context, SearchResult result) {
                                return ListTile(
                                  title: Text(result.address),
                                );
                              },
                              onSuggestionSelected: (SearchResult result) {
                                selectDestination(result);
                                _searchController.text = result.address;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: zoomIn,
                      icon: Icon(Icons.add),
                    ),
                    IconButton(
                      onPressed: zoomOut,
                      icon: Icon(Icons.remove),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (selectedLocation != null && searchResults.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Selected location: ${searchResults.firstWhere(
                (result) => result.location == selectedLocation,
                orElse: () => SearchResult(address: '', location: LatLng(0, 0)),
              ).address}',
            ),
          ),
      ],
    ),
  );
}

}