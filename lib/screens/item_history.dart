import 'package:flutter/material.dart';

class ItemHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '나의 거래내역',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TransactionItem(
              imageUrl: 'https://image.made-in-china.com/202f0j00gCoYVfNWalqT/Newly-Spot-Mobile-Phone-M90-Water-Drop-Large-Screen-Fingerprint-Smartphone.webp',
              title: '아이폰 11 프로맥스',
              price: '800,000원',
              status: '판매 완료',
            ),
            TransactionItem(
              imageUrl: 'https://image.made-in-china.com/202f0j00gCoYVfNWalqT/Newly-Spot-Mobile-Phone-M90-Water-Drop-Large-Screen-Fingerprint-Smartphone.webp',
              title: '갤럭시 버즈 3 프로 팔아요!',
              price: '280,000원',
              status: '판매 완료',
            ),
            TransactionItem(
              imageUrl: 'https://image.made-in-china.com/202f0j00gCoYVfNWalqT/Newly-Spot-Mobile-Phone-M90-Water-Drop-Large-Screen-Fingerprint-Smartphone.webp',
              title: '커피머신',
              price: '100,000원',
              status: '구매 완료',
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String status;

  TransactionItem({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ],
              ),
            ),
            Text(
              status,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
