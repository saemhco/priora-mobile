import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({
    required this.initialLatitude,
    required this.initialLongitude,
    super.key,
  });
  final double initialLatitude;
  final double initialLongitude;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  late double _selectedLatitude;
  late double _selectedLongitude;
  bool _mapReady = false;

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
      // Búsqueda de lugares con Nominatim (OpenStreetMap), sin API key.
      final response = await Dio().get<dynamic>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'countrycodes': 'pe',
          'limit': 5,
          'accept-language': 'es',
        },
        options: Options(headers: {'User-Agent': 'priora-mobile-app'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data as List<dynamic>? ?? [];
        setState(() {
          _searchResults = results;
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
    if (_mapReady) {
      _mapController.move(LatLng(lat, lng), 15);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _gettingMyLocation = true;
    });
    try {
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están desactivados.');
      }

      var permission = await geo.Geolocator.checkPermission();
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

      final position = await geo.Geolocator.getCurrentPosition(
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
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              key: const ValueKey('mapPicker'),
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_selectedLatitude, _selectedLongitude),
                initialZoom: 15,
                onMapReady: () {
                  _mapReady = true;
                },
                onPositionChanged: (camera, hasGesture) {
                  final center = camera.center;
                  setState(() {
                    _selectedLatitude = center.latitude;
                    _selectedLongitude = center.longitude;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.dope.priora',
                  maxZoom: 19,
                ),
              ],
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
                          color: Colors.black.withValues(alpha: 0.08),
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
                                  padding: EdgeInsets.all(12),
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
                            color: Colors.black.withValues(alpha: 0.08),
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
                          final name = place['display_name']?.toString() ?? '';
                          final lat = double.tryParse(
                            place['lat']?.toString() ?? '',
                          );
                          final lon = double.tryParse(
                            place['lon']?.toString() ?? '',
                          );

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
                              if (lat != null && lon != null) {
                                _goToLocation(lat, lon);
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
      ),
    );
  }
}
