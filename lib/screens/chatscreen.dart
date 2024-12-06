import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_p/screens/review_screen.dart';
import 'package:visibility_detector/visibility_detector.dart';
class ChatScreen extends StatefulWidget {
  final String chatRoomId; // Firestore 채팅방 ID
  final String name; // 대화 상대 이름
  final String temperature; // 온도
  final String product; // 상품 정보
  final String price; // 상품 가격
  final String productImage; // 상품 이미지

  ChatScreen({
    required this.chatRoomId,
    required this.name,
    required this.temperature,
    required this.product,
    required this.price,
    required this.productImage,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Firestore에서 메시지를 가져오는 스트림
  Stream<QuerySnapshot> getChatMessages() {
    return _firestore
        .collection('chatrooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
  void _completeTransaction() async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('거래 완료하기'),
        content: Text('이 거래를 완료 처리하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('완료'),
          ),
        ],
      ),
    );

    if (confirmation == true) {

      // 거래 완료 후 리뷰 요청 팝업 표시
      final reviewConfirmation = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('거래 리뷰 작성'),
          content: Text('거래 리뷰를 작성하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // "아니오"
              child: Text('아니오'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // "네"
              child: Text('네'),
            ),
          ],
        ),
      );

      // "네"를 선택하면 리뷰 작성 화면으로 이동
      if (reviewConfirmation == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewScreen(
              chatRoomId: widget.chatRoomId, // productImage 전달
            ), // 리뷰 작성 화면

          ),
        );
      }
    }
  }


  void _leaveChatRoom() async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('채팅방 나가기'),
        content: Text('정말로 이 채팅방을 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('나가기'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      final chatRoomRef = _firestore.collection('chatrooms').doc(widget.chatRoomId);

      // Firestore 트랜잭션을 사용하여 participants 필드 업데이트
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(chatRoomRef);
        if (!snapshot.exists) return;

        // participants 배열 가져오기
        final participants = List<String>.from(snapshot['participants'] ?? []);
        final currentUserId = _auth.currentUser?.uid;

        if (currentUserId != null && participants.contains(currentUserId)) {
          // 현재 사용자의 값을 "out"으로 변경
          final updatedParticipants = participants.map((participant) {
            return participant == currentUserId ? "out" : participant;
          }).toList();

          // Firestore에 업데이트
          transaction.update(chatRoomRef, {'participants': updatedParticipants});
        }
      });

      Navigator.pop(context); // 이전 화면으로 돌아감
    }
  }


  // Firestore에 메시지 추가
  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;
      final String messageText = _messageController.text.trim();
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      String profileImageUrl = '';
      if (userDoc.exists) {
        profileImageUrl = userDoc.data()?['profileImage'] ?? ''; // users 컬렉션에서 profileImage 필드 가져오기
      }

      final messageDoc = await _firestore
          .collection('chatrooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add({
        'message':messageText,
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead' : false,
        'imageUrl':"",
        'profileImageUrl' : profileImageUrl,
      });
      await _firestore
          .collection('chatrooms')
          .doc(widget.chatRoomId)
          .update({
        'message': messageText, // 마지막 메시지 내용
        'senderId' : currentUser.uid,
        'isRead' : false,
        'notReadCount': FieldValue.increment(1),
        'lastMessageTimeStamp' :  FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }
  }
  //메시지 읽음 처리
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatRoomId)
          .update({
        'isRead': true,
        'notReadCount': 0,
      });
    } catch (e) {
      print("Error marking message as read: $e");
    }
  }
  // 이미지 선택 및 전송
  Future<void> _sendImage() async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      File file = File(pickedFile.path);
      String fileName =
          'chat_images/${DateTime.now().millisecondsSinceEpoch}_${_auth.currentUser?.uid}.jpg';
      final storageRef = _storage.ref().child(fileName);

      await storageRef.putFile(file);

      String imageUrl = await storageRef.getDownloadURL();

      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('chatrooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add({
        'imageUrl': imageUrl,
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'message':'',
      });

      await _firestore.collection('chatrooms').doc(widget.chatRoomId).update({
        'message': '사진을 보냈습니다.',
        'senderId': currentUser.uid,
        'isRead': false,
        'notReadCount': FieldValue.increment(1),
      });

      print("Image sent successfully");
    } catch (e) {
      print("Error sending image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.name,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Text(
              widget.temperature,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (String result) {
              if (result == 'leave') {
                _leaveChatRoom();
              } else if (result == 'complete') {
                _completeTransaction();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'leave',
                child: Text('채팅방 나가기'),
              ),
              PopupMenuItem<String>(
                value: 'complete',
                child: Text('거래 완료하기'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 상품 정보 섹션
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  widget.productImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '판매중',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.product,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.price,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 메시지 리스트 섹션
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getChatMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  reverse: false,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == _auth.currentUser?.uid;




                    return VisibilityDetector(
                      key: Key(message.id),
                      onVisibilityChanged: (visibilityInfo) {
                        if (visibilityInfo.visibleFraction > 0.5 && !isMe && !(message['isRead'] ?? false)) {
                          // 메시지가 화면에서 50% 이상 보일 때 읽음 처리
                          markMessageAsRead(message.id);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: message['profileImageUrl'] != null &&
                                    message['profileImageUrl'].isNotEmpty
                                    ? NetworkImage(message['profileImageUrl'])
                                    : null,
                                child: message['profileImageUrl'] == null ||
                                    message['profileImageUrl'].isEmpty
                                    ? Icon(Icons.person, size: 16)
                                    : null,
                              ),
                              SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isMe ? Color(0xFFe8f0fe) : Color(0xFFF1F1F1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    if (message['imageUrl'] != null &&
                                        message['imageUrl'].toString().isNotEmpty)
                                      Image.network(message['imageUrl']),
                                    if (message['message'] != null &&
                                        message['message'].toString().isNotEmpty)
                                      Text(
                                        message['message'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    SizedBox(height: 5),
                                    Text(
                                      message['timestamp'] != null
                                          ? DateFormat('yyyy-MM-dd HH:mm') // 원하는 날짜/시간 형식
                                          .format((message['timestamp'] as Timestamp).toDate())
                                          : '시간 정보 없음', // 값이 없을 때 표시
                                      style: TextStyle(
                                        fontSize: 12, // 약간 더 큰 폰트
                                        color: Colors.grey.shade700, // 더 잘 보이는 중간 밝기의 색상
                                        fontWeight: FontWeight.w500, // 가독성을 위한 약간 두꺼운 글꼴
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // 메시지 입력창 섹션
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo, color: Colors.grey),
                  onPressed: _sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '메시지 보내기',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Color(0xFF0E3672),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
