import 'package:firebase_auth/firebase_auth.dart';
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

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController signupEmailController = TextEditingController();
  TextEditingController signupPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String? emailError;
  String? passwordError;
  String? signupEmailError;
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

  /// Firebase 회원가입 메서드
  Future<void> _signupWithEmailPassword() async {
    try {
      final auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: signupEmailController.text.trim(),
        password: signupPasswordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입이 완료되었습니다. 이메일 인증 메일을 확인해주세요.')),
        );
      }
      _switchToPage(0); // 로그인 페이지로 이동
    } catch (e) {
      setState(() {
        signupEmailError = '회원가입에 실패했습니다. 이메일 또는 비밀번호를 확인해주세요.';
      });
    }
  }

  /// Firebase 로그인 메서드
  Future<void> _loginWithEmailPassword() async {
    try {
      final auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        if (user.emailVerified) {
          // 인증된 사용자
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          // 이메일 인증 필요
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이메일 인증이 필요합니다. 이메일을 확인해주세요.')),
          );
          await auth.signOut(); // 인증되지 않은 사용자 로그아웃 처리
        }
      }
    } catch (e) {
      setState(() {
        emailError = '로그인에 실패했습니다. 이메일 또는 비밀번호를 확인해주세요.';
      });
    }
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
              SizedBox(height: screenHeight * 0.1),
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
                      offset: Offset(20, -10),
                      child: Container(
                        alignment: Alignment.topRight,
                        child: Image.asset(
                          'assets/images/image_6.png',
                          width: screenWidth * 0.35,
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
              SizedBox(height: screenHeight * 0.03),
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
                      // 로그인 버튼 클릭 시
                      _loginWithEmailPassword();
                    } else {
                      // 회원가입 버튼 클릭 시
                      _validateSignupPassword();
                      _validateConfirmPassword();
                      if (signupPasswordError == null && confirmPasswordError == null) {
                        _signupWithEmailPassword();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('회원등록이 완료되었습니다. 이메일 인증 메일을 확인해주세요.')),
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
          controller: emailController,
          decoration: InputDecoration(
            labelText: '학교 이메일',
            errorText: emailError,
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
          controller: signupEmailController,
          decoration: InputDecoration(
            labelText: '학교 이메일',
            errorText: signupEmailError,
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
