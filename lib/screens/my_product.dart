import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  Future<String> _convertGsUrlToHttp(String gsUrl) async {
    try {
      if (gsUrl.startsWith("gs://")) {
        final ref = FirebaseStorage.instance.refFromURL(gsUrl);
        return await ref.getDownloadURL();
      }
      return gsUrl; // 이미 HTTP URL인 경우 그대로 반환
    } catch (e) {
      print("이미지 URL 변환 오류: $e");
      return ""; // 오류 발생 시 빈 문자열 반환
    }
  }

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
        final imageUrl = await _convertGsUrlToHttp(data["image"] ?? "");
        final item = {
          "title": data["title"],
          "price": data["price"].toString(),
          "image": imageUrl,
          "buyerId": data["buyerId"] ?? "",
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
      title: Text(
        "내가 등록한 상품",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => Divider(),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  item["image"],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                ),
              ),
              title: Text(item["title"]),
              subtitle: Text("${item["price"]}원"),
              trailing: item["buyerId"].isEmpty
                  ? Text(
                "거래 중",
                style: TextStyle(color: Colors.orange),
              )
                  : Text(
                "거래 완료",
                style: TextStyle(color: Colors.green),
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
          ? Center(
        child: Text("등록된 상품이 없습니다."),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            if (ongoingItems.isNotEmpty)
              _buildItemList("거래 진행 중", ongoingItems),
            if (completedItems.isNotEmpty)
              _buildItemList("거래 완료", completedItems),
          ],
        ),
      ),
    );
  }
}
