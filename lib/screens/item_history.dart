import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ItemHistoryScreen extends StatelessWidget {
  const ItemHistoryScreen({Key? key}) : super(key: key);

  // Firebase Storage URL 변환 함수
  Future<String> _getDownloadUrl(String imageUrl) async {
    if (imageUrl.startsWith('gs://')) {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      return await ref.getDownloadURL();
    }
    return imageUrl; // HTTP(S) URL은 그대로 반환
  }

  Future<List<Map<String, dynamic>>> _fetchTransactionHistory() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    final userId = currentUser.uid;

    // Firestore에서 판매/구매 내역 가져오기
    final querySnapshot = await FirebaseFirestore.instance.collection('items').get();

    // 판매/구매 완료 항목 분류
    final transactions = await Future.wait(querySnapshot.docs.map((doc) async {
      final data = doc.data();
      final isSeller = data['userId'] == userId;
      final isBuyer = data['buyerId'] == userId;
      final status = isSeller
          ? '판매 완료'
          : isBuyer
          ? '구매 완료'
          : '진행 중';

      // 이미지 URL 변환
      final resolvedImageUrl = await _getDownloadUrl(data['image'] ?? '');

      return {
        'imageUrl': resolvedImageUrl,
        'title': data['title'] ?? '상품명 없음',
        'price': '${data['price'] ?? 0}원',
        'status': status,
        'isRelevant': isSeller || isBuyer,
      };
    }).toList());

    // 판매/구매와 관련된 항목만 반환
    return transactions.where((transaction) => transaction['isRelevant']).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '나의 거래내역',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTransactionHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('거래내역을 불러오는 중 오류가 발생했습니다: ${snapshot.error}'),
            );
          }

          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return const Center(child: Text('거래내역이 없습니다.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return TransactionItem(
                imageUrl: transaction['imageUrl']!,
                title: transaction['title']!,
                price: transaction['price']!,
                status: transaction['status']!,
              );
            },
          );
        },
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String status;

  const TransactionItem({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 표시 (Firebase Storage의 다운로드 URL 사용)
            Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ],
              ),
            ),
            Text(
              status,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
