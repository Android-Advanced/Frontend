import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Mapscreen extends StatefulWidget {
  const Mapscreen({Key? key}) : super(key: key);

  @override
  State<Mapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  late GoogleMapController _mapController;
  final LatLng _initialPosition = LatLng(37.582557057513185, 127.01022325889619);
  final Set<Marker> _markers = {};
  double _currentZoom = 15;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _loadMarkers() async {
    final items = await FirebaseFirestore.instance
        .collection('items')
        .where('location', isNotEqualTo: null)
        .get();

    for (var doc in items.docs) {
      final data = doc.data();
      final location = data['location'] as GeoPoint?;
      final imageUrl = data['image'] ?? '';

      if (location != null) {
        final markerIcon = await _getOptimizedMarkerIcon(imageUrl);

        final marker = Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: data['title'],
            snippet: data['description'],
          ),
          icon: markerIcon,
        );

        setState(() {
          _markers.add(marker);
        });
      }
    }
  }

  Future<BitmapDescriptor> _getOptimizedMarkerIcon(String imageUrl) async {
    try {
      final Uint8List imageData = await _fetchImageData(imageUrl);
      final Uint8List resizedImage = await _resizeImage(imageData, 100);
      return BitmapDescriptor.fromBytes(resizedImage);
    } catch (e) {
      print("Error loading marker icon: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<Uint8List> _fetchImageData(String imageUrl) async {
    final Uri uri = Uri.parse(imageUrl);
    final HttpClient httpClient = HttpClient();
    final HttpClientRequest request = await httpClient.getUrl(uri);
    final HttpClientResponse response = await request.close();
    final Completer<Uint8List> completer = Completer<Uint8List>();
    final List<int> bytes = [];
    response.listen(
          (chunk) => bytes.addAll(chunk),
      onDone: () => completer.complete(Uint8List.fromList(bytes)),
      onError: (e) => completer.completeError(e),
    );
    return completer.future;
  }

  Future<Uint8List> _resizeImage(Uint8List data, int size) async {
    final ui.Codec codec = await ui.instantiateImageCodec(data, targetWidth: size, targetHeight: size);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      _mapController.animateCamera(CameraUpdate.zoomTo(_currentZoom));
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
      _mapController.animateCamera(CameraUpdate.zoomTo(_currentZoom));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('지도'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: _currentZoom,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _zoomIn,
            child: Icon(Icons.zoom_in),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _zoomOut,
            child: Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }
}