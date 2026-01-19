import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/shelter.dart';
import '../theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final LatLng _timisoaraCenter = const LatLng(45.7489, 21.2087);
  LatLng? _currentLocation;
  bool _isLoading = true;
  bool _locationEnabled = false;
  final bool _usingGooglePlaces = false;
  Set<Marker> _markers = {};
  List<Shelter> _shelters = [];
  Shelter? _selectedShelter;
  String _statusMessage = 'Loading shelters in Timisoara...';

  @override
  void initState() {
    super.initState();
    print("=== INITIALIZING MAP ===");
    _initLocation();
    _loadShelters();
  }

  Future<void> _loadShelters() async {
    print("=== LOADING SHELTERS ===");
    try {
      setState(() {
        _statusMessage = 'Searching for shelters in Timisoara...';
      });
      
      // Use direct fallback shelters for testing
      _useFallbackShelters();
      
    } catch (e) {
      print("Error loading shelters: $e");
      _useFallbackShelters();
    }
  }

  void _useFallbackShelters() {
    print("=== USING FALLBACK SHELTERS ===");
    final fallbackShelters = [
      Shelter(
        id: 1,
        name: "Animal Protection Association Timisoara",
        address: "Bega Street 1, Timisoara",
        city: "Timisoara",
        phone: "+40 256 494 320",
        latitude: 45.752821,
        longitude: 21.228017,
        description: "Main animal protection association in Timisoara",
        source: "Fallback",
      ),
      Shelter(
        id: 2,
        name: "Salvami Animal Rescue",
        address: "Coriolan Brediceanu Street 10, Timisoara",
        city: "Timisoara",
        phone: "+40 256 222 222",
        latitude: 45.749275,
        longitude: 21.229570,
        description: "Animal rescue and protection organization",
        source: "Fallback",
      ),
      Shelter(
        id: 3,
        name: "Doctor Vet Clinic",
        address: "Liviu Rebreanu Boulevard 48, Timisoara",
        city: "Timisoara",
        phone: "+40 256 293 939",
        latitude: 45.769898,
        longitude: 21.217364,
        description: "Veterinary clinic with emergency services",
        source: "Fallback",
      ),
      Shelter(
        id: 4,
        name: "Animed Veterinary Center",
        address: "Vasile Alecsandri Street 2, Timisoara",
        city: "Timisoara",
        phone: "+40 256 200 600",
        latitude: 45.751511,
        longitude: 21.225671,
        description: "Modern veterinary clinic",
        source: "Fallback",
      ),
    ];
    
    _updateShelters(fallbackShelters);
  }

  void _updateShelters(List<Shelter> shelters) {
    print("=== UPDATING SHELTERS ===");
    print("Received ${shelters.length} shelters");
    
    for (var shelter in shelters) {
      print("Shelter: ${shelter.name} - Lat: ${shelter.latitude}, Lng: ${shelter.longitude}");
    }
    
    setState(() {
      _shelters = shelters;
      _isLoading = false;
      _statusMessage = 'Found ${shelters.length} shelters in Timisoara';
    });
    
    // Add markers immediately
    _addMarkers();
  }

  Future<void> _initLocation() async {
    print("=== INITIALIZING LOCATION ===");
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print("Location service enabled: $serviceEnabled");
      
      if (!serviceEnabled) {
        print("Location services disabled");
        setState(() {
          _locationEnabled = false;
          _currentLocation = _timisoaraCenter;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print("Location permission: $permission");
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location permission denied");
          setState(() {
            _locationEnabled = false;
            _currentLocation = _timisoaraCenter;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Location permission denied forever");
        setState(() {
          _locationEnabled = false;
          _currentLocation = _timisoaraCenter;
        });
        return;
      }

      print("Getting current location...");
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
      
      print("Location obtained: ${position.latitude}, ${position.longitude}");
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationEnabled = true;
      });
      
    } catch (e) {
      print("Location error: $e");
      setState(() {
        _locationEnabled = false;
        _currentLocation = _timisoaraCenter;
      });
    }
  }

  void _addMarkers() {
    print("=== ADDING MARKERS ===");
    print("Shelters count: ${_shelters.length}");
    
    final markers = <Marker>{};
    int addedMarkers = 0;
    
    for (final shelter in _shelters) {
      print("Processing shelter: ${shelter.name}");
      print("Coordinates: ${shelter.latitude}, ${shelter.longitude}");
      
      if (shelter.latitude != null && 
          shelter.longitude != null &&
          shelter.latitude! != 0.0 && 
          shelter.longitude! != 0.0) {
        
        final markerId = MarkerId('shelter_${shelter.id}');
        final position = LatLng(shelter.latitude!, shelter.longitude!);
        
        print("✓ Adding marker for ${shelter.name} at $position");
        
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
        addedMarkers++;
      } else {
        print("✗ Skipping ${shelter.name} - invalid coordinates");
      }
    }
    
    print("Total markers added: $addedMarkers");
    
    // Add current location marker
    LatLng locationToShow = _currentLocation ?? _timisoaraCenter;
    markers.add(
      Marker(
        markerId: const MarkerId('my_location'),
        position: locationToShow,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
        infoWindow: InfoWindow(
          title: _locationEnabled ? 'Your Location' : 'Timisoara Center',
          snippet: _locationEnabled ? 'You are here in Timisoara' : 'Default location',
        ),
      ),
    );
    
    print("Setting markers in state...");
    setState(() {
      _markers = markers;
    });
    
    print("Markers set. Total markers on map: ${_markers.length}");
    
    // Zoom to fit markers
    if (markers.length > 1) {
      _zoomToFitMarkers();
    }
  }

  void _onMarkerTapped(Shelter shelter) {
    print("Marker tapped: ${shelter.name}");
    setState(() {
      _selectedShelter = shelter;
    });
    
    if (shelter.latitude != null && shelter.longitude != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(shelter.latitude!, shelter.longitude!),
          16.0,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    print("=== MAP CONTROLLER CREATED ===");
    _mapController = controller;
    
    // Add markers after a short delay to ensure map is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_shelters.isNotEmpty && _markers.isEmpty) {
        print("Map ready, adding markers...");
        _addMarkers();
      }
    });
  }

  void _zoomToFitMarkers() {
    if (_markers.isEmpty || _mapController == null) {
      print("Cannot zoom - no markers or map controller");
      return;
    }
    
    try {
      print("Zooming to fit markers...");
      LatLngBounds bounds = _getBounds(_markers.map((m) => m.position).toList());
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
      print("Zoomed to fit all markers");
    } catch (e) {
      print("Error zooming to markers: $e");
      // Fallback: zoom to Timisoara center
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_timisoaraCenter, 13.0),
      );
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
      'https://www.google.com/maps/search/?api=1&query=${shelter.latitude},${shelter.longitude}'
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _makeCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _refreshShelters() {
    print("=== REFRESHING SHELTERS ===");
    setState(() {
      _isLoading = true;
      _markers.clear();
      _shelters.clear();
      _selectedShelter = null;
      _statusMessage = 'Refreshing shelters in Timisoara...';
    });
    
    _loadShelters();
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
              
              ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${shelter.address}, Timisoara',
                      style: const TextStyle(color: textSecondary),
                    ),
                  ),
                ],
              ),
            ],
              
              if (shelter.phone != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      shelter.phone!,
                      style: const TextStyle(color: textSecondary),
                    ),
                  ],
                ),
              ],
              
              if (shelter.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  shelter.description!,
                  style: const TextStyle(color: textSecondary, fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
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
                      label: const Text('Get Directions'),
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

  @override
  Widget build(BuildContext context) {
    print("=== BUILDING MAP SCREEN ===");
    print("Is loading: $_isLoading");
    print("Shelters count: ${_shelters.length}");
    print("Markers count: ${_markers.length}");
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Shelters in Timisoara'),
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
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
                  onTap: (_) {
                    // Clear selection when tapping on map
                    if (_selectedShelter != null) {
                      setState(() {
                        _selectedShelter = null;
                      });
                    }
                  },
                ),
                
                // Status bar
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
                          _shelters.isNotEmpty ? Icons.check_circle : Icons.warning,
                          color: _shelters.isNotEmpty ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _shelters.isNotEmpty 
                                    ? '${_shelters.length} shelters in Timisoara'
                                    : 'No shelters found',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _statusMessage,
                                style: const TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
                          _mapController?.animateCamera(CameraUpdate.zoomIn());
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        onPressed: () {
                          _mapController?.animateCamera(CameraUpdate.zoomOut());
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.remove, color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton.small(
                        heroTag: 'my_location',
                        onPressed: () {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              _currentLocation ?? _timisoaraCenter, 
                              16.0
                            ),
                          );
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.my_location,
                          color: primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Shelter Details
                if (_selectedShelter != null) _buildShelterDetails(),
                
                // Instruction when no shelter selected
                if (_selectedShelter == null && _shelters.isNotEmpty && _markers.length > 1)
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
                      child: const Row(
                        children: [
                          Icon(Icons.touch_app, color: primaryPurple, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tap any marker for shelter details',
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