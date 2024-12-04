import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: likedItems.length,
      itemBuilder: (context, index) {
        final item = likedItems[index];
        return GestureDetector(
          onTap: () {
            // 상세 페이지로 이동할 로직을 여기에 추가
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
              return Container(); // 상세 페이지로 교체
            }));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  child: Image.network(
                    item['image'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.only(left: 20),
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.favorite, color: Colors.red),
                            const SizedBox(width: 5),
                            Text("${item['likes'] ?? 0}"),
                          ],
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
