import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewScreen extends StatefulWidget {
  final String chatRoomId;

  ReviewScreen({required this.chatRoomId}); // chatRoomId를 받는 생성자 추가
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _currentTemperature = 3.0;
  final TextEditingController _reviewController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _reviewerName = "User"; // 현재 사용자 이름
  String _revieweeName = "Seller"; // 판매자 이름

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // 현재 사용자 이름 가져오기
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      _reviewerName = userDoc.data()?['displayName'] ?? "User";

      // 판매자 이름 가져오기
      final chatRoomDoc = await _firestore.collection('chatrooms').doc(widget.chatRoomId).get();
      if (chatRoomDoc.exists) {
        final chatRoomData = chatRoomDoc.data();
        final revieweeUID = chatRoomData?['participants']
            ?.firstWhere((uid) => uid != currentUser.uid, orElse: () => null);

        if (revieweeUID != null) {
          final revieweeDoc = await _firestore.collection('users').doc(revieweeUID).get();
          _revieweeName = revieweeDoc.data()?['displayName'] ?? "Seller";
        }
      }

      setState(() {}); // 상태 업데이트
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _submitReview() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Firestore에서 users 컬렉션에서 displayName 가져오기
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final reviewerName = userDoc.data()?['displayName'] ?? "Anonymous"; // displayName 가져오기

      // chatRoomId에 해당하는 문서에서 데이터 가져오기
      final chatRoomDoc = await _firestore.collection('chatrooms').doc(widget.chatRoomId).get();
      if (!chatRoomDoc.exists) {
        throw "ChatRoom 문서를 찾을 수 없습니다.";
      }

      final chatRoomData = chatRoomDoc.data() ?? {};
      final revieweeUID = chatRoomData['participants']
          ?.firstWhere((uid) => uid != currentUser.uid, orElse: () => "unknown");
      final thumbnail = chatRoomData['productImage'] ?? "https://example.com/default-thumbnail.jpg";

      final reviewUID = _firestore.collection('reviews').doc().id; // Unique ID 생성
      final createdAt = FieldValue.serverTimestamp(); // 현재 시간
      final itemID = widget.chatRoomId; // 채팅방 ID를 ItemID로 사용

      // 온도 계산 및 소수점 첫째 자리까지만 반영
      final rating = double.parse((36.5 + (_currentTemperature - 3) * 0.5).toStringAsFixed(1));
      final reviewText = _reviewController.text.trim();

      // Firestore에 리뷰 추가
      await _firestore.collection('reviews').doc(reviewUID).set({
        'itemID': itemID,
        'createdAt': createdAt,
        'rating': rating,
        'reviewText': reviewText,
        'revieweeUID': revieweeUID,
        'reviewerName': reviewerName, // Firestore에서 가져온 이름 사용
        'reviewerUID': currentUser.uid,
        'thumbnail': thumbnail,
      });

      // Reviewee의 HansungPoint 갱신
      if (revieweeUID != "unknown") {
        final revieweeDoc = await _firestore.collection('users').doc(revieweeUID).get();
        final revieweeData = revieweeDoc.data();
        if (revieweeData != null) {
          final currentHansungPoint = revieweeData['hansungPoint'] ?? 36.5;
          final updatedHansungPoint = double.parse(
            ((currentHansungPoint + rating) / 2).toStringAsFixed(1),
          ); // 평균 계산 후 소수점 첫째 자리까지만 반영

          await _firestore.collection('users').doc(revieweeUID).update({
            'hansungPoint': updatedHansungPoint,
          });
        }
      }

      // 완료 후 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("후기가 제출되었습니다.")),
      );

      Navigator.pop(context); // 작성 후 이전 화면으로 돌아가기
    } catch (error) {
      // 에러 처리
      print("후기 작성 중 오류 발생: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("후기 작성 중 오류가 발생했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              "거래 후기 작성",
              style: TextStyle(color: Colors.black),
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Divider(
              color: Colors.grey[300],
              thickness: 1.0,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              '$_reviewerName님,\n$_revieweeName님과의 거래가 어떠셨나요?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.grey[300],
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: Colors.blue,
                      overlayShape: SliderComponentShape.noOverlay,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: _currentTemperature,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (value) {
                        setState(() {
                          _currentTemperature = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "${(36.5 + (_currentTemperature - 3) * 0.5).toStringAsFixed(1)}°C",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF4AC1DB),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Text(
              '어떤 점이 좋고, 어떤 점이 별로였나요?\n후기를 적어주세요!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: '여기에 적어주세요!',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFEBEBEB),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0E3672),
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: screenWidth * 0.3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  '후기 보내기',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
