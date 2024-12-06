import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chatpage.dart';
import 'chatscreen.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _startListeningToUnreadMessages();
  }

  void _startListeningToUnreadMessages() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print("Error: User not logged in.");
      return;
    }

    _firestore
        .collection('chatrooms')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        // senderId가 userId와 같거나 null/빈 문자열인 경우 건너뜀
        if (doc['senderId'] == userId || doc['senderId'] == null || doc['senderId'] == '') {
          continue;
        }

        final List<String> participants = List<String>.from(doc['participants'] as List<dynamic>);
        final List<String> names = List<String>.from(doc['name'] as List<dynamic>);

        // 내 userId가 participants에 없으면 건너뜀
        if (!participants.contains(userId)) continue;

        String? senderName;
        if (participants[0] == userId) {
          senderName = names[1];
        } else {
          senderName = names[0];
        }

        // 기존 알림이 있는지 확인
        _firestore.collection('alarmList').doc(doc.id).get().then((documentSnapshot) {
          if (!documentSnapshot.exists) {
            // 새 알림 추가
            _firestore.collection('alarmList').doc(doc.id).set({
              'time': doc['time'],
              'chatroomId': doc.id,
              'syncedAt': FieldValue.serverTimestamp(),
              'isRead': false,
              'senderName': senderName,
            });
            print('Synced to alarmList: ${doc.id}');
          } else if (documentSnapshot.data()?['isRead'] == true) {
            // 기존 알림을 업데이트하여 다시 활성화
            _firestore.collection('alarmList').doc(doc.id).update({
              'time': doc['time'],
              'syncedAt': FieldValue.serverTimestamp(),
              'isRead': false, // 다시 읽지 않은 상태로 설정
            });
            print('Updated alarm: ${doc.id}');
          } else {
            print('Duplicate alarm skipped: ${doc.id}');
          }
        });
      }
    });
  }




  // alarm 컬렉션에서 데이터를 가져오는 스트림
  Stream<QuerySnapshot> getAlarmStream() {
    return _firestore.collection('alarmList').orderBy('syncedAt', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getAlarmStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('알림이 없습니다.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return NotificationItem(
                icon: Icons.chat,
                title: '${doc['senderName'] ?? '알 수 없는 사용자'} 에게서 온 읽지 않은 메시지',
                time: doc['time'] ?? '시간 정보 없음',
                chatroomId: doc['chatroomId'],
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String chatroomId; // 알림의 chatroomId
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.time,
    required this.chatroomId,
  });

  void _markAsRead(String chatroomId) async {
    try {
      await _firestore
          .collection('alarmList')
          .doc(chatroomId)
          .update({'isRead': true});
      print('Marked as read: $chatroomId');
    } catch (e) {
      print('Error updating isRead: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _markAsRead(chatroomId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(icon, color: Colors.blue),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
