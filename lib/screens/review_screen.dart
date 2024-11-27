import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _currentTemperature = 3.0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0), // AppBar 높이를 조정
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 16.0), // 아이콘 아래로 여백 추가
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 16.0), // 제목 아래로 여백 추가
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
            SizedBox(height: 20), // AppBar 아래로 추가 여백
            Text(
              'user2님,\nuser1님과의 거래가 어떠셨나요?',
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
                    "${(36.5 + (_currentTemperature - 3) * 0.5).toStringAsFixed(1)}°H",
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
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("후기 작성 완료"),
                        content: Text("후기 작성을 완료하시겠습니까?"),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFF0E3672),
                              side: BorderSide(color: Color(0xFF0E3672)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text("예", style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("후기가 제출되었습니다.")),
                              );
                            },
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              side: BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text("아니오", style: TextStyle(color: Colors.black)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
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
