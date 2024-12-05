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
  List<Map<String, String>> datas = [];
  late int currentPageIndex;

  @override
  void initState() {
    currentPageIndex=0;
    super.initState();
    datas = [
      {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      },
      {
        "image": "assets/images/2.jpg",
        "title": "아이폰 13프로맥스",
        "price": "1300000",
        "likes": "15"
      },
      {
        "image": "assets/images/2.jpg",
        "title": "커피머신",
        "price": "150000",
        "likes": "1"
      },
      {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      }, {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      },
      {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      },
      {
        "image": "assets/images/2.jpg",
        "title": "커피머신",
        "price": "150000",
        "likes": "1"
      },
      {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      }, {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      },
      {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      }
    ];
  }



  String calcStringToWon(String priceString){
    return "원";
  }
  Widget _bodyWidget() {
    switch (currentPageIndex){
      case 0:
        return Home();

      case 1:
        return Mapscreen();

      case 2:
        return ChatPage();

      case 3:
        return Profile();

    }
    return Container();
  }

  Widget _bottomNavigationbarWidget() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,  // 균등하게 아이템을 배분
      onTap: (int index){
        setState(() {
          currentPageIndex = index;
        });
      },
      selectedFontSize: 12,
      currentIndex: currentPageIndex,
      items: [
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
      selectedItemColor: Colors.black, // 선택된 항목의 아이콘과 label 색상
      unselectedItemColor: Colors.black, // 선택되지 않은 항목의 아이콘과 label 색상
      showUnselectedLabels: true, // 선택되지 않은 항목에도 label 표시
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _bodyWidget(),
        bottomNavigationBar: _bottomNavigationbarWidget(),
    );
  }
}