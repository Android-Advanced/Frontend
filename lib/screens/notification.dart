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
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      print("Error: User not logged in.");
      return;
    }

    // 읽지 않은 메시지 가져오기
    _firestore
        .collection('chatrooms')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        final List<dynamic> participants = doc['participants'];
        final senderId = doc['senderId'];

        if (participants.length != 2 || senderId == null || senderId == '') continue;

        final String userId = participants[0] == senderId
            ? participants[1]
            : participants[0];
        if (userId == senderId) continue;

        // Firestore에서 senderId의 displayName 가져오기
        _firestore
            .collection('users')
            .doc(senderId)
            .get()
            .then((userDoc) {
          final displayName = userDoc.data()?['displayName'] ?? '알 수 없는 사용자';

          // 중복 방지: doc(chatroomId) 사용
          _firestore.collection('alarmList').doc(doc.id).set({
            'time': doc['time'],               // 메시지 시간
            'chatroomId': doc.id,             // 채팅방 ID
            'senderId': senderId,             // 보낸 사람 ID
            'userId': userId,                 // 수신자 ID
            'senderName': displayName,        // Firestore에서 가져온 displayName
            'syncedAt': FieldValue.serverTimestamp(),
            'isRead': false,                  // 읽지 않은 상태로 저장
          }, SetOptions(merge: true)).then((_) {
            print('New or updated alarm set for chatroom: ${doc.id}');
          }).catchError((error) {
            print('Error setting new alarm: $error');
          });
        }).catchError((error) {
          print('Error fetching user displayName: $error');
        });
      }
    });
  }








  // alarm 컬렉션에서 데이터를 가져오는 스트림
  Stream<QuerySnapshot> getAlarmStream() {
    final String? currentId = FirebaseAuth.instance.currentUser?.uid;

    if (currentId == null) {
      print("Error: User not logged in.");
      return const Stream.empty();
    }

    return _firestore
        .collection('alarmList')
        .where('userId',isEqualTo: currentId)
        .snapshots();
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

  void _deleteNotification(String chatroomId) async {
    try {
      // chatroomId에 해당하는 문서 삭제
      await _firestore
          .collection('alarmList')
          .where('chatroomId', isEqualTo: chatroomId)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          _firestore.collection('alarmList').doc(doc.id).delete();
        }
      });
      print('Deleted notification for chatroom: $chatroomId');
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

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
        _deleteNotification(chatroomId);
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
