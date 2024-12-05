import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './post.dart'; // Post 페이지 import

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  List<Map<String, dynamic>> ongoingItems = [];
  List<Map<String, dynamic>> completedItems = [];

  @override
  void initState() {
    super.initState();
    _fetchMyItems();
  }

  /// `gs://` URL을 HTTP(S) URL로 변환하는 함수
  Future<String> _convertGsUrlToHttp(String gsUrl) async {
    try {
      if (gsUrl.startsWith("gs://")) {
        final ref = FirebaseStorage.instance.refFromURL(gsUrl);
        final downloadUrl = await ref.getDownloadURL();
        print("변환된 URL: $downloadUrl");
        return downloadUrl;
      }
    } catch (e) {
      print("URL 변환 중 오류 발생: $e");
    }
    return gsUrl;
  }

  /// Firestore에서 데이터를 가져오는 함수
  Future<void> _fetchMyItems() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("로그인한 사용자가 없습니다.");
      }

      // Firestore에서 내 상품 가져오기
      final querySnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      List<Map<String, dynamic>> ongoing = [];
      List<Map<String, dynamic>> completed = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        // 이미지 URL 변환
        final imageUrl = await _convertGsUrlToHttp(data["image"] ?? "");

        // 필요한 필드만 명시적으로 추가하고 기본값 설정
        final item = {
          "title": data["title"] ?? "제목 없음",
          "price": data["price"] != null ? data["price"].toString() : "0원",
          "image": imageUrl,
          "buyerId": data["buyerId"] ?? "",
          ...data // Firestore 데이터 유지
        };

        if (item["buyerId"].isEmpty) {
          ongoing.add(item); // 거래 진행 중
        } else {
          completed.add(item); // 거래 완료
        }
      }

      setState(() {
        ongoingItems = ongoing;
        completedItems = completed;
      });
    } catch (e) {
      print("데이터를 가져오는 중 오류 발생: $e");
    }
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: const Text(
        "내가 등록한 상품",
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

  Widget _buildItemList(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Post(itemData: item), // Post로 데이터 전달
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          item["image"],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 80,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["title"],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              "${item["price"]}원",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item["buyerId"].isEmpty ? "거래 중" : "거래 완료",
                        style: TextStyle(
                          color: item["buyerId"].isEmpty ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appbarWidget(),
      body: ongoingItems.isEmpty && completedItems.isEmpty
          ? const Center(
        child: Text("등록된 상품이 없습니다."),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            if (ongoingItems.isNotEmpty) _buildItemList("거래 진행 중", ongoingItems),
            if (completedItems.isNotEmpty) _buildItemList("거래 완료", completedItems),
          ],
        ),
      ),
    );
  }
}
