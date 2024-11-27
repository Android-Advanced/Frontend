import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
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
        title: Text(
          '알림',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          NotificationItem(
            icon: Icons.chat,
            title: '요아기 님에게서 온 메시지',
            time: '36.5°H · 1주 전',

          ),
          NotificationItem(
            icon: Icons.person,
            title: '승상훈 님에게서 온 메시지',
            time: '36.5°H · 1주 전',

          ),
          NotificationItem(
            icon: Icons.system_update,
            title: '한성부기님에 대한 리뷰 작성이 완료되었습니다!',
            time: '36.5°H · 1주 전',

          ),
          NotificationItem(
            icon: Icons.system_update,
            title: '신규 가입을 환영합니다',
            time: '36.5°H · 1주 전',

          ),
        ],
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                // 시간 및 온도 정보
                Text(
                  time,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(height: 4),
                // 제목
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                // 메시지 내용

              ],
            ),
          ),
        ],
      ),
    );
  }
}
