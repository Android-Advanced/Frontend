import 'package:flutter/material.dart';
import 'chatscreen.dart'; // ChatScreen 파일을 import (경로는 프로젝트에 따라 다를 수 있음)

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedIndex = 2; // 초기 선택 탭 (채팅 탭)

  // 더미 데이터 리스트
  final List<Map<String, dynamic>> chatList = [
    {
      'profileImage': 'https://via.placeholder.com/50', // 임시 프로필 이미지
      'name': '요이키',
      'temperature': '29.H', // 온도 정보 추가
      'time': '1주 전',
      'message': '확인했습니다 감사합니다 :)',
      'productImage': 'https://via.placeholder.com/50', // 임시 상품 이미지
      'product': '아이폰 13프로맥스 팝니다',
      'price': '1,300,000원',
    },
    {
      'profileImage': 'https://via.placeholder.com/50',
      'name': '한성마켓',
      'temperature': '37.2°H',
      'time': '2일 전',
      'message': '상품 문의 드립니다.',
      'productImage': 'https://via.placeholder.com/50',
      'product': '갤럭시 S21 울트라',
      'price': '900,000원',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: 원하는 페이지로 전환 로직 추가
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '채팅',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              // 알림 버튼 클릭 처리
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // "전체" 버튼 클릭 로직
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0E3672),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    '전체',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: chatList.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final chat = chatList[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(chat['profileImage']),
                  ),
                  title: Row(
                    children: [
                      Text(
                        chat['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 5), // 온도와 시간 간격
                      Row(
                        children: [
                          Text(
                            chat['temperature'], // 온도 정보
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 5), // 온도와 시간 간격
                          Text(
                            chat['time'], // 시간 정보
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Text(
                    chat['message'],
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    overflow: TextOverflow.ellipsis, // 메시지가 길 경우 ... 처리
                  ),
                  trailing: chat['productImage'] != null
                      ? Image.network(
                    chat['productImage'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : null,
                  onTap: () {
                    // 채팅 클릭 이벤트 처리 - ChatScreen으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          title: chat['name'],
                          temperature: chat['temperature'],
                          product: chat['product'],
                          price: chat['price'],
                          productImage: chat['productImage'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}