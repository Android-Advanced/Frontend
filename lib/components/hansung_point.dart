import 'package:flutter/material.dart';

class HansungPoint extends StatelessWidget {
  final double hansungpoint;
  int level = 0;
  final List<Color> pointColors = [
    Color(0xff072038),
    Color(0xff0d3a65),
    Color(0xff186ec0),
    Color(0xff37b24d),
    Color(0xffffad13),
    Color(0xfff76707),
  ];

  HansungPoint({Key? key, required this.hansungpoint}) : super(key: key) {
    _calcTempLevel();
  }

  void _calcTempLevel() {
    if (hansungpoint <= 20) {
      level = 0;
    } else if (hansungpoint > 20 && hansungpoint <= 32) {
      level = 1;
    } else if (hansungpoint > 32 && hansungpoint <= 36.5) {
      level = 2;
    } else if (hansungpoint > 36.5 && hansungpoint <= 40) {
      level = 3;
    } else if (hansungpoint > 40 && hansungpoint <= 50) {
      level = 4;
    } else {
      level = 5;
    }
  }

  Widget _makePointLabelAndBar(BuildContext context) {
    //final double screenWidth = MediaQuery.of(context).size.width; // 화면 너비 가져오기

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${hansungpoint.toStringAsFixed(1)}°C",
          style: TextStyle(
            color: pointColors[level],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8), // 텍스트와 진행 바 사이 간격
        Container(
          height: 6,
          color: Colors.black.withOpacity(0.2), // 배경색 설정
          child: Row(
            children: [
              Container(
                height: 6,
                width: 65/99 *hansungpoint, // 점수에 따라 동적 너비 설정
                color: pointColors[level],
              )
            ],
            ),
          ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "한성부기 님",
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _makePointLabelAndBar(context),
        ],
      ),
    );
  }
}
