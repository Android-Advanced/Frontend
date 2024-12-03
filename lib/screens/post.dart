import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chatscreen.dart';
class Post extends StatefulWidget {
  //final String itemId; // 게시글 ID

 // Post({required this.itemId});

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  String? buyerId; // 현재 로그인한 사용자의 ID
  String? profileImage; // 로그인한 사용자의 프로필 이미지

  @override
  void initState() {
    super.initState();
    fetchCurrentUserData(); // Firebase Authentication 및 Firestore 데이터 가져오기
  }

  Future<void> fetchCurrentUserData() async {
    try {
      // Firebase Authentication에서 현재 로그인한 사용자의 UID 가져오기
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        buyerId = currentUser.uid; // 현재 로그인한 사용자의 UID

        // Firestore에서 해당 사용자의 profileImage 가져오기
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(buyerId)
            .get();

        if (userSnapshot.exists) {
          final userData = userSnapshot.data() as Map<String, dynamic>;
          setState(() {
            profileImage = userData['profileImage'] ?? ''; // 프로필 이미지 저장
          });
        }
      } else {
        print('사용자가 로그인되어 있지 않습니다.');
      }
    } catch (e) {
      print('데이터 가져오기 중 오류 발생: $e');
    }
  }
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
                'https://image.made-in-china.com/202f0j00gCoYVfNWalqT/Newly-Spot-Mobile-Phone-M90-Water-Drop-Large-Screen-Fingerprint-Smartphone.webp', // 실제 이미지 URL로 변경
                height: 250, // 원하는 크기로 설정
                fit: BoxFit.cover,
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
                      '한성부기',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Spacer(),
                    Text(
                      '37.2°H / 2시간 전',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // 게시글 제목
                Text(
                  '아이폰 13프로맥스 팝니다.',
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
                  '8/31일 해외직구한\n한달도 안된제품 입니다.\n박풀 S급입니다.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                // 가격과 채팅 버튼
                Row(
                  children: [
                    Text(
                      '1,300,000',
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                chatRoomId: "test1", // Firestore 채팅방 ID
                                name: "요이키", // 대화 상대 이름
                                temperature: "29.1H",
                                product: "아이폰 13프로맥스 팝니다",
                                price:"1300000",
                                productImage:profileImage!,
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
