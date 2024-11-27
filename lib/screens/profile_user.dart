import 'package:flutter/material.dart';

class ProfileUser extends StatefulWidget {
  const ProfileUser({super.key});

  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {

PreferredSizeWidget _appbarWidget() {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.start, // 좌측 정렬
      children: [
        SizedBox(width: 10), // 간격 추가
        Image.asset(
          'assets/images/상상부기.jpg',
          width: 40,
          height: 40,
        ),
        SizedBox(width: 10), // 이미지와 텍스트 간격
        Text(
          "프로필",
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
        icon: Icon(Icons.notifications, color: Colors.black),
      ),
    ],
  );
}

Widget _bodyWidget() {
  // Define list of profile options
  final List<Map<String, dynamic>> profileOptions = [
    {"icon": Icons.category, "title": "관심 카테고리"},
    {"icon": Icons.inventory, "title": "거래 내역", "trailing": "5 건"},
    {"icon": Icons.shopping_bag, "title": "내가 등록한 상품", "trailing": "10 건"},
    {"icon": Icons.star, "title": "거래 후기"},
  ];

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: 60,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "한성부기 님",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        SizedBox(height: 20),
        Divider(),

        // Use ListView.builder to iterate over profileOptions list
        ...profileOptions.map((option) {
          return Column(
            children: [
              _profileOption(
                option['icon'],
                option['title'],
                trailing: option['trailing'],
                onTap: () {
                  // Implement the onTap action for each option here
                  print("${option['title']} tapped");
                },
              ),
              Divider(),
            ],
          );
        }).toList(),
      ],
    ),
  );
}

Widget _profileOption(IconData icon, String title,
    {String? trailing, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF2657A1)),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}
