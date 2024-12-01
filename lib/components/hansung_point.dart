import 'package:flutter/material.dart';

class HansungPoint extends StatelessWidget {
  final String displayName; // 유저 이름
  final double hansungPoint; // 한성포인트
  int level = 0;

  // 점수에 따른 색상
  final List<Color> pointColors = [
    Color(0xff072038),
    Color(0xff0d3a65),
    Color(0xff186ec0),
    Color(0xff37b24d),
    Color(0xffffad13),
    Color(0xfff76707),
  ];

  // 생성자에 필요한 매개변수 추가
  HansungPoint({
    Key? key,
    required this.displayName,
    required this.hansungPoint,
  }) : super(key: key) {
    _calcTempLevel();
  }

  // 한성포인트에 따른 레벨 계산
  void _calcTempLevel() {
    if (hansungPoint <= 20) {
      level = 0;
    } else if (hansungPoint > 20 && hansungPoint <= 32) {
      level = 1;
    } else if (hansungPoint > 32 && hansungPoint <= 36.5) {
      level = 2;
    } else if (hansungPoint > 36.5 && hansungPoint <= 40) {
      level = 3;
    } else if (hansungPoint > 40 && hansungPoint <= 50) {
      level = 4;
    } else {
      level = 5;
    }
  }

  // UI 컴포넌트 생성
  Widget _makePointLabelAndBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${hansungPoint.toStringAsFixed(1)}°C",
          style: TextStyle(
            color: pointColors[level],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 6,
          color: Colors.black.withOpacity(0.2),
          child: Row(
            children: [
              Container(
                height: 6,
                width: 65 / 99 * hansungPoint, // 점수에 따른 진행 바 너비
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
            "$displayName 님",
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
