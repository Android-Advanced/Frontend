import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class PostItemScreen extends StatefulWidget {
  @override
  _PostItemScreenState createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage; // 선택한 이미지 파일을 저장
  List<String> selectedCategories = [];
  Position? _currentPosition;

  final List<String> allCategories = [
    '맛집 탐방', '전자제품', '건강', '스포츠', '책', '운동', '중고차', '가구', '도서', '식물', '상품권'
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      // 위치 권한 요청
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("위치 서비스가 비활성화되어 있습니다.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("위치 권한이 거부되었습니다.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("위치 권한이 영구적으로 거부되었습니다.");
        return;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        print("현재 위치: ${position.latitude}, ${position.longitude}");
      });
    } catch (e) {
      print("위치 가져오기 실패: $e");
    }
  }


  // 이미지 선택
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 이미지를 Firebase Storage에 업로드
  Future<String?> _uploadImage(File image) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg'; // 고유 파일명 생성
      final Reference storageRef =
      FirebaseStorage.instance.ref().child('item_images/$fileName');
      final UploadTask uploadTask = storageRef.putFile(image);
      final TaskSnapshot taskSnapshot = await uploadTask;

      // 업로드 완료 후 다운로드 URL 반환
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
      return null;
    }
  }

  // Firestore에 데이터 저장
  void _addItemToFirestore() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('사용자가 로그인되어 있지 않습니다.');
      return;
    }
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      print('사용자 정보를 찾을 수 없습니다.');
      return;
    }

    if (_currentPosition == null) {
      print("현재 위치를 가져올 수 없습니다.");
      return;
    }

    // 선택된 이미지를 업로드하고 URL 가져오기
    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImage(_selectedImage!);
    } else {
      print('이미지를 선택해주세요.');
      return;
    }

    final hansungPoint = userDoc['hansungPoint'] ?? 0.0;

    final docRef = FirebaseFirestore.instance.collection('items').doc(); // Firestore 컬렉션과 문서 ID 생성

    await docRef.set({
      'image': imageUrl ?? '', // 업로드된 이미지 URL
      'title': _titleController.text, // 제목 입력값
      'price': int.tryParse(_priceController.text) ?? 0, // 가격 입력값
      'description': _descriptionController.text, // 설명 입력값
      'categories': selectedCategories, // 선택된 카테고리 리스트
      'userId': user.uid, // 로그인된 사용자 ID
      'createdAt': FieldValue.serverTimestamp(), // Firestore 서버 타임스탬프
      'likes': 0,
      'displayName' : userDoc['displayName'],
      'buyerId':"",
      'hansungPoint' : hansungPoint,
      'location': GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
    });

    print('상품이 성공적으로 등록되었습니다!');
    // 저장 완료 후 이전 화면으로 이동
    Navigator.pop(context);
  }

  void _validateAndSubmit() {
    if (_titleController.text.isEmpty) {
      print('제목을 입력해주세요.');
      return;
    }
    if (_priceController.text.isEmpty || int.tryParse(_priceController.text) == null) {
      print('올바른 가격을 입력해주세요.');
      return;
    }
    if (_descriptionController.text.isEmpty) {
      print('설명을 입력해주세요.');
      return;
    }
    if (_selectedImage == null) {
      print('이미지를 선택해주세요.');
      return;
    }
    if (_currentPosition == null) {
      print('위치를 가져오는 중입니다. 잠시 후 다시 시도해주세요.');
      return;
    }

    _addItemToFirestore();
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
        title: Text(
          '내 물건 팔기',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImage != null
                    ? Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                )
                    : Icon(Icons.add, size: 40, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 11.0), // 위쪽 간격 추가
              child: Text(
                '제목', // 굵은 글씨 제목
                style: TextStyle(
                  fontSize: 16, // 글씨 크기
                  fontWeight: FontWeight.bold, // 굵게 표시
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                alignLabelWithHint: true, // Label과 Hint를 정렬
                labelText: '제목', // 설명을 Label로
                labelStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey, // 스타일 커스터마이징 가능
                ),
                border: OutlineInputBorder(),
              ),
              maxLines: 1, // 여러 줄 입력 가능
            ),
            Padding(
              padding: const EdgeInsets.only(top: 11.0), // 위쪽 간격 추가
              child: Text(
                '가격', // 굵은 글씨 제목
                style: TextStyle(
                  fontSize: 16, // 글씨 크기
                  fontWeight: FontWeight.bold, // 굵게 표시
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                alignLabelWithHint: true, // Label과 Hint를 정렬
                labelText: '가격', // 설명을 Label로
                labelStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey, // 스타일 커스터마이징 가능
                ),
                border: OutlineInputBorder(),
              ),
              maxLines: 1, // 여러 줄 입력 가능
            ),
            Padding(
              padding: const EdgeInsets.only(top: 11.0), // 위쪽 간격 추가
              child: Text(
                '자세한 설명', // 굵은 글씨 제목
                style: TextStyle(
                  fontSize: 16, // 글씨 크기
                  fontWeight: FontWeight.bold, // 굵게 표시
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                alignLabelWithHint: true, // Label과 Hint를 정렬
                labelText: '거래할 물건을 상세하게 설명해주세요', // 설명을 Label로
                labelStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey, // 스타일 커스터마이징 가능
                ),
                border: OutlineInputBorder(),
              ),
              maxLines: 6, // 여러 줄 입력 가능
            ),

            SizedBox(height: 16),
            Text(
              '카테고리',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: [
                ...selectedCategories.map((category) => CategoryChip(label: category, selected: true)),
                GestureDetector(
                  onTap: () {
                    _showCategorySelection();
                  },
                  child: Chip(
                    label: Text('+'),
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  '등록하기',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '카테고리 선택',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 18),
              Wrap(
                spacing: 11.0, // 가로 간격
                runSpacing: 8.0, // 세로 간격 추가
                children: allCategories.map((category) {
                  final isSelected = selectedCategories.contains(category);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedCategories.remove(category);
                        } else {
                          selectedCategories.add(category);
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: Chip(
                      label: Text(category),
                      backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        );
      },
    );
  }

  // 등록 확인 팝업
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.inventory, color: Colors.blue),
              SizedBox(width: 8),
              Text('물건등록'),
            ],
          ),
          content: Text('물건을 등록하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // NO 버튼 클릭 시 팝업 닫기
              },
              child: Text('NO', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                // OK 버튼 클릭 시 Firestore에 데이터 저장
                _addItemToFirestore();
                Navigator.pop(context); // OK 버튼 클릭 시 팝업 닫기
                // 등록 로직 추가 가능
              },
              child: Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;

  CategoryChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: selected ? Colors.blue : Colors.grey[300],
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
      ),
    );
  }
}
