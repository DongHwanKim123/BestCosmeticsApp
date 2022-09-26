import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:best_cosmetics/screens/baskets/basket_screen.dart';
import 'package:best_cosmetics/screens/search/search_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../../resources/member_get.dart';
import '../../widgets/like_animation.dart';
import '../categories/goods_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final formatCurrency = new NumberFormat.simpleCurrency(locale: "ko.KR",name: "",decimalDigits: 0);
  // var homeData=[];
  var MDGoodsData=[];
  var BestGoodsData=[];
  var NewGoodsData=[];
  var userLikeList = [];
  dynamic userdata;
  bool isLoading = false;
  var count = "";
  var assetImage=['assets/images/1.jpg', 'assets/images/2.jpg', 'assets/images/3.jpg'];
  String basketCount="";

  @override
  void initState() {
    super.initState();
    // getData();
    getMDGoodsData();
    getBestGoodsData();
    getNewGoodsData();
    getlikeData();
    getBasketCount();
  }

  getMDGoodsData () async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse("${adminIp}/api/goodsMd");


    http.Response response = await http.get(
      url,
      headers : {"Accept" : "application/json"}
    );
    var responseBody = utf8.decode(response.bodyBytes);
    MDGoodsData = jsonDecode(responseBody);

    setState(() {
      isLoading = false;
    });
  }

  getBestGoodsData () async {
    var url = Uri.parse("${adminIp}/api/goodsBest");
    http.Response response = await http.get(
      url,
      headers : {"Accept" : "application/json"}
    );
    var responseBody = utf8.decode(response.bodyBytes);
    BestGoodsData = jsonDecode(responseBody);
    //print(allGoodsData);
    setState(() {});
  }

  getNewGoodsData () async {
    var url = Uri.parse("${adminIp}/api/goodsNew");
    http.Response response = await http.get(
      url,
      headers : {"Accept" : "application/json"}
    );
    var responseBody = utf8.decode(response.bodyBytes);
    NewGoodsData = jsonDecode(responseBody);
    //print(allGoodsData);
    setState(() {});
  }

  getlikeData () async {
    MemberGet memberGet = new MemberGet();
    userdata = await memberGet.getUser();
    //print(userdata.userNum);

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
    setState(() {
      
    });
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

  Future<void> _refresh() {
    return Future.delayed(
      Duration(seconds: 0),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              "assets/icons/logo.png",
              width: MediaQuery.of(context).size.width*0.09,
            ),
            Text(
              " Best Cosmetics",
              style: TextStyle(
                color: primaryColor,
              ),
            ),
          ],
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
      body: isLoading? Center(child: CircularProgressIndicator(color: Colors.black),)
        : ListView(
          physics: BouncingScrollPhysics(),
          children: [
            CarouselSlider.builder(
              itemCount: assetImage.length,
              itemBuilder: ((context, index, realIndex) {
                  return Image.asset(
                    assetImage[index],
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                  );
              }
            ),
            options: CarouselOptions(
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              enlargeCenterPage: true,
              height: 250,
            
              )
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Text(
                  "[MD's Pick] MD가 찜♥했닷", 
                  style: TextStyle(fontSize: 20, fontFamily: 'Jua'),
                  )
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CarouselSlider.builder(
                itemCount: MDGoodsData.length,
                itemBuilder: ((context, index, realIndex) {
                  dynamic snapshot = MDGoodsData[index];
                    return InkWell(
                      onTap: () async{
                        await Get.to(() => GoodsDetailPage(bcgKey: snapshot['bcg_key'], bcgName: snapshot['bcg_name']));
                        getlikeData();
                        getBasketCount();
                      },
                      child: Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            snapshot['bcg_img']
                          ),
                        ),
                      ),
                    );
                }),
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 2),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),)
                ),
            ),
        
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Container(
                child: Text("[Best] 인★기★상★품", style: TextStyle(fontSize: 20, fontFamily: 'Jua'),)
                ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20.0),
                height: 200,
                child: RefreshIndicator(
                  onRefresh: _refresh,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: BestGoodsData.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        // crossAxisSpacing: 0.2,
                        // mainAxisSpacing: 2.5,
                        // childAspectRatio: 1,
                      ),
                      shrinkWrap: true, 
                      itemBuilder: (context, index) {
                        dynamic snapshot = BestGoodsData[index];
                        var nameSubString = snapshot['bcg_name'].toString();
                        bool isLike = userLikeList.contains(snapshot['bcg_key']);
                          // if(nameSubString.length>10){
                          //   nameSubString = nameSubString.substring(0,9);
                          // }
                          return InkWell(
                            onTap: () async{
                              await Get.to(() => GoodsDetailPage(bcgKey: snapshot['bcg_key'], bcgName: snapshot['bcg_name']));
                              getlikeData();
                              getBasketCount();
                            },
                            child: GridTile(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                        borderRadius: BorderRadius.circular(16.0),
                                          child: Image.network(
                                            snapshot['bcg_img']
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
                                        ),
                                      ],
                                    ),
                                    
                                  ),
                                  Text(
                                    nameSubString,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    formatCurrency.format(snapshot['bcg_price'])+"원",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ]
                              ),
                            )
                          );
                      }
                  ),
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Container(
                child: Text("[New] 최신상품", style: TextStyle(fontSize: 20, fontFamily: 'Jua',),)
                ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20.0),
                height: 200,
                child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: NewGoodsData.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          // crossAxisSpacing: 0.2,
                          // mainAxisSpacing: 2.5,
                          // childAspectRatio: 1,
                        ),
                        shrinkWrap: true, 
                        itemBuilder: (context, index) {
                          dynamic snapshot = NewGoodsData[index];
                          var nameSubString = snapshot['bcg_name'].toString();
                          bool isLike = userLikeList.contains(snapshot['bcg_key']);
                            // if(nameSubString.length>10){
                            //   nameSubString = nameSubString.substring(0,9);
                            // }
                            return InkWell(
                              onTap: () async{
                                await Get.to(() => GoodsDetailPage(bcgKey: snapshot['bcg_key'], bcgName: snapshot['bcg_name']));
                                getlikeData();
                                getBasketCount();
                              },
                              child: GridTile(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                          borderRadius: BorderRadius.circular(16.0),
                                            child: Image.network(
                                              snapshot['bcg_img']
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
                                          ),
                                        ],
                                      ),
                                      
                                    ),
                                    Text(
                                      nameSubString,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      formatCurrency.format(snapshot['bcg_price'])+"원",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ]
                                ),
                              )
                            );
                        }
                 )
              ),
            ),
          ],
        )
        // GridView.builder(
        //   itemCount: NewGoodsData.length,
        //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: 3,
        //     crossAxisSpacing: 2.5,
        //     mainAxisSpacing: 2.5,
        //     childAspectRatio: 1,
        //   ),
        //   shrinkWrap: true, 
        //   itemBuilder: (context, index) {
        //     dynamic snapshot = NewGoodsData[index];
        //     return Image(
        //       image: NetworkImage(
        //         snapshot['bcg_img']
        //       ),
        //     );
        //   }
        // )
    );
  }
}