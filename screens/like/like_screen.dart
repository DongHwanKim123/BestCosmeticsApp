
import 'package:badges/badges.dart';
import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/screens/baskets/basket_screen.dart';
import 'package:best_cosmetics/screens/categories/goods_detail_screen.dart';
import 'package:best_cosmetics/screens/search/search_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:best_cosmetics/widgets/like_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class LikeScreen extends StatefulWidget {
  const LikeScreen({Key? key}) : super(key: key);

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  final formatCurrency = new NumberFormat.simpleCurrency(locale: "ko.KR",name: "",decimalDigits: 0);
  MemberGet memberGet = new MemberGet();
  dynamic userdata;
  var likeGoodsData = [];
  var userLikeList = [];
  var count = "";
  String basketCount="";

  @override
  void initState() {
    super.initState();
    
    getLikeGoodsData();
    getlikeData();
    getBasketCount();
  }

  getLikeGoodsData () async {
    userdata = await memberGet.getUser();
    var url = Uri.parse("${adminIp}/api/member/UserGoodsJoinLikelist");
    
    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/x-www-form-urlencoded',
      },
      body: <String, String> {
        "bcmNum" : userdata.userNum.toString()
      },
    );
    var responseBody = utf8.decode(response.bodyBytes);
    likeGoodsData = jsonDecode(responseBody);
    setState(() {});
  }

  getlikeData () async {
    userdata = await memberGet.getUser();
    var url = Uri.parse("${adminIp}/api/member/likeList");
    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/x-www-form-urlencoded',
      },
      body: <String, String> {
        "bcmNum" : userdata.userNum.toString()
      },
    );
    var responseBody = utf8.decode(response.bodyBytes);
    var jsonData = jsonDecode(responseBody);
    //print(jsonData);
    userLikeList=[];
    for(var i = 0; i<jsonData.length; i++) {
      int bcgKey = jsonData[i]['bcg_key'];
      userLikeList.add(bcgKey);
    }
    //print(userLikeList);
    setState(() {});
  }
  favoriteCount (int bcgKey) async {
    var url = Uri.parse("${adminIp}/api/goods/favoriteCount");
    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/x-www-form-urlencoded',
      },
      body: <String, String> {
        "bcgKey" : bcgKey.toString(),
        "count" : count,
        "bcmNum" : userdata.userNum.toString()
      },
    );
  }
  getBasketCount () async {
    MemberGet memberGet = new MemberGet();
    userdata = await memberGet.getUser();

    var url = Uri.parse("${adminIp}/api/member/basket/count?bcmNum=${userdata.userNum.toString()}");

    http.Response response = await http.get(
      url,
      headers : {"Accept" : "application/json"}
    );
    var responseBody = utf8.decode(response.bodyBytes);
    var Data = jsonDecode(responseBody);
    print(Data);
    basketCount = Data.toString();
    setState(() {
      
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroudColor,
        title: Text(
          "찜 목록"
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => SearchScreen());
            }, 
            icon: Icon(
              Icons.search
            )
          ),
          IconButton(
            onPressed: () async{
              await Get.to(() =>BasketScreen(),transition: Transition.rightToLeft);
              getBasketCount();
            }, 
            icon: 
            (basketCount == "0")
            ? Icon(
                Icons.shopping_cart_outlined
            )
            : Badge(
                badgeContent: Text(
                  basketCount, style: const TextStyle(color: Colors.white),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined
                ),
                badgeColor: Colors.black,
                animationType: BadgeAnimationType.scale,
                animationDuration: Duration(milliseconds: 200),
            )
          ),
        ],
      ),
      body:Container(
        margin: EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            child: GridView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: likeGoodsData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 7,
                mainAxisSpacing: 18,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                dynamic snapshot = likeGoodsData[index];
                bool isLike = userLikeList.contains(snapshot['bcg_key']);
                return InkWell(
                  onTap: () async{
                    await Get.to(() => GoodsDetailPage(bcgKey: snapshot['bcg_key'], bcgName: snapshot['bcg_name']));
                    getlikeData();
                    getBasketCount();
                  },
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.network(
                                snapshot['bcg_img'],
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: LikeAnimation(
                                isAnimating: isLike,
                                smallLike: true,
                                child: IconButton(
                                  splashRadius: 0.1,
                                  icon: Icon(
                                    isLike ? Icons.favorite : Icons.favorite_outline_outlined ,
                                    color:
                                    isLike ? Colors.red : Colors.black12,
                                  ),
                                  onPressed: () async{
                                    if(isLike){
                                      await favoriteCount(snapshot['bcg_key']);
                                      setState(() {
                                        count = "down";
                                      });
                                      getlikeData();
                                    }else{
                                      await favoriteCount(snapshot['bcg_key']);
                                      setState(() {
                                        count = "up";
                                      });
                                      getlikeData();
                                    }
                                  },
                                ),
                              )
                            )
                          ],
                        ),
                        SizedBox(height: 2,),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: snapshot['bcg_name'],
                              style: TextStyle(color: Colors.black54, fontSize: 13)
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: formatCurrency.format(snapshot['bcg_price'])+"원",
                              style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w500, fontSize: 15)
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
        ),   
      ),
    );
  }
}