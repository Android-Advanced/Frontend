import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'profile.dart';
import './chatpage.dart';
import 'home.dart';
import 'map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int currentPageIndex;
  DateTime? _lastPressedAt; // 마지막으로 뒤로가기 버튼을 누른 시간

  @override
  void initState() {
    currentPageIndex = 0;
    super.initState();
  }

  // 각 탭에 해당하는 위젯 반환
  Widget _bodyWidget() {
    switch (currentPageIndex) {
      case 0:
        return Home(); // 홈 화면
      case 1:
        return Mapscreen(); // 지도 화면
      case 2:
        return ChatPage(); // 채팅 화면
      case 3:
        return Profile(); // 프로필 화면
      default:
        return Container();
    }
  }

  // BottomNavigationBar 구성
  Widget _bottomNavigationbarWidget() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        setState(() {
          currentPageIndex = index; // 탭 전환
        });
      },
      selectedFontSize: 12,
      currentIndex: currentPageIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30.0, color: Color(0xFF0E3672)),
          label: "홈",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map, size: 30.0, color: Color(0xFF0E3672)),
          label: "지도",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat, size: 30.0, color: Color(0xFF0E3672)),
          label: "채팅",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 30.0, color: Color(0xFF0E3672)),
          label: "프로필",
        ),
      ],
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
    );
  }

  // 뒤로가기 버튼 처리
  Future<bool> _onWillPop() async {
    if (currentPageIndex != 0) {
      // 홈이 아닌 경우, 홈으로 이동
      setState(() {
        currentPageIndex = 0;
      });
      return false;
    }

    // 홈에서 뒤로가기 버튼 두 번 눌렀을 때 종료
    final now = DateTime.now();
    if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('뒤로가기 버튼을 한 번 더 누르시면 앱이 종료됩니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // 뒤로가기 로직 추가
      child: Scaffold(
        body: _bodyWidget(),
        bottomNavigationBar: _bottomNavigationbarWidget(),
      ),
    );
  }
}
