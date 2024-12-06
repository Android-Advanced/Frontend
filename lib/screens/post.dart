import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'chatscreen.dart';

class Post extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const Post({super.key, required this.itemData});

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfileImage();
  }

  Future<void> _fetchUserProfileImage() async {
    try {
      final String userId = widget.itemData['userId'] ?? '';

      if (userId.isNotEmpty) {
        // Firestore에서 users 컬렉션의 userId에 해당하는 문서를 가져옴
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            profileImageUrl = userData['profileImage'] ?? '';
            // Firebase Storage URL 변환
            if (profileImageUrl.startsWith('gs://')) {
              FirebaseStorage.instance
                  .refFromURL(profileImageUrl)
                  .getDownloadURL()
                  .then((url) {
                setState(() {
                  profileImageUrl = url;
                });
              });
            }
          });
        }
      }
    } catch (e) {
      print('프로필 이미지 가져오기 실패: $e');
    }
  }

  String calculateTimeAgo(String createdAt) {
    try {
      final DateTime createdTime = DateTime.parse(createdAt);
      final Duration difference = DateTime.now().difference(createdTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}분 전';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}시간 전';
      } else {
        return '${difference.inDays}일 전';
      }
    } catch (e) {
      print('시간 계산 중 오류 발생: $e');
      return '알 수 없음';
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
                widget.itemData['image'] ?? '',
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
                    CircleAvatar(
                      radius: 25, // 프로필 이미지 크기
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null, // 네트워크 이미지
                      child: profileImageUrl.isEmpty
                          ? Icon(Icons.account_circle, size: 50, color: Colors.blue)
                          : null, // 기본 아이콘
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.itemData['displayName'] ?? '사용자 이름 없음',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 찜 버튼
                        IconButton(
                          icon: Icon(
                            Icons.favorite_border, // 기본 찜 상태는 빈 하트
                            color: Colors.red,
                          ),
                          onPressed: () {
                            // 찜 상태 관리 로직

                          },
                        ),
                    Text(
                      '${widget.itemData['hansungPoint'] ?? '포인트 없음'}°C · ${calculateTimeAgo(widget.itemData['createdAt'] ?? '')}',
                      style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // 게시글 제목
                Text(
                  widget.itemData['title'] ?? '제목 없음',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                // 게시글 세부 정보
                Text(
                  '${widget.itemData['categories'] ?? '카테고리 없음'} · ${widget.itemData['buyerId']!.isEmpty ? '판매중' : '판매완료'}',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  widget.itemData['description'] ??
                      '해당 제품에 대한 설명이 없습니다.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                // 가격과 채팅 버튼
                Row(
                  children: [
                    Text(
                      '${widget.itemData['price']}원',
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


                        final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
                        if (!userDoc.exists) {
                          print("사용자 문서를 찾을 수 없습니다.");
                          return;
                        }
                        final String? buyerName = userDoc.data()?['displayName'];

                        final chatRoomDoc = _firestore.collection('chatrooms').doc('${currentUser.uid}${widget.itemData['userId']}');


                        // Firestore 문서 필드 업데이트
                        await chatRoomDoc.set({
                          'chatRoomId': '${currentUser.uid}${widget.itemData['userId']}',
                          'message': '', // 초기 상태에서는 메시지가 비어 있음
                          'name': [buyerName,widget.itemData['displayName']], // 대화 상대 이름
                          'participants': [currentUser.uid, widget.itemData['userId'] ?? 'unknown'], // 참가자 목록
                          'price': '${widget.itemData['price']}원', // 상품 가격
                          'product': widget.itemData['title'] ?? '제목 없음', // 상품 이름
                          'productImage': widget.itemData['image'] ?? '', // 상품 이미지
                          'profileImage': currentUser.photoURL ?? '', // 현재 사용자 프로필 이미지
                          'time': '1주전', // 현재 시간
                          'temperature': '37.2°C', // 더미 데이터
                          'senderId' : '',
                          'isRead' : false,
                          'notReadCount' : 0,
                        }, SetOptions(merge: true)); // 기존 데이터 병합

                        // 채팅 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatRoomId: widget.itemData['title'] ?? '제목 없음', // 채팅방 ID
                              name: widget.itemData['displayName'] ?? '사용자 이름 없음',
                              temperature: '37.2°C',
                              product: widget.itemData['title'] ?? '제목 없음',
                              price: '${widget.itemData['price']}원',
                              productImage: widget.itemData['image'] ?? '',
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

