import 'package:flutter/material.dart';

class ReviewDetailPage extends StatelessWidget {
  final Map<String, dynamic> reviewData;

  const ReviewDetailPage({Key? key, required this.reviewData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "리뷰 상세",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 이미지
            Center(
              child: reviewData["thumbnail"] != null && reviewData["thumbnail"].isNotEmpty
                  ? Image.network(
                reviewData["thumbnail"],
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 150,
                height: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            // 작성자 이름
            Text(
              "작성자: ${reviewData['reviewerName'] ?? '익명'}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // 온도
            Text(
              "온도: ${reviewData['temperature'].toStringAsFixed(1)}°H",
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 10),
            // 리뷰 내용
            Text(
              "리뷰 내용:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              reviewData['reviewText'] ?? "내용 없음",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
