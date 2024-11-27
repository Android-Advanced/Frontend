import 'package:flutter/material.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  List<Map<String, String>> datas = [];

  @override
  void initState() {
    super.initState();
    datas = [
      {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      },
      {
        "image": "assets/images/2.jpg",
        "title": "아이폰 13프로맥스",
        "price": "1300000",
        "likes": "15"
      },
      {
        "image": "assets/images/2.jpg",
        "title": "커피머신",
        "price": "150000",
        "likes": "1"
      },
      {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      }, {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      },
      {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      },
      {
        "image": "assets/images/2.jpg",
        "title": "커피머신",
        "price": "150000",
        "likes": "1"
      },
      {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      }, {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      },
      {
        "image": "assets/images/1.jpg",
        "title": "샌드위치 팝니다",
        "price": "3000",
        "likes": "2"
      }
    ];
  }


  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Text(
        "내가 등록한 상품",
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


  String calcStringToWon(String priceString){
    return "원";
  }
  Widget _bodyWidget() {
    return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (BuildContext _context, int index) {
          //리스트 클릭 페이지 전환
          return GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext){
                  return Container();
                }));

                print(datas[index]["title"]);
              },
              //여기까지
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      child: Image.asset(
                        datas[index]["image"]!,
                        width: 100,
                        height: 100,
                      ),
                    ),
                    Expanded(
                      child:Container(
                        height: 100,
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(datas[index]["title"]!),
                            Text(
                              datas[index]["price"]! + "원",
                              style: TextStyle(
                                color: Color(0xFF0E3672), // 텍스트 색상을 파란색으로 설정
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(Icons.favorite, color: Colors.red), // 하트 아이콘 추가
                                  SizedBox(width: 5), // 아이콘과 텍스트 간격
                                  Text(datas[index]["likes"]!), // 좋아요 수 표시
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
          );
        },
        itemCount: 10,

        separatorBuilder: (BuildContext _context, int index) {
          return Container(height: 1, color: Colors.black,);
        }
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
