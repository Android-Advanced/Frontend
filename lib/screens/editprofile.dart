import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // List of interest categories
  final List<String> categories = [
    "맛집 탐방", "전자제품", "건강", "스포츠", "책", "운동", "중고차", "가구", "도서", "식물", "상품권"
  ];

  // Currently selected categories
  final Set<String> selectedCategories = {"전자제품", "도서"};

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          Text(
            "정보 변경",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications),
        ),
      ],
    );
  }

  Widget _profilePictureSection() {
    return Stack(
      alignment: Alignment.center, // Ensures the avatar stays centered
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          right: 0, // Adjust this value to control distance from the right edge
          child: ElevatedButton(
            onPressed: () {
              // Add photo change functionality here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2657A1),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              "사진 변경",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField(String initialValue, bool obscureText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          controller: TextEditingController(text: initialValue),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _categoryChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((category) {
        final isSelected = selectedCategories.contains(category);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedCategories.remove(category);
              } else {
                selectedCategories.add(category);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF2657A1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }




  Widget _bodyWidget() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profilePictureSection(),
          SizedBox(height: 20),
          Text(
            "이름",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          _textField("한성부기", false),
          _textField("********", true),
          Text(
            "관심 카테고리",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 10),
          _categoryChips(),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
            onPressed: () {
            // Add save functionality here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2657A1),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                    ),
            ),
            child: Text(
                    "저장 하기",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
              ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget()
    );
  }
}