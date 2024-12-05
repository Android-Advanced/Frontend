import 'package:flutter/material.dart';
import './search.dart';
import './notification.dart';
import './post.dart';
import './post_item.dart'; // Import the new file
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  final String searchQuery;

  const Home({super.key, this.searchQuery = ""});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, String>> datas = [];
  List<Map<String, String>> filteredDatas = [];
  String searchQuery = "";
  DateTime? _lastPressedAt; // 마지막으로 뒤로 가기 버튼을 누른 시간

  @override
  void initState() {
    super.initState();
    searchQuery = widget.searchQuery; // 검색어 초기화
    _fetchItemsFromFirestore();
  }

  Future<void> _fetchItemsFromFirestore() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('items')
          .orderBy('createdAt', descending: true) // 최신 순으로 정렬
          .get();

      final List<Map<String, String>> loadedItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "image": (data['image'] ?? '').toString(),
          "title": (data['title'] ?? '').toString(),
          "price": (data['price'] ?? '').toString(),
          "userId": (data['userId'] ?? '').toString(),
          "likes": (data['likes'] ?? '').toString(),
          "description": (data['description'] ?? '').toString(),
          "displayName": (data['displayName'] ?? '').toString(),
          "createdAt": data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
              : '',
          "hansungPoint": (data['hansungPoint'] ?? '').toString(),
          "categories": (data['categories'] ?? '').toString(),
          "buyerId": (data['buyerId'] ?? '').toString(),
        };
      }).toList();

      setState(() {
        datas = loadedItems;
        _applyFilter();
      });
    } catch (e) {
      print('Firestore 데이터를 불러오는 중 오류 발생: $e');
    }
  }

  void _applyFilter() {
    setState(() {
      filteredDatas = searchQuery.isEmpty
          ? datas
          : datas
          .where((item) =>
          item['title']!.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.menu),
          SizedBox(width: 10),
          Image.asset(
            'assets/images/bugi2_2.png',
            width: 40,
            height: 40,
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Search()),
            );

            if (result != null) {
              setState(() {
                searchQuery = result;
                _applyFilter();
              });
            }
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
      onRefresh: _fetchItemsFromFirestore,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (BuildContext _context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Post(
                    itemData: filteredDatas[index],
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
                    child: Image.network(
                      filteredDatas[index]["image"]!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error, size: 50);
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
                          Text(filteredDatas[index]["title"]!),
                          Text(
                            filteredDatas[index]["price"]! + "원",
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
                                Text(filteredDatas[index]["likes"]!),
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
        itemCount: filteredDatas.length,
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
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('뒤로 가기 버튼을 한 번 더 누르시면 앱이 종료됩니다.'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
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
      ),
    );
  }
}
