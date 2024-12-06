import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'chatscreen.dart';

class Post extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const Post({super.key, required this.itemData});

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  bool _isLiked = false;
  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _fetchUserProfileImage();
  }

  Future<void> _checkIfLiked() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final String userId = currentUser.uid;
    final String itemId = widget.itemData['itemId'] ?? '';

    if (itemId.isEmpty) return;

    final likedItemDoc =
    FirebaseFirestore.instance.collection('likedItems').doc('${userId}_$itemId');

    final likedItemSnapshot = await likedItemDoc.get();

    setState(() {
      _isLiked = likedItemSnapshot.exists;
    });
  }

  Future<void> _fetchUserProfileImage() async {
    try {
      final String userId = widget.itemData['userId'] ?? '';

      if (userId.isNotEmpty) {
        final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            profileImageUrl = userData['profileImage'] ?? '';
            if (profileImageUrl.startsWith('gs://')) {
              FirebaseStorage.instance
                  .refFromURL(profileImageUrl)
                  .getDownloadURL()
                  .then((url) {
                setState(() {
                  profileImageUrl = url;
                });
              });
            }
          });
        }
      }
    } catch (e) {
      print('프로필 이미지 가져오기 실패: $e');
    }
  }

  Future<void> _toggleLike() async {
    try {
      if (_isLiked) {
        await _removeFromLikedItems();
      } else {
        await _addToLikedItems();
      }

      final itemDoc = FirebaseFirestore.instance.collection('items').doc(widget.itemData['itemId']);
      final snapshot = await itemDoc.get();
      final updatedLikes = snapshot.data()?['likes'] ?? 0;

      setState(() {
        _isLiked = !_isLiked;
        widget.itemData['likes'] = updatedLikes;
      });
    } catch (e) {
      print("좋아요 토글 중 오류 발생: $e");
    }
  }

  Future<void> _addToLikedItems() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그인 후 사용 가능합니다.")),
        );
        return;
      }

      final String userId = currentUser.uid;
      final String itemId = widget.itemData['itemId'] ?? '';

      if (itemId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("항목 ID가 올바르지 않습니다.")),
        );
        return;
      }

      final likedItemDoc =
      FirebaseFirestore.instance.collection('likedItems').doc('${userId}_$itemId');

      final itemDoc = FirebaseFirestore.instance.collection('items').doc(itemId);

      await likedItemDoc.set({
        'userId': userId,
        'itemId': itemId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await itemDoc.update({'likes': FieldValue.increment(1)});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("관심 목록에 추가되었습니다.")),
      );
    } catch (e) {
      print("찜 추가 중 오류 발생: $e");
    }
  }

  Future<void> _removeFromLikedItems() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) return;

      final String userId = currentUser.uid;
      final String itemId = widget.itemData['itemId'] ?? '';

      final likedItemDoc =
      FirebaseFirestore.instance.collection('likedItems').doc('${userId}_$itemId');

      final itemDoc = FirebaseFirestore.instance.collection('items').doc(itemId);

      await likedItemDoc.delete();
      await itemDoc.update({'likes': FieldValue.increment(-1)});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("관심 목록에서 제거되었습니다.")),
      );
    } catch (e) {
      print("찜 제거 중 오류 발생: $e");
    }
  }

  String calculateTimeAgo(String createdAt) {
    try {
      final DateTime createdTime = DateTime.parse(createdAt);
      final Duration difference = DateTime.now().difference(createdTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}일 전';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}시간 전';
      } else {
        return '${difference.inMinutes}분 전';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Image.network(
                widget.itemData['image'] ?? '',
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, size: 50);
                },
              ),
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl.isEmpty
                          ? Icon(Icons.account_circle, size: 50, color: Colors.blue)
                          : null,
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.itemData['displayName'] ?? '사용자 이름 없음',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: _toggleLike,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  widget.itemData['title'] ?? '제목 없음',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '${widget.itemData['categories'] ?? '카테고리 없음'} · ${widget.itemData['buyerId']?.isEmpty ?? true ? '판매중' : '판매완료'}',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  widget.itemData['description'] ?? '해당 제품에 대한 설명이 없습니다.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '${widget.itemData['price']}원',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatRoomId: widget.itemData['title'] ?? '제목 없음',
                              name: widget.itemData['displayName'] ?? '사용자 이름 없음',
                              temperature: '37.2°C',
                              product: widget.itemData['title'] ?? '제목 없음',
                              price: '${widget.itemData['price']}원',
                              productImage: widget.itemData['image'] ?? '',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: Text(
                        '채팅하기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
