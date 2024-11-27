import 'package:flutter/material.dart';

import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  PageController _pageController = PageController(initialPage: 0);

  bool isLoginSelected = true;
  bool isPasswordVisible = false;
  bool isPasswordConfirmVisible = false;

  TextEditingController studentIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController signupStudentIdController = TextEditingController();
  TextEditingController signupPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String? studentIdError;
  String? passwordError;
  String? signupStudentIdError;
  String? signupPasswordError;
  String? confirmPasswordError;

  void _switchToPage(int page) {
    setState(() {
      isLoginSelected = page == 0;
    });
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _validateLogin() {
    setState(() {
      studentIdError = '존재하지 않는 학번입니다.';
      passwordError = '잘못된 비밀번호입니다.';
    });
  }

  void _validateSignupPassword() {
    setState(() {
      final password = signupPasswordController.text;
      if (password.length < 8 ||
          password.length > 16 ||
          !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$&*~])[A-Za-z\d!@#\$&*~]{8,16}$')
              .hasMatch(password)) {
        signupPasswordError =
        '비밀번호는 영어, 숫자, 특수문자를 포함하여 최소 8자 이상 16자 이하로 구성되어야 합니다.';
      } else {
        signupPasswordError = null;
      }
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      confirmPasswordError = signupPasswordController.text !=
          confirmPasswordController.text
          ? '비밀번호가 일치하지 않습니다.'
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.1), // 최상단 여백 조정
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '한성마켓',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: screenWidth * 0.09,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0E3672),
                            height: 2,
                          ),
                        ),
                        Text(
                          'Hansung',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.08,
                            color: Color(0xBF0E3672),
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Transform.translate(
                      offset: Offset(20, -10), // 오른쪽으로 10, 위로 -10 이동
                      child: Container(
                        alignment: Alignment.topRight,
                        child: Image.asset(
                          'assets/images/image_6.png',
                          width: screenWidth * 0.35, // 크기를 35%로 키움
                          height: screenWidth * 0.35,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'MARKET PLACE',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.09,
                  color: Color(0xFF0E3672),
                  height: 1,
                ),
              ),
              SizedBox(height: screenHeight * 0.03), // 추가 UI 요소와의 간격 조정
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _switchToPage(0),
                    child: Text(
                      '로그인',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: screenWidth * 0.05,
                        color: isLoginSelected
                            ? Color(0xFF0E3672)
                            : Color(0x80000000),
                        decoration: isLoginSelected
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  GestureDetector(
                    onTap: () => _switchToPage(1),
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: screenWidth * 0.05,
                        color: !isLoginSelected
                            ? Color(0xFF0E3672)
                            : Color(0x80000000),
                        decoration: !isLoginSelected
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                height: screenHeight * 0.3,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      isLoginSelected = page == 0;
                    });
                  },
                  children: [
                    _buildLoginForm(screenWidth, screenHeight),
                    _buildSignupForm(screenWidth, screenHeight),
                  ],
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (isLoginSelected) {
                      _validateLogin();
                     // if (studentIdError == null && passwordError == null) { 잠시 기능 구현때문에 꺼놓음
                        //if () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      //}
                    } else {
                      _validateSignupPassword();
                      _validateConfirmPassword();
                      if (signupPasswordError == null && confirmPasswordError == null) {
                        // 회원가입 완료 후 동작 추가
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0E3672),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    isLoginSelected ? '로그인' : '회원가입',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: screenWidth * 0.045,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: studentIdController,
          decoration: InputDecoration(
            labelText: '학번',
            errorText: studentIdError,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        TextField(
          controller: passwordController,
          obscureText: !isPasswordVisible,
          decoration: InputDecoration(
            labelText: '비밀번호',
            errorText: passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: signupStudentIdController,
          decoration: InputDecoration(
            labelText: '학번',
            errorText: signupStudentIdError,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        TextField(
          controller: signupPasswordController,
          obscureText: !isPasswordVisible,
          onChanged: (value) => _validateSignupPassword(),
          decoration: InputDecoration(
            labelText: '비밀번호',
            errorText: signupPasswordError,
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        TextField(
          controller: confirmPasswordController,
          obscureText: !isPasswordConfirmVisible,
          onChanged: (value) => _validateConfirmPassword(),
          decoration: InputDecoration(
            labelText: '비밀번호 확인',
            errorText: confirmPasswordError,
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordConfirmVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  isPasswordConfirmVisible = !isPasswordConfirmVisible;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}