import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapscreen extends StatefulWidget {
  const Mapscreen({Key? key}) : super(key: key);

  @override
  State<Mapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  late GoogleMapController _mapController;

  final LatLng _initialPosition = LatLng(37.582557057513185, 127.01022325889619); // 한성대의 위도와 경도
  final Set<Marker> _markers = {};

  double _currentZoom = 15; // 초기 줌 레벨

  @override
  void initState() {
    super.initState();
    // 초기 마커 추가
    _markers.add(
      Marker(
        markerId: MarkerId('initial_marker'),
        position: _initialPosition,
        infoWindow: InfoWindow(
          title: '한성대학교',
          snippet: '한성대학교',
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // 줌인 기능
  void _zoomIn() {
    setState(() {
      _currentZoom += 1; // 줌 레벨 증가
      _mapController.animateCamera(
        CameraUpdate.zoomTo(_currentZoom),
      );
    });
  }

  // 줌아웃 기능
  void _zoomOut() {
    setState(() {
      _currentZoom -= 1; // 줌 레벨 감소
      _mapController.animateCamera(
        CameraUpdate.zoomTo(_currentZoom),
      );
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
          zoom: _currentZoom, // 초기 줌 레벨
        ),
        markers: _markers,
        myLocationEnabled: true, // 사용자의 현재 위치 표시
        myLocationButtonEnabled: true, // 현재 위치 버튼 활성화
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _zoomIn, // 줌인 버튼
            child: Icon(Icons.zoom_in),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _zoomOut, // 줌아웃 버튼
            child: Icon(Icons.zoom_out),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              // 새로운 위치 추가
              setState(() {
                LatLng newLocation = LatLng(37.5775, 126.9895); // 다른 위치
                _markers.add(
                  Marker(
                    markerId: MarkerId('new_marker'),
                    position: newLocation,
                    infoWindow: InfoWindow(
                      title: '새로운 마커',
                      snippet: '여기에 새로운 위치를 추가합니다.',
                    ),
                  ),
                );
                _mapController.animateCamera(
                  CameraUpdate.newLatLng(newLocation),
                );
              });
            },
            child: Icon(Icons.add_location),
          ),
        ],
      ),
    );
  }
}
