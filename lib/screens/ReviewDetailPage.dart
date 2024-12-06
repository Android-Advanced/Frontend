import 'package:flutter/material.dart';

class ReviewDetailPage extends StatelessWidget {
  final Map<String, dynamic> reviewData;

  const ReviewDetailPage({Key? key, required this.reviewData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 썸네일 이미지
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: reviewData["thumbnail"] != null &&
                        reviewData["thumbnail"].isNotEmpty
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
                ),
                const SizedBox(height: 20),
                // 작성자 섹션
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: reviewData["reviewerImage"] != null &&
                          reviewData["reviewerImage"].isNotEmpty
                          ? NetworkImage(reviewData["reviewerImage"])
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: reviewData["reviewerImage"] == null ||
                          reviewData["reviewerImage"].isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reviewData['reviewerName'] ?? '익명',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "리뷰 온도: ${reviewData['temperature'].toStringAsFixed(1)}°C",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 리뷰 제목
                const Text(
                  "리뷰 내용",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // 리뷰 본문
                Text(
                  reviewData['reviewText'] ?? "내용 없음",
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
