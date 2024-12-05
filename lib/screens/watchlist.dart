import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './post.dart'; // Post 화면 import

class Watchlist extends StatefulWidget {
  const Watchlist({super.key});

  @override
  _WatchlistState createState() => _WatchlistState();
}

class _WatchlistState extends State<Watchlist> {
  List<Map<String, dynamic>> likedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLikedItems();
  }

  Future<void> _fetchLikedItems() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("로그인된 사용자가 없습니다.");
      }

      final userId = currentUser.uid;

      // 1. likedItems에서 userId로 필터링
      final likedSnapshot = await FirebaseFirestore.instance
          .collection('likedItems')
          .where('userId', isEqualTo: userId)
          .get();

      // 2. items에서 itemId로 게시글 정보 가져오기
      List<Map<String, dynamic>> items = [];
      for (var doc in likedSnapshot.docs) {
        final itemId = doc['itemId'];
        final itemDoc = await FirebaseFirestore.instance.collection('items').doc(itemId).get();

        if (itemDoc.exists) {
          final itemData = itemDoc.data()!;
          String imageUrl = itemData['image'];

          // `gs://` 경로를 다운로드 가능한 URL로 변환
          if (imageUrl.startsWith('gs://')) {
            try {
              final ref = FirebaseStorage.instance.refFromURL(imageUrl);
              imageUrl = await ref.getDownloadURL();
            } catch (e) {
              print("Firebase Storage URL 변환 실패: $e");
            }
          }

          items.add({
            'id': itemDoc.id, // 문서 ID 추가
            ...itemData,
            'image': imageUrl,
          });
        }
      }

      setState(() {
        likedItems = items;
        isLoading = false;
      });
    } catch (e) {
      print("관심 목록을 불러오는 중 오류 발생: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: const Text(
        "관심 목록",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      elevation: 0,
    );
  }

  Widget _bodyWidget() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (likedItems.isEmpty) {
      return const Center(child: Text("관심 목록이 비어있습니다."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemCount: likedItems.length,
      itemBuilder: (context, index) {
        final item = likedItems[index];
        return GestureDetector(
          onTap: () {
            // Post 화면으로 이동하며 선택된 item 데이터 전달
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Post(itemData: item),
              ),
            );
          },
          child: Card(
            color: Colors.white, // 카드 배경색 설정
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Image.network(
                      item['image'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${item['price']}원",
                          style: const TextStyle(
                            color: Color(0xFF0E3672),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.favorite, color: Colors.red, size: 16),
                            const SizedBox(width: 4),
                            Text("${item['likes'] ?? 0}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
