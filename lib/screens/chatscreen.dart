import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String title; // 대화 상대 이름
  final String temperature; // 온도
  final String product; // 상품 정보
  final String price; // 상품 가격
  final String productImage; // 상품 이미지

  ChatScreen({
    required this.title,
    required this.temperature,
    required this.product,
    required this.price,
    required this.productImage,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> messages = [
    {'isMe': false, 'message': '사실건가요?', 'time': '오후 8:32'},
    {'isMe': true, 'message': '알아서 할게요', 'time': '오후 8:42'},
    {'isMe': false, 'message': '시험 힘들어', 'time': '오후 8:55'},
    {'isMe': true, 'message': '알아서 할게요', 'time': '오후 8:42'},
    {'isMe': false, 'message': '시험 힘들어', 'time': '오후 8:55'},
  ];

  TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add({
          'isMe': true,
          'message': _messageController.text,
          'time': '오후 9:00', // 실제 프로젝트에서는 현재 시간 사용
        });
        _messageController.clear();
      });
    }
  }

  void _handleMenuItem(String value) {
    if (value == 'exit') {
      // "채팅방 나가기" 경고 다이얼로그
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('경고'),
          content: Text('채팅방에서 나가면 기록이 삭제됩니다. 정말 나가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 채팅방 나가기
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    } else if (value == 'complete') {
      // "거래 완료하기" 경고 다이얼로그
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('경고'),
          content: Text('거래 완료 확인 시, 거래가 정상적으로 종료됩니다. 거래가 완료되었습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('거래가 완료되었습니다.')),
                );
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // 제목 중앙 정렬
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min, // 중앙에 배치되도록 설정
          children: [
            Text(
              widget.title,
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
            onSelected: _handleMenuItem,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'exit',
                child: Text('채팅방 나가기'),
              ),
              PopupMenuItem(
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
                          SizedBox(width: 8), // "판매중"과 상품명 사이 간격
                          Expanded(
                            child: Text(
                              widget.product,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis, // 긴 텍스트 처리
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
            child: ListView.builder(
              itemCount: messages.length,
              reverse: false,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: message['isMe']
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!message['isMe']) ...[
                        CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 16),
                        ),
                        SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth: screenWidth * 0.6),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: message['isMe']
                                ? Color(0xFFe8f0fe)
                                : Color(0xFFF1F1F1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomLeft: message['isMe']
                                  ? Radius.circular(12)
                                  : Radius.circular(0),
                              bottomRight: message['isMe']
                                  ? Radius.circular(0)
                                  : Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: message['isMe']
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['message'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                message['time'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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