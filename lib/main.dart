import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // LoginScreen이 있는 파일 경로
import 'screens/review_screen.dart'; // ReviewScreen이 있는 파일 경로

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Zone 초기화
  runApp(HansungMarketApp());
}

class HansungMarketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(), // 초기 화면을 LoginScreen으로 설정
    );
  }
}
