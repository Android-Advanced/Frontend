import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapscreen extends StatefulWidget {
  const Mapscreen({Key? key}) : super(key: key);

  @override
  State<Mapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  late GoogleMapController _mapController;

  final LatLng _initialPosition = LatLng(37.5665, 126.9780); // 서울의 위도와 경도
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // 초기 마커 추가
    _markers.add(
      Marker(
        markerId: MarkerId('initial_marker'),
        position: _initialPosition,
        infoWindow: InfoWindow(
          title: '서울',
          snippet: '서울의 중심부',
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지도 화면'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 12, // 확대 레벨
        ),
        markers: _markers,
        myLocationEnabled: true, // 사용자의 현재 위치 표시
        myLocationButtonEnabled: true, // 현재 위치 버튼 활성화
      ),
      floatingActionButton: FloatingActionButton(
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
    );
  }
}
