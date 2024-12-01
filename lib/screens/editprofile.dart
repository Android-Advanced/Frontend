import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> categories = [
    "맛집 탐방", "전자제품", "건강", "스포츠", "책", "운동", "중고차", "가구", "도서", "식물", "상품권"
  ];
  final Set<String> selectedCategories = {};
  String profileImage = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['displayName'] ?? '';
        selectedCategories.addAll(List<String>.from(data['categories'] ?? []));
        profileImage = data['profileImage'] ?? "";
        isLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'displayName': _nameController.text,
        'categories': selectedCategories.toList(),
        'profileImage': profileImage,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('정보가 성공적으로 저장되었습니다.')),
      );
    }
  }

  Future<void> _changeProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profileImages')
            .child('${currentUser.uid}.jpg');

        await ref.putFile(File(pickedFile.path));
        final newImageUrl = await ref.getDownloadURL();

        setState(() {
          profileImage = newImageUrl;
        });
      }
    }
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          Text(
            "정보 변경",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications),
        ),
      ],
    );
  }

  Widget _profilePictureSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage: profileImage.isNotEmpty
              ? NetworkImage(profileImage)
              : AssetImage('assets/images/user_profile.jpg') as ImageProvider,
          child: profileImage.isEmpty
              ? Icon(
            Icons.person,
            size: 60,
            color: Colors.white,
          )
              : null,
        ),
        Positioned(
          right: 0,
          child: ElevatedButton(
            onPressed: _changeProfilePicture,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2657A1),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              "사진 변경",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((category) {
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
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF2657A1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _bodyWidget() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profilePictureSection(),
          SizedBox(height: 20),
          Text(
            "이름",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "관심 카테고리",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 10),
          _categoryChips(),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _saveUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2657A1),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                "저장 하기",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}
