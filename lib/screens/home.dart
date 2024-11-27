import 'package:flutter/material.dart';
import './search.dart';
import './notification.dart';
import './post.dart';
import './post_item.dart'; // Import the new file

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
    datas = [
      {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      },
      {
        "image": "assets/images/2.jpg",
        "title": "아이폰 13프로맥스",
        "price": "1300000",
        "likes": "15"
      },
      {
        "image": "assets/images/2.jpg",
        "title": "커피머신",
        "price": "150000",
        "likes": "1"
      },
      {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      },
      {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      }
    ];
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align to the left
        children: [
          Icon(Icons.menu), // Menu icon
          SizedBox(width: 10), // Add spacing
          Image.asset(
            'assets/images/상상부기.jpg',
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
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (BuildContext _context, int index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Post(),
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
