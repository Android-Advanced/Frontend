import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './ReviewDetailPage.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({Key? key}) : super(key: key);

  Future<String> _fetchUserProfileImage() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final data = userDoc.data() ?? {};
    String imageUrl = data['profileImage'] ?? "";

    if (imageUrl.startsWith("gs://")) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        imageUrl = await ref.getDownloadURL();
      } catch (e) {
        print("이미지 URL 변환 오류: $e");
      }
    }
    return imageUrl;
  }

  Future<List<Map<String, dynamic>>> _fetchReviews() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('revieweeUID', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return await Future.wait(querySnapshot.docs.map((doc) async {
        final data = doc.data();
        String reviewerImage = "";
        if (data["reviewerUID"] != null) {
          final reviewerDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(data["reviewerUID"])
              .get();
          final reviewerData = reviewerDoc.data() ?? {};
          reviewerImage = reviewerData["profileImage"] ?? "";

          if (reviewerImage.startsWith("gs://")) {
            try {
              final ref = FirebaseStorage.instance.refFromURL(reviewerImage);
              reviewerImage = await ref.getDownloadURL();
            } catch (e) {
              print("리뷰어 이미지 URL 변환 오류: $e");
            }
          }
        }

        String thumbnailUrl = data["thumbnail"] ?? "";
        if (thumbnailUrl.startsWith("gs://")) {
          try {
            final ref = FirebaseStorage.instance.refFromURL(thumbnailUrl);
            thumbnailUrl = await ref.getDownloadURL();
          } catch (e) {
            print("썸네일 URL 변환 오류: $e");
          }
        }

        return {
          "reviewerName": data["reviewerName"] ?? "익명",
          "temperature": data["rating"] ?? 0.0,
          "reviewText": data["reviewText"] ?? "",
          "reviewerImage": reviewerImage,
          "thumbnail": thumbnailUrl,
        };
      }).toList());
    } catch (e) {
      print("리뷰 데이터를 불러오는 중 오류 발생: $e");
      rethrow;
    }
  }

  Widget _bodyWidget(String userProfileImage, List<Map<String, dynamic>> reviews) {
    return Column(
      children: [
        // Main Profile Section
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: userProfileImage.isNotEmpty
                    ? NetworkImage(userProfileImage)
                    : null,
                backgroundColor: Colors.grey[300],
                child: userProfileImage.isEmpty
                    ? Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
              SizedBox(height: 10),
              Text(
                "내 거래 후기",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Divider(),

        // Review List Section
        Expanded(
          child: ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewDetailPage(reviewData: review),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 리뷰어의 프로필 이미지
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: review["reviewerImage"].isNotEmpty
                            ? NetworkImage(review["reviewerImage"])
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: review["reviewerImage"].isEmpty
                            ? Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  review["reviewerName"],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "${review["temperature"].toStringAsFixed(1)}°H",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2657A1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                              review["reviewText"],
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      review["thumbnail"].isNotEmpty
                          ? Image.network(
                        review["thumbnail"],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "거래 후기",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_fetchUserProfileImage(), _fetchReviews()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            print("오류 발생: ${snapshot.error}");
            return Center(
              child: Text('리뷰 데이터를 불러오는 중 오류가 발생했습니다.'),
            );
          }

          final userProfileImage = snapshot.data?[0] as String;
          final reviews = snapshot.data?[1] as List<Map<String, dynamic>>;
          if (reviews.isEmpty) {
            return Center(
              child: Text('거래 후기가 없습니다.'),
            );
          }
          return _bodyWidget(userProfileImage, reviews);
        },
      ),
    );
  }
}
