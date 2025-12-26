import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  // List of tapped points
  final List<LatLng> _points = [];

  // Markers to display
  final Set<Marker> _markers = {};

  // Polygons to display
  final Set<Polygon> _polygons = {};

  // Initial camera
  final CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(-1.286389, 36.817223), // Nairobi
    zoom: 12,
  );

  // Handle map tap to add marker
  void _onMapTapped(LatLng point) {
    final markerId = MarkerId(point.toString());
    setState(() {
      _points.add(point);

      // Add marker
      _markers.add(Marker(
        markerId: markerId,
        position: point,
        infoWindow: const InfoWindow(title: "Point"),
        onTap: () {
          _removeMarker(markerId);
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
      ));

      // Update polygon
      _updatePolygon();
    });
  }

  // Remove marker individually
  void _removeMarker(MarkerId markerId) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == markerId);
      _points.removeWhere((point) => MarkerId(point.toString()) == markerId);
      _updatePolygon();
    });
  }

  // Update polygon connecting all points
  void _updatePolygon() {
    if (_points.isEmpty) {
      _polygons.clear();
      return;
    }

    _polygons.clear();
    _polygons.add(Polygon(
      polygonId: const PolygonId("zone_polygon"),
      points: List.from(_points),
      strokeColor: Colors.blue,
      strokeWidth: 2,
      fillColor: Colors.blue.withOpacity(0.15),
    ));
  }

  // Clear all markers and polygon
  void _clearMarkers() {
    setState(() {
      _markers.clear();
      _points.clear();
      _polygons.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapping Zone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearMarkers,
            tooltip: "Clear all markers",
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCamera,
        onMapCreated: (controller) => _mapController = controller,
        onTap: _onMapTapped,
        markers: _markers,
        polygons: _polygons,
      ),
    );
  }
}
