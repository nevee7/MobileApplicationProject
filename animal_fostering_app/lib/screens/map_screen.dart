import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/shelter.dart';
import '../theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final LatLng _timisoaraCenter = const LatLng(45.7489, 21.2087);
  LatLng? _currentLocation;
  bool _isLoading = true;
  bool _locationEnabled = false;
  bool _usingRealShelters = false;
  Set<Marker> _markers = {};
  List<Shelter> _shelters = [];
  Shelter? _selectedShelter;

  @override
  void initState() {
    super.initState();
    _checkGooglePlacesHealth();
    _initLocation();
  }

  Future<void> _checkGooglePlacesHealth() async {
    print("Checking Google Places API health...");
    final health = await ApiService.checkGooglePlacesHealth();
    print("Google Places Health: $health");
    
    _usingRealShelters = health['googleApiKeyConfigured'] == true;
    
    if (_usingRealShelters) {
      print("Using REAL shelters from Google Places API");
      await _loadRealShelters();
    } else {
      print("Google Places API not configured, using local shelters");
      await _loadLocalShelters();
    }
  }

  Future<void> _loadRealShelters() async {
    try {
      print("Loading REAL shelters from Google Places...");
      final shelters = await ApiService.getRealSheltersFromGooglePlaces();
      print("Got ${shelters.length} REAL shelters");
      
      setState(() {
        _shelters = shelters;
      });
      
      // Add markers after a short delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _addMarkers();
        }
      });
      
    } catch (e) {
      print("Error loading real shelters: $e");
      // Fallback to local shelters
      await _loadLocalShelters();
    }
  }

  Future<void> _loadLocalShelters() async {
    try {
      print("Loading local shelters...");
      final shelters = await ApiService.getShelters();
      print("Got ${shelters.length} local shelters");
      
      setState(() {
        _shelters = shelters;
        _isLoading = false;
      });
      
      _addMarkers();
      
    } catch (e) {
      print("Error loading local shelters: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationEnabled = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationEnabled = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationEnabled = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationEnabled = true;
      });
      
    } catch (e) {
      setState(() {
        _locationEnabled = false;
      });
    }
  }

  void _addMarkers() {
    print("Adding markers for ${_shelters.length} shelters");
    
    final markers = <Marker>{};
    
    for (final shelter in _shelters) {
      if (shelter.latitude != null && 
          shelter.longitude != null &&
          shelter.latitude! != 0.0 && 
          shelter.longitude! != 0.0) {
        
        final markerId = MarkerId('shelter_${shelter.id}');
        final position = LatLng(shelter.latitude!, shelter.longitude!);
        
        markers.add(
          Marker(
            markerId: markerId,
            position: position,
            infoWindow: InfoWindow(
              title: shelter.name,
              snippet: shelter.address ?? 'Timisoara',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet,
            ),
            onTap: () => _onMarkerTapped(shelter),
          ),
        );
      }
    }
    
    if (_currentLocation != null && _locationEnabled) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'You are here',
          ),
        ),
      );
    }
    
    setState(() {
      _markers = markers;
      _isLoading = false;
    });
    
    // Zoom to fit all markers
    if (markers.isNotEmpty) {
      _zoomToFitMarkers();
    }
  }

  void _onMarkerTapped(Shelter shelter) {
    setState(() {
      _selectedShelter = shelter;
    });
    
    if (shelter.latitude != null && shelter.longitude != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(shelter.latitude!, shelter.longitude!),
          15.0,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Add markers if not already added
    if (_markers.isEmpty && _shelters.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _addMarkers();
      });
    }
  }

  void _zoomToFitMarkers() {
    if (_markers.isEmpty) return;
    
    try {
      final LatLngBounds bounds = _getBounds(_markers.map((m) => m.position).toList());
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    } catch (e) {
      print("Error zooming to markers: $e");
    }
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double? west, north, east, south;
    
    for (var point in points) {
      west = west != null ? (west < point.longitude ? west : point.longitude) : point.longitude;
      north = north != null ? (north > point.latitude ? north : point.latitude) : point.latitude;
      east = east != null ? (east > point.longitude ? east : point.longitude) : point.longitude;
      south = south != null ? (south < point.latitude ? south : point.latitude) : point.latitude;
    }
    
    return LatLngBounds(
      southwest: LatLng(south ?? _timisoaraCenter.latitude, west ?? _timisoaraCenter.longitude),
      northeast: LatLng(north ?? _timisoaraCenter.latitude, east ?? _timisoaraCenter.longitude),
    );
  }

  Future<void> _openGoogleMaps(Shelter shelter) async {
    if (shelter.latitude == null || shelter.longitude == null) return;
    
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${shelter.latitude},${shelter.longitude}&query_place_id=${shelter.id}'
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _makeCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Widget _buildShelterDetails() {
    if (_selectedShelter == null) return const SizedBox();

    final shelter = _selectedShelter!;
    
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shelter.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (shelter.source != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: shelter.source == 'GooglePlaces' 
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              shelter.source == 'GooglePlaces' ? '🔄 Real-time' : '📍 Local',
                              style: TextStyle(
                                fontSize: 10,
                                color: shelter.source == 'GooglePlaces' ? Colors.green : Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedShelter = null;
                      });
                    },
                  ),
                ],
              ),
              
              if (shelter.address != null) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 16, color: textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        shelter.address!,
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
              
              if (shelter.phone != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      shelter.phone!,
                      style: TextStyle(color: textSecondary),
                    ),
                  ],
                ),
              ],
              
              if (shelter.rating != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '${shelter.rating!.toStringAsFixed(1)}/5.0',
                      style: TextStyle(
                        color: Colors.amber[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openGoogleMaps(shelter),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.directions, size: 18),
                      label: const Text('Open in Maps'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (shelter.phone != null)
                    ElevatedButton.icon(
                      onPressed: () => _makeCall(shelter.phone!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text('Call'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshShelters() {
    setState(() {
      _isLoading = true;
      _markers.clear();
      _shelters.clear();
      _selectedShelter = null;
    });
    
    _checkGooglePlacesHealth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Shelters in Timisoara'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshShelters,
            tooltip: 'Refresh shelters',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? _timisoaraCenter,
                    zoom: 13.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: _locationEnabled,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                
                // Status indicator
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _usingRealShelters ? Icons.check_circle : Icons.info,
                          color: _usingRealShelters ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _usingRealShelters
                                ? '✅ Showing REAL shelters from Google'
                                : '⚠️ Showing local shelters (Google API not configured)',
                            style: TextStyle(
                              color: _usingRealShelters ? Colors.green : Colors.orange,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '${_shelters.length} found',
                          style: TextStyle(
                            color: primaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Map controls
                Positioned(
                  right: 16,
                  bottom: 100,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        onPressed: () {
                          _mapController.animateCamera(
                            CameraUpdate.zoomIn(),
                          );
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        onPressed: () {
                          _mapController.animateCamera(
                            CameraUpdate.zoomOut(),
                          );
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.remove, color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton.small(
                        heroTag: 'my_location',
                        onPressed: () {
                          if (_currentLocation != null) {
                            _mapController.animateCamera(
                              CameraUpdate.newLatLngZoom(_currentLocation!, 15.0),
                            );
                          }
                        },
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.my_location,
                          color: _locationEnabled ? primaryPurple : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Shelter Details
                if (_selectedShelter != null) _buildShelterDetails(),
                
                // Instruction when no shelter selected
                if (_selectedShelter == null && _shelters.isNotEmpty)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: primaryPurple, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tap on any ${_usingRealShelters ? 'REAL' : ''} shelter marker for details',
                              style: TextStyle(color: textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}