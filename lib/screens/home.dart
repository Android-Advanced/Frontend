import 'package:flutter/material.dart';
import './search.dart';
import './notification.dart';
import './post.dart';
import './post_item.dart'; // Import the new file
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  final String searchQuery;

  const Home({super.key, this.searchQuery = ""});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> datas = [];
  List<Map<String, dynamic>> filteredDatas = [];
  String searchQuery = "";
  DateTime? _lastPressedAt; // 마지막으로 뒤로 가기 버튼을 누른 시간
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

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

      final List<Map<String, dynamic>> loadedItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "itemId": doc.id, // Firestore 문서 ID를 itemId로 포함
          "image": data['image'] ?? '',
          "title": data['title'] ?? '',
          "price": (data['price'] ?? 0).toString(), // int를 String으로 변환
          "userId": data['userId'] ?? '',
          "likes": (data['likes'] ?? 0).toString(), // int를 String으로 변환
          "description": data['description'] ?? '',
          "displayName": data['displayName'] ?? '',
          "createdAt": data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
              : '',
          "hansungPoint": (data['hansungPoint'] ?? 0).toString(), // int를 String으로 변환
          "categories": data['categories'] ?? '',
          "buyerId": data['buyerId'] ?? '',
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
          .where((item) => item['title']!.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  Future<void> _toggleLike(String itemId, int currentLikes) async {
    try {
      final likedItemDoc = FirebaseFirestore.instance.collection('likedItems').doc('${userId}_$itemId');
      final likedSnapshot = await likedItemDoc.get();
      final itemDoc = FirebaseFirestore.instance.collection('items').doc(itemId);

      if (likedSnapshot.exists) {
        // 관심목록에서 제거
        await likedItemDoc.delete();
        await itemDoc.update({'likes': currentLikes - 1});
      } else {
        // 관심목록에 추가
        await likedItemDoc.set({
          'userId': userId,
          'itemId': itemId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await itemDoc.update({'likes': currentLikes + 1});
      }

      _fetchItemsFromFirestore(); // UI 업데이트
    } catch (e) {
      print('좋아요 상태 업데이트 중 오류 발생: $e');
    }
  }

  Future<bool> _isLiked(String itemId) async {
    final likedItemDoc = FirebaseFirestore.instance.collection('likedItems').doc('${userId}_$itemId');
    final likedSnapshot = await likedItemDoc.get();
    return likedSnapshot.exists;
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      backgroundColor: Colors.white,
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
          final item = filteredDatas[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Post(itemData: item),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item["image"]!,
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
                          Text(item["title"]!),
                          Text(
                            '${item["price"]}원',
                            style: TextStyle(color: Color(0xFF0E3672)),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FutureBuilder<bool>(
                                  future: _isLiked(item["itemId"]),
                                  builder: (context, snapshot) {
                                    final isLiked = snapshot.data ?? false;
                                    return IconButton(
                                      icon: Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _toggleLike(item["itemId"], int.parse(item["likes"] ?? '0')),
                                    );
                                  },
                                ),
                                SizedBox(width: 5),
                                Text(item["likes"]!),
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
          return Divider(color: Colors.black);
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
        backgroundColor: Colors.white,
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
