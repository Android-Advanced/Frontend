import 'package:flutter/material.dart';
import 'chatscreen.dart'; // ChatScreen 파일을 import (경로는 프로젝트에 따라 다를 수 있음)
import 'package:cloud_firestore/cloud_firestore.dart';
final FirebaseFirestore firestore = FirebaseFirestore.instance;



class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedIndex = 2; // 초기 선택 탭 (채팅 탭)



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
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('chatrooms').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final chatRooms = snapshot.data!.docs;

                return ListView.separated(
                  itemCount: chatRooms.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final chat = chatRooms[index].data() as Map<String, dynamic>;
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
                          SizedBox(width: 5),
                          Text(
                            chat['temperature'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            chat['time'],
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        chat['message'],
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
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
                );
              },
            ),
          ),

        ],
      ),

    );
  }
}