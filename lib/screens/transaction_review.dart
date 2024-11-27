import 'package:flutter/material.dart';

class ReviewPage extends StatelessWidget {
  // Sample data for reviews
  final List<Map<String, dynamic>> reviews = [
    {
      "name": "나유성",
      "temperature": 37.2,
      "review": "정말 답변도 빠르시고 잘 거래했습니다.",
      "image": "", // No image path
    },
    {
      "name": "나유성",
      "temperature": 37.2,
      "review": "정말 답변도 빠르시고 잘 거래했습니다.",
      "image": "", // No image path
    },
    {
      "name": "나유성",
      "temperature": 37.2,
      "review": "정말 답변도 빠르시고 잘 거래했습니다.",
      "image": "", // No image path
    },
  ];


  Widget _bodyWidget(){
    return Column(
      children: [
        // Main Profile Section
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "한성부기님",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                review["name"],
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
                            review["review"],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    // Image or Placeholder Box
                    review["image"].isNotEmpty
                        ? Image.asset(
                      review["image"],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget _appbarWidget() {
      return AppBar(
        title: Text(
          "거래 후기",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // Make the text bold
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true, // Center the title
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      );
    }
    return Scaffold(
      appBar: _appbarWidget(),
      body:  _bodyWidget()
    );
  }
}