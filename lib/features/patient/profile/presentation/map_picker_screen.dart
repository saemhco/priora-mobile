import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const MapPickerScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  MapboxMap? _mapboxMap;
  late double _selectedLatitude;
  late double _selectedLongitude;

  final _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _searching = false;
  bool _gettingMyLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedLatitude = widget.initialLatitude;
    _selectedLongitude = widget.initialLongitude;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    setState(() {
      _searching = true;
    });
    try {
      final token = dotenv.env['MAPBOX_DOWNLOADS_TOKEN'] ?? '';
      final url =
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json';
      final response = await Dio().get(
        url,
        queryParameters: {
          'access_token': token,
          'country': 'pe',
          'limit': 5,
          'language': 'es',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final features = response.data['features'] as List<dynamic>? ?? [];
        setState(() {
          _searchResults = features;
        });
      }
    } catch (e) {
      debugPrint('Error searching places: $e');
    } finally {
      setState(() {
        _searching = false;
      });
    }
  }

  void _goToLocation(double lat, double lng) {
    setState(() {
      _selectedLatitude = lat;
      _selectedLongitude = lng;
      _searchResults = [];
      _searchController.clear();
    });
    _mapboxMap?.setCamera(
      CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 15.0),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _gettingMyLocation = true;
    });
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están desactivados.');
      }

      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          throw Exception('Los permisos de ubicación fueron denegados.');
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        throw Exception(
          'Los permisos de ubicación están denegados permanentemente.',
        );
      }

      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      _goToLocation(position.latitude, position.longitude);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación de GPS obtenida correctamente'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      setState(() {
        _gettingMyLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seleccionar Ubicación',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapPicker"),
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(_selectedLongitude, _selectedLatitude),
              ),
              zoom: 15.0,
            ),
            onMapCreated: (MapboxMap mapboxMap) {
              _mapboxMap = mapboxMap;
            },
            onCameraChangeListener: (event) {
              _mapboxMap?.getCameraState().then((state) {
                final center = state.center;
                final pos = center.coordinates;
                setState(() {
                  _selectedLatitude = pos.lat.toDouble();
                  _selectedLongitude = pos.lng.toDouble();
                });
              });
            },
          ),

          // Static Center Pin Marker (Uber style)
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 36,
                ), // Align bottom tip of the pin with dead center of map
                child: Icon(
                  Icons.location_pin,
                  color: Color(0xFF0256C2),
                  size: 48,
                ),
              ),
            ),
          ),

          // Search Bar Overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchPlaces,
                    decoration: InputDecoration(
                      hintText: 'Buscar lugar o dirección...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF64748B),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFF64748B),
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchResults = [];
                                });
                              },
                            )
                          : _searching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0256C2),
                                ),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: Color(0xFFF1F5F9), height: 1),
                      itemBuilder: (context, index) {
                        final place = _searchResults[index];
                        final name = place['place_name']?.toString() ?? '';
                        final coords = place['center'] as List<dynamic>?;

                        return ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF0256C2),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            if (coords != null && coords.length >= 2) {
                              final lng = coords[0] as double;
                              final lat = coords[1] as double;
                              _goToLocation(lat, lng);
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // My Location Button
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'myLocationBtn',
              onPressed: _gettingMyLocation ? null : _getCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0256C2),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: _gettingMyLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0256C2),
                      ),
                    )
                  : const Icon(Icons.my_location_rounded, size: 24),
            ),
          ),

          // Confirm Button
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'latitude': _selectedLatitude,
                    'longitude': _selectedLongitude,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0256C2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Confirmar Ubicación',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
