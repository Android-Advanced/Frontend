import 'package:flutter/material.dart';
import 'transaction_review.dart';
import 'watchlist.dart';
import 'package:mobile_p/components/hansung_point.dart';
import 'editprofile.dart';
import 'home.dart';
import 'my_product.dart';
import './item_history.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Left-align
        children: [
          Image.asset(
            'assets/images/상상부기.jpg', // Adjust the path to your image
            width: 40,
            height: 40,
          ),
          SizedBox(width: 10), // Space between icon and text
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
    final List<Map<String, dynamic>> profileOptions = [
      {"icon": Icons.favorite_border, "title": "관심 목록", "trailing": "(6)"},
      {"icon": Icons.shopping_bag_outlined, "title": "내가 등록한 상품"},
      {"icon": Icons.inventory_2_outlined, "title": "거래 내역"},
      {"icon": Icons.category_outlined, "title": "관심 카테고리"},
      {"icon": Icons.star_border, "title": "거래 후기"},
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),

          // Profile Header with Image and Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: AssetImage('assets/images/user_profile.jpg'),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HansungPoint(hansungpoint: 35.0), // 점수 전달
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Divider(),

          // Profile Options
          ...profileOptions.map((option) {
            return Column(
              children: [
                _profileOption(
                  option['icon'],
                  option['title'],
                  trailing: option['trailing'],
                  onTap: () {
                    switch (option['title']) {
                      case "관심 카테고리":
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                        break;
                      case "거래 내역":
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ItemHistoryScreen()),
                        );
                        break;
                      case "내가 등록한 상품":
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Product()),
                        );
                        break;
                      case "거래 후기":
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReviewPage()),
                        );
                        break;
                      case "관심 목록":
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Watchlist()),
                        );
                        break;
                      default:
                        print("Unknown option tapped");
                    }
                  },
                ),
                Divider(),
              ],
            );
          }).toList(),

          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(right: 20), // Add space from the right edge
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Aligns the button to the end
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2657A1), // Button color (blue)
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Rounded corners
                    ),
                  ),
                  child: Text(
                    "정보변경",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
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
                  color: Color(0xFF2657A1),
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
