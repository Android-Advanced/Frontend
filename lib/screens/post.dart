import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chatscreen.dart';
class Post extends StatelessWidget {
  final Map<String, String> itemData;

  const Post({super.key, required this.itemData});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 이미지 섹션
            Center(
              child: Image.network(
                itemData['image'] ?? '', // 데이터베이스의 이미지 URL
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, size: 50);
                },
              ),
            ),
            Spacer(), // 이미지와 텍스트 사이에 빈 공간 추가
            // 아래 텍스트 정보 섹션
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자 정보 섹션
                Row(
                  children: [
                    Icon(Icons.account_circle, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      itemData['displayName'] ?? '사용자 이름 없음', // 필요한 경우 데이터베이스에서 가져옴
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Spacer(),
                    Text(
                      '37.2°H / 2시간 전', // 더미 데이터
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // 게시글 제목
                Text(
                  itemData['title'] ?? '제목 없음',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                // 게시글 세부 정보
                Text(
                  '디지털기기 · 글올 1일 전',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  itemData['description'] ??
                      '해당 제품에 대한 설명이 없습니다.', // 데이터베이스에 추가 필드가 있으면 사용
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                // 가격과 채팅 버튼
                Row(
                  children: [
                    Text(
                      '${itemData['price']}원',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '가격 제안 불가',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        final currentUser = FirebaseAuth.instance.currentUser;

                        if (currentUser == null) {
                          print("사용자가 로그인하지 않았습니다.");
                          return;
                        }

                        final FirebaseFirestore _firestore = FirebaseFirestore.instance;
                        final chatRoomDoc = _firestore.collection('chatrooms').doc(itemData['title'] ?? '제목 없음');

                        // Firestore 문서 필드 업데이트
                        await chatRoomDoc.set({
                          'chatRoomId': itemData['title'] ?? '제목 없음', // 채팅방 ID
                          'message': '', // 초기 상태에서는 메시지가 비어 있음
                          'name': itemData['displayName'] ?? '사용자 이름 없음', // 대화 상대 이름
                          'participants': [currentUser.uid, itemData['userId'] ?? 'unknown'], // 참가자 목록
                          'price': '${itemData['price']}원', // 상품 가격
                          'product': itemData['title'] ?? '제목 없음', // 상품 이름
                          'productImage': itemData['image'] ?? '', // 상품 이미지
                          'profileImage': currentUser.photoURL ?? '', // 현재 사용자 프로필 이미지
                          'time': '1주전', // 현재 시간
                          'temperature': '37.2°C', // 더미 데이터
                          'senderId' : '',
                          'isRead' : false,
                        }, SetOptions(merge: true)); // 기존 데이터 병합

                        // 채팅 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatRoomId: itemData['title'] ?? '제목 없음', // 채팅방 ID
                              name: itemData['displayName'] ?? '사용자 이름 없음',
                              temperature: '37.2°C',
                              product: itemData['title'] ?? '제목 없음',
                              price: '${itemData['price']}원',
                              productImage: itemData['image'] ?? '',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: Text(
                        '채팅하기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

