import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'transaction_review.dart';
import 'watchlist.dart';
import '../components/hansung_point.dart';
import 'editprofile.dart';
import 'home.dart';
import 'my_product.dart';
import './item_history.dart';
import './notification.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String displayName = "사용자 이름";
  double hansungPoint = 0.0;
  String profileImage = "";
  bool isLoading = true;
  int likedItemsCount = 0; // 관심 목록 게시글 수

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchLikedItemsCount(); // 좋아요한 게시글 수 가져오기
  }

  Future<void> _fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        displayName = data['displayName'] ?? "사용자 이름";
        hansungPoint = data['hansungPoint'] ?? 0.0;
        profileImage = data['profileImage'] ?? "";

        // Firebase Storage URL 변환
        if (profileImage.startsWith('gs://')) {
          FirebaseStorage.instance
              .refFromURL(profileImage)
              .getDownloadURL()
              .then((url) {
            setState(() {
              profileImage = url;
            });
          });
        }

        isLoading = false;
      });
    }
  }

  Future<void> _fetchLikedItemsCount() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Firestore에서 likedItems 컬렉션에서 현재 사용자의 좋아요 게시글 수 가져오기
      final querySnapshot = await FirebaseFirestore.instance
          .collection('likedItems')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      setState(() {
        likedItemsCount = querySnapshot.docs.length;
      });
    }
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Left-align
        children: [
          Image.asset(
            'assets/images/bugi2.png', // Adjust the path to your image
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationScreen()),
            );
          },
          icon: Icon(Icons.notifications),
        ),
      ],
    );
  }

  Widget _bodyWidget() {
    final List<Map<String, dynamic>> profileOptions = [
      {"icon": Icons.favorite_border, "title": "관심 목록", "trailing": "($likedItemsCount)"},
      {"icon": Icons.shopping_bag_outlined, "title": "내가 등록한 상품"},
      {"icon": Icons.inventory_2_outlined, "title": "거래 내역"},
      {"icon": Icons.category_outlined, "title": "관심 카테고리"},
      {"icon": Icons.star_border, "title": "거래 후기"},
    ];

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

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
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : AssetImage('assets/images/user_profile.jpg')
                  as ImageProvider,
                  child: profileImage.isEmpty
                      ? Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  )
                      : null,
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HansungPoint(
                      displayName: displayName,
                      hansungPoint: hansungPoint,
                    ),
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
                    ).then((_) => _fetchUserData()); // Refresh data after editing
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
      backgroundColor: Colors.white,
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}
