import 'dart:convert';
import 'dart:typed_data';

import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/resources/storage_methds.dart';
import 'package:best_cosmetics/screens/categories/goods_detail_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/utils.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ReviewWriteScreen extends StatefulWidget {
  final int bcgKey;
  final String bcgName;
  final String bcgImg;
  final String orderNum;
  const ReviewWriteScreen({Key? key, required this.bcgKey, required this.bcgName, required this.bcgImg, required this.orderNum}) : super(key: key);

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  MemberGet memberGet = new MemberGet();
  final TextEditingController _reviewController = TextEditingController();
  List<bool> stars = [false,false,false,false,false];
  Uint8List? _image;
  dynamic userdata;

  @override
  void dispose() {
    super.dispose();
    _reviewController.dispose();
  }
  
  void starsCheck (int index) {
    for(int i = 0; i<stars.length ; i++){
      if(i==index){
        stars[i] = !stars[i];
      }else if(i<index){
        stars[i] = true;
      }else{
        stars[i] = false;
      }
    }
    setState(() {
      
    });
  }
  
  selectImage() async{
    var im = await pickImage(ImageSource.gallery);
    
    setState(() {
      _image = im;
    });
  }

  void _fieldSubmit (String reviewStr) {
    
  }

  void reviewSubmit () async{
    if(_reviewController.text == "") {
      showSnackBar(context, "리뷰 내용이 없습니다.");
      return;
    }
    userdata = await memberGet.getUser();
    String photoUrl = "";
    try{
      photoUrl = await StorageMethods().uploadImageToStorage("review", _image!);
    } catch(err) {
      print(err.toString());
    }

    int score = 0;
    for(int i = 0; i<stars.length ; i++){
      if(stars[i]){
        score += 1;
      }
    }

    print(photoUrl);
    print(_reviewController.text);
    print(score);

    var url = Uri.parse("${adminIp}/api/member/review/write");

    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/x-www-form-urlencoded',
      },
      body: <String, String> {
        "bcmNum" : userdata.userNum.toString(),
        "bcmName" : userdata.userName.toString(),
        "bcgKey" : widget.bcgKey.toString(),
        "bcgName" : widget.bcgName,
        "bcrPhoto" : photoUrl,
        "bcrScore" : score.toString(),
        "bcrContent" : _reviewController.text,
        "orderNum" : widget.orderNum
      },
    );
    _reviewController.clear();
    showSnackBar(context, "리뷰가 등록되었습니다.");
    Get.off(() => GoodsDetailPage(bcgKey: widget.bcgKey, bcgName: widget.bcgName));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("리뷰작성"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: [
              stars[0] 
              ? ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  widget.bcgImg,
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                ),
              )
              : ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  widget.bcgImg,
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(height: 10,),
              Center(child: Text(widget.bcgName, style: TextStyle(fontFamily: 'jua'),)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      starsCheck(0);
                    }, 
                    icon: Icon(
                      stars[0] ? Icons.star : Icons.star_border_outlined
                    ),
                    color: stars[0] ? Colors.yellowAccent : Colors.black26,
                  ),
                  IconButton(
                    onPressed: () {
                      starsCheck(1);
                    }, 
                    icon: Icon(
                      stars[1] ? Icons.star : Icons.star_border_outlined
                    ),
                    color: stars[1] ? Colors.yellowAccent : Colors.black26,
                  ),
                  IconButton(
                    onPressed: () {
                      starsCheck(2);
                    }, 
                    icon: Icon(
                      stars[2] ? Icons.star : Icons.star_border_outlined
                    ),
                    color: stars[2] ? Colors.yellowAccent : Colors.black26,
                  ),
                  IconButton(
                    onPressed: () {
                      starsCheck(3);
                    }, 
                    icon: Icon(
                      stars[3] ? Icons.star : Icons.star_border_outlined
                    ),
                    color: stars[3] ? Colors.yellowAccent : Colors.black26,
                  ),
                  IconButton(
                    onPressed: () {
                      starsCheck(4);
                    }, 
                    icon: Icon(
                      stars[4] ? Icons.star : Icons.star_border_outlined
                    ),
                    color: stars[4] ? Colors.yellowAccent : Colors.black26,
                  )
                ],
              ),
              stars[0] ==false
              ? Container()
              : Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _reviewController,
                      cursorColor: Colors.black,
                      style: TextStyle(fontFamily: "NotoSansKR"),
                      maxLines: 5,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Color.fromRGBO(196, 196, 255, 200),
                        hintText: '리뷰 내용을 입력해주세요',
                        hintStyle: const TextStyle(
                          color: Colors.black26
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black26)
                        )
                      ),
                      onFieldSubmitted: _fieldSubmit,
                    ),
                    SizedBox(height: 10,),
                    _image != null
                    ? InkWell(
                      onTap: selectImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.memory(
                          _image!,
                          width: MediaQuery.of(context).size.width *0.3,
                          height: MediaQuery.of(context).size.width *0.3,
                        ),
                      ),
                    )
                    : Container(
                      width: MediaQuery.of(context).size.width *0.3,
                      height: MediaQuery.of(context).size.width *0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.black38,
                        )
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.add_a_photo
                            ),
                            tooltip: "이미지 등록",
                            iconSize: 50,
                            color: Colors.black54,
                            onPressed: selectImage,
                          ),
                          Text("사진", style: TextStyle(color: Colors.black54),)
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.black)
                      ),
                      child: Text("등록"),
                      onPressed: reviewSubmit,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}