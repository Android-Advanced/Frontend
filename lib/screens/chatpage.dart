import 'package:flutter/material.dart';
import 'chatscreen.dart'; // ChatScreen 파일을 import (경로는 프로젝트에 따라 다를 수 있음)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth 추가

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth 인스턴스

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedIndex = 2; // 초기 선택 탭 (채팅 탭)

  // 현재 로그인된 사용자 UID 가져오기
  String? getCurrentUserId() {
    final currentUser = _auth.currentUser;
    return currentUser?.uid;
  }

  // 현재 사용자와 관련된 채팅방만 가져오는 Firestore 쿼리
  Stream<QuerySnapshot> getUserChatRooms() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.empty(); // 사용자 정보가 없으면 빈 스트림 반환
    }

    return firestore
        .collection('chatrooms')
        .where('participants', arrayContains: userId) // 필터링 조건
        .snapshots();
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
              stream: getUserChatRooms(), // 필터링된 채팅방 스트림 사용
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final chatRooms = snapshot.data!.docs;

                if (chatRooms.isEmpty) {
                  return Center(
                    child: Text(
                      '진행 중인 채팅방이 없습니다.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: chatRooms.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final chat = chatRooms[index].data() as Map<String, dynamic>;
                    final String? currentUserId = getCurrentUserId();
                     final List<String> participants = List<String>.from(chat['participants'] as List<dynamic>);
                    final List<String> names = List<String>.from(chat['name'] as List<dynamic>);
                    print(participants[0]);
                    final String? otherUserName;

                    if (participants[0] == currentUserId) {
                      otherUserName = names[1]; // 0번이 내 아이디와 같으면, 1번 이름
                    } else {
                      otherUserName = names[0]; // 1번이 내 아이디와 같으면, 0번 이름
                    }
                    final bool isUnreadMessage = chat['isRead'] == false && chat['senderId'] != currentUserId;


                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(chat['profileImage']),
                      ),
                      title: Row(
                        children: [
                          Text(
                            otherUserName,
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
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat['message'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: isUnreadMessage ? FontWeight.w900 : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (chat['notReadCount'] != null && chat['notReadCount'] > 0 &&  chat['senderId'] != currentUserId)
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                chat['notReadCount'].toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
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
                        print('Navigating to ChatScreen with data: ${chat['chatRoomId']}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatRoomId: chat['chatRoomId'], // Firestore에서 가져온 데이터
                              name: otherUserName!,
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
