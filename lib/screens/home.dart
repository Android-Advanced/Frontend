import 'package:flutter/material.dart';
import './search.dart';
import './notification.dart';
import './post.dart';
import './post_item.dart'; // Import the new file
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, String>> datas = [];

  @override
  void initState() {
    super.initState();
    _fetchItemsFromFirestore();
  }


  Future<void> _fetchItemsFromFirestore() async {
    try {
      final QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('items').get();

      final List<Map<String, String>> loadedItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "image": (data['image'] ?? '').toString(),
          "title": (data['title'] ?? '').toString(),
          "price": (data['price'] ?? '').toString(),
          "likes": "0", // 기본값
          "description": (data['description'] ?? '').toString(),
          "displayName": (data['displayName'] ?? '').toString(),
          "createdAt": (data['displayName'] ?? '').toString(),
        };
      }).toList();

      setState(() {
        datas = loadedItems;
      });
    } catch (e) {
      print('Firestore 데이터를 불러오는 중 오류 발생: $e');
    }
  }



  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align to the left
        children: [
          Icon(Icons.menu), // Menu icon
          SizedBox(width: 10), // Add spacing
          Image.asset(
            'assets/images/bugi2.png',
            width: 40,
            height: 40,
          ), // Add image
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Search()),
            );
          },
          icon: Icon(Icons.search),
        ),
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
    return RefreshIndicator(
      onRefresh: _fetchItemsFromFirestore, // 새로고침 시 호출될 함수
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (BuildContext _context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Post(
                    itemData: datas[index], // 선택된 데이터를 전달

                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Image.asset(
                      datas[index]["image"]!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error, size: 50); // 이미지 로드 실패 시 아이콘 표시
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(datas[index]["title"]!),
                          Text(
                            datas[index]["price"]! + "원",
                            style: TextStyle(
                              color: Color(0xFF0E3672),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Icon(Icons.favorite, color: Colors.red),
                                SizedBox(width: 5),
                                Text(datas[index]["likes"]!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: datas.length,
        separatorBuilder: (BuildContext _context, int index) {
          return Container(
            height: 1,
            color: Colors.black,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostItemScreen()),
          );
        },
        backgroundColor: Color(0xFF0E3672),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
