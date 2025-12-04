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
  
  // Timișoara specific coordinates
  final LatLng _timisoaraCenter = const LatLng(45.7489, 21.2087); // Centrul Timișoarei (Piața Victoriei)
  final LatLng _operaRomana = const LatLng(45.7475, 21.2272); // Opera Română
  final LatLng _catedralaMitropolitana = const LatLng(45.7533, 21.2258); // Catedrala Mitropolitană
  final LatLng _universitate = const LatLng(45.7470, 21.2295); // Universitatea de Vest
  
  // Timișoara bounds
  static final LatLngBounds _timisoaraBounds = LatLngBounds(
    southwest: const LatLng(45.73, 21.18),  // Sud-Vest Timișoara
    northeast: const LatLng(45.77, 21.25),  // Nord-Est Timișoara
  );
  
  LatLng? _currentLocation;
  bool _isLoading = true;
  bool _locationEnabled = false;
  bool _usingRealShelters = false;
  Set<Marker> _markers = {};
  List<Shelter> _shelters = [];
  Shelter? _selectedShelter;
  double _mapZoom = 13.0;
  String _statusMessage = 'Încarc azilele din Timișoara...';

  @override
  void initState() {
    super.initState();
    print("🌍 Inițializare hartă Timișoara...");
    _checkGooglePlacesHealth();
    _initLocation();
  }

  Future<void> _checkGooglePlacesHealth() async {
    print("🔍 Verific Google Places API...");
    final health = await ApiService.checkGooglePlacesHealth();
    print("✅ Stare Google Places: $health");
    
    _usingRealShelters = health['googleApiKeyConfigured'] == true;
    
    if (_usingRealShelters) {
      print("📍 Folosesc azile REALE din Google Places API");
      _statusMessage = 'Caut azile reale în Timișoara...';
      await _loadRealShelters();
    } else {
      print("⚠️ Google Places API nu este configurat, folosesc azile locale");
      _statusMessage = 'Încarc azile locale din Timișoara...';
      await _loadLocalShelters();
    }
  }

  Future<void> _loadRealShelters() async {
    try {
      print("🔄 Încarc azile REALE din Timișoara...");
      final shelters = await ApiService.getRealSheltersFromGooglePlaces();
      print("✅ Am găsit ${shelters.length} azile în Timișoara");
      
      // Filter for Timișoara area only
      final timisoaraShelters = shelters.where((shelter) {
        if (shelter.latitude == null || shelter.longitude == null) return false;
        
        // Check if within Timișoara bounds
        return shelter.latitude! >= 45.73 && 
               shelter.latitude! <= 45.77 &&
               shelter.longitude! >= 21.18 && 
               shelter.longitude! <= 21.25;
      }).toList();
      
      setState(() {
        _shelters = timisoaraShelters.isNotEmpty ? timisoaraShelters : shelters;
        _statusMessage = 'Am găsit ${_shelters.length} azile în Timișoara';
      });
      
      // Add markers
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _addMarkers();
        }
      });
      
    } catch (e) {
      print("❌ Eroare la încărcarea azilelor reale: $e");
      _statusMessage = 'Eroare la încărcarea azilelor. Încerc azile locale...';
      await _loadLocalShelters();
    }
  }

  Future<void> _loadLocalShelters() async {
    try {
      print("🔄 Încarc azile locale din Timișoara...");
      final shelters = await ApiService.getShelters();
      
      // Filter for Timișoara shelters
      final timisoaraShelters = shelters.where((shelter) {
        return shelter.city?.toLowerCase().contains('timișoara') == true ||
               shelter.city?.toLowerCase().contains('timisoara') == true ||
               shelter.city == null; // Include shelters without city if we have no other data
      }).toList();
      
      print("✅ Am găsit ${timisoaraShelters.length} azile locale în Timișoara");
      
      setState(() {
        _shelters = timisoaraShelters.isNotEmpty ? timisoaraShelters : shelters;
        _isLoading = false;
        _statusMessage = 'Am găsit ${_shelters.length} azile în Timișoara';
      });
      
      _addMarkers();
      
    } catch (e) {
      print("❌ Eroare la încărcarea azilelor locale: $e");
      setState(() {
        _isLoading = false;
        _statusMessage = 'Nu am putut încărca azilele. Încearcă mai târziu.';
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

      print("📍 Obțin locația curentă în Timișoara...");
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      // Check if location is in Timișoara area
      bool isInTimisoara = position.latitude >= 45.73 && 
                           position.latitude <= 45.77 &&
                           position.longitude >= 21.18 && 
                           position.longitude <= 21.25;
      
      if (isInTimisoara) {
        print("✅ Locație în Timișoara: ${position.latitude}, ${position.longitude}");
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _locationEnabled = true;
        });
      } else {
        print("⚠️ Locația nu este în Timișoara, folosesc centrul Timișoarei");
        setState(() {
          _currentLocation = _timisoaraCenter;
          _locationEnabled = false;
        });
      }
      
    } catch (e) {
      print("❌ Eroare la obținerea locației: $e");
      setState(() {
        _locationEnabled = false;
        _currentLocation = _timisoaraCenter; // Default to Timișoara center
      });
    }
  }

  void _addMarkers() {
    print("📍 Adaug markeri pe hartă...");
    
    final markers = <Marker>{};
    int markerCount = 0;
    
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
              snippet: shelter.address ?? 'Timișoara',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet,
            ),
            onTap: () => _onMarkerTapped(shelter),
          ),
        );
        markerCount++;
      }
    }
    
    print("✅ Am adăugat $markerCount markeri pe hartă");
    
    // Add current location marker if available
    if (_currentLocation != null && _locationEnabled) {
      markers.add(
        Marker(
          markerId: const MarkerId('my_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: const InfoWindow(
            title: 'Locația mea',
            snippet: 'Sunteți aici în Timișoara',
          ),
        ),
      );
    }
    
    // Add Timișoara landmarks for reference
    _addTimisoaraLandmarks(markers);
    
    setState(() {
      _markers = markers;
      _isLoading = false;
    });
    
    // Zoom to show Timișoara area
    if (markers.isNotEmpty) {
      _zoomToTimisoara();
    }
  }

  void _addTimisoaraLandmarks(Set<Marker> markers) {
    // Add important landmarks in Timișoara for reference
    markers.addAll({
      Marker(
        markerId: const MarkerId('opera'),
        position: _operaRomana,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Opera Română', snippet: 'Timișoara'),
      ),
      Marker(
        markerId: const MarkerId('catedrala'),
        position: _catedralaMitropolitana,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Catedrala Mitropolitană', snippet: 'Timișoara'),
      ),
      Marker(
        markerId: const MarkerId('universitate'),
        position: _universitate,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Universitatea de Vest', snippet: 'Timișoara'),
      ),
    });
  }

  void _onMarkerTapped(Shelter shelter) {
    print("📍 Marker apăsat: ${shelter.name}");
    setState(() {
      _selectedShelter = shelter;
    });
    
    if (shelter.latitude != null && shelter.longitude != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(shelter.latitude!, shelter.longitude!),
          16.0,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    print("🗺️ Harta Timișoarei a fost creată");
    
    // Restrict map to Timișoara area
    _mapController.moveCamera(
      CameraUpdate.newLatLngBounds(_timisoaraBounds, 50.0),
    );
    
    // Add markers if not already added
    if (_markers.isEmpty && _shelters.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _addMarkers();
      });
    }
  }

  void _zoomToTimisoara() {
    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(_timisoaraBounds, 50.0),
    );
  }

  void _zoomToMyLocation() {
    if (_currentLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 16.0),
      );
    } else {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_timisoaraCenter, 14.0),
      );
    }
  }

  void _zoomToCentruTimisoara() {
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_timisoaraCenter, 15.0),
    );
  }

  Future<void> _openGoogleMaps(Shelter shelter) async {
    if (shelter.latitude == null || shelter.longitude == null) return;
    
    final address = Uri.encodeComponent(shelter.address ?? 'Timișoara');
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${shelter.latitude},${shelter.longitude}&query_place_id=${shelter.id}'
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
                        if (_usingRealShelters)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '📍 Azil real în Timișoara',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
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
                        '${shelter.address!}, Timișoara',
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
              
              if (shelter.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  shelter.description!,
                  style: TextStyle(color: textSecondary, fontSize: 14),
                  maxLines: 2,
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
                      label: const Text('Direcții'),
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
                      label: const Text('Sună'),
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
      _statusMessage = 'Reîncarc azilele din Timișoara...';
    });
    
    _checkGooglePlacesHealth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Azile în Timișoara'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshShelters,
            tooltip: 'Reîncarcă azilele',
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
                    style: TextStyle(
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
                    zoom: _mapZoom,
                  ),
                  markers: _markers,
                  myLocationEnabled: _locationEnabled,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  minMaxZoomPreference: const MinMaxZoomPreference(11.0, 18.0),
                  cameraTargetBounds: CameraTargetBounds(_timisoaraBounds),
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
                                    ? '${_shelters.length} azile în Timișoara'
                                    : 'Niciun azil găsit',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _usingRealShelters ? 'Date în timp real' : 'Date locale',
                                style: TextStyle(
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
                          _mapController.animateCamera(CameraUpdate.zoomIn());
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        onPressed: () {
                          _mapController.animateCamera(CameraUpdate.zoomOut());
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.remove, color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton.small(
                        heroTag: 'my_location',
                        onPressed: _zoomToMyLocation,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.my_location,
                          color: _locationEnabled ? primaryPurple : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'centru',
                        onPressed: _zoomToCentruTimisoara,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.location_city, color: primaryPurple),
                        tooltip: 'Centrul Timișoarei',
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
                          Icon(Icons.touch_app, color: primaryPurple, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Atinge un marker pentru detalii despre azil',
                              style: TextStyle(color: textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // No shelters found message
                if (_shelters.isEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pets, size: 60, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Nu am găsit azile în Timișoara',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Încearcă să reîncarci sau verifică conexiunea',
                            style: TextStyle(color: textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshShelters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPurple,
                            ),
                            child: const Text('Reîncarcă'),
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