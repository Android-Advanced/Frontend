import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './post.dart';

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

    final transactions = await Future.wait(querySnapshot.docs.map((doc) async {
      final data = doc.data();
      final isSeller = data['userId'] == userId;
      final isBuyer = data['buyerId'] == userId;

      // 판매 완료와 구매 완료만 포함
      final isRelevant = (isSeller && (data['buyerId']?.isNotEmpty ?? false)) || isBuyer;

      if (!isRelevant) return null; // 관련 없는 항목은 제외

      // 이미지 URL 변환
      final resolvedImageUrl = await _getDownloadUrl(data['image'] ?? '');

      // 거래 상태 결정
      final status = isSeller
          ? '판매 완료'
          : isBuyer
          ? '구매 완료'
          : '';

      return {
        ...data, // Firestore에서 가져온 모든 데이터를 포함
        'imageUrl': resolvedImageUrl,
        'status': status,
      };
    }).toList());

    // null을 제외한 리스트 반환
    return transactions.where((transaction) => transaction != null).toList().cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '나의 거래내역',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
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
                price: transaction['price']!.toString(),
                status: transaction['status']!,
                itemData: transaction, // 전체 데이터를 전달
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
  final Map<String, dynamic> itemData;

  const TransactionItem({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.status,
    required this.itemData,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Post(itemData: itemData), // 모든 데이터를 전달
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
      ),
    );
  }
}
