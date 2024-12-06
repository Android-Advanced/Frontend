import 'package:flutter/material.dart';
import './search.dart';
import './notification.dart';
import './post.dart';
import './post_item.dart'; // Import the new file
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './categorysearch.dart';

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
  DateTime? _lastPressedAt;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  List<String> allCategories = [
    '맛집 탐방',
    '전자제품',
    '건강',
    '스포츠',
    '책',
    '운동',
    '중고차',
    '가구',
    '도서',
    '식물',
    '상품권'
  ];
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    searchQuery = widget.searchQuery;
    _fetchItemsFromFirestore();
    _fetchUserCategories();
  }

  Future<void> _fetchItemsFromFirestore() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('items')
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> loadedItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "itemId": doc.id,
          "image": data['image'] ?? '',
          "title": data['title'] ?? '',
          "price": (data['price'] ?? 0).toString(),
          "userId": data['userId'] ?? '',
          "likes": (data['likes'] ?? 0).toString(),
          "description": data['description'] ?? '',
          "displayName": data['displayName'] ?? '',
          "createdAt": data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
              : '',
          "hansungPoint": (data['hansungPoint'] ?? 0).toString(),
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

  Future<void> _fetchUserCategories() async {
    if (userId == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        if (data['categories'] != null) {
          setState(() {
            selectedCategories = List<String>.from(data['categories']);
          });
        }
      }
    } catch (e) {
      print('사용자 카테고리를 가져오는 중 오류 발생: $e');
    }
  }

  void _applyFilter() {
    setState(() {
      if (selectedCategories.isEmpty) {
        // 모든 물품을 표시
        filteredDatas = datas.where((item) =>
            item['title']!.toLowerCase().contains(searchQuery.toLowerCase())
        ).toList();
      } else {
        // 선택된 카테고리에 해당하는 데이터 필터링
        filteredDatas = datas.where((item) {
          final itemCategories = List<String>.from(item['categories'] ?? []);
          return selectedCategories.any((category) => itemCategories.contains(category)) &&
              item['title']!.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _toggleLike(String itemId, int currentLikes) async {
    try {
      final likedItemDoc = FirebaseFirestore.instance.collection('likedItems').doc('${userId}_$itemId');
      final likedSnapshot = await likedItemDoc.get();
      final itemDoc = FirebaseFirestore.instance.collection('items').doc(itemId);

      if (likedSnapshot.exists) {
        await likedItemDoc.delete();
        await itemDoc.update({'likes': currentLikes - 1});
      } else {
        await likedItemDoc.set({
          'userId': userId,
          'itemId': itemId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await itemDoc.update({'likes': currentLikes + 1});
      }

      _fetchItemsFromFirestore();
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
        children: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: _navigateToCategorySelection,
          ),
          Image.asset(
            'assets/images/bugi2_2.png',
            width: 40,
            height: 40,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: selectedCategories.map((category) {
                  final isSelected = selectedCategories.contains(category);
                  return GestureDetector(
                    onTap: () => _filterByCategory(category),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF2657A1) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? Colors.transparent : Colors.black),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            ),
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

  void _filterByCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
      _applyFilter();
    });
  }

  void _navigateToCategorySelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectionScreen(
          allCategories: allCategories,
          selectedCategories: selectedCategories,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedCategories = result;
      });
    }
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
