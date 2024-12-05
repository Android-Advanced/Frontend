import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String searchQuery = ""; // 검색어 상태
  List<Map<String, String>> searchResults = []; // 검색 결과 상태

  // Firestore에서 데이터 검색
  Future<void> _searchItems(String query) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff') // Firestore 문자열 검색
          .get();

      final List<Map<String, String>> loadedItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "image": (data['image'] ?? '').toString(),
          "title": (data['title'] ?? '').toString(),
          "price": (data['price'] ?? '').toString(),
          "description": (data['description'] ?? '').toString(),
        };
      }).toList();

      setState(() {
        searchResults = loadedItems;
      });
    } catch (e) {
      print('검색 중 오류 발생: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
            _searchItems(value); // 검색 쿼리 업데이트 시 Firestore 호출
          },
          decoration: InputDecoration(
            hintText: '게시물 제목으로 검색',
            suffixIcon: GestureDetector(
              onTap: () {
                // 검색어를 Home 화면으로 전달하며 이동
                Navigator.pop(context, searchQuery);

              },
              child: Icon(Icons.search),
            ),
            border: InputBorder.none,
          ),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (searchResults.isEmpty)
              Center(
                child: Text(
                  searchQuery.isEmpty
                      ? '검색어를 입력해주세요.'
                      : '검색 결과가 없습니다.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final item = searchResults[index];
                    return ListTile(
                      leading: Image.network(
                        item["image"]!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error, size: 50); // 이미지 로드 실패 시
                        },
                      ),
                      title: Text(item["title"]!),
                      subtitle: Text('${item["price"]}원'),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;

  CategoryButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

class SearchItem extends StatelessWidget {
  final String label;

  SearchItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        label,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
