import 'dart:convert';
import 'dart:core';
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

class CatecoryScreen extends StatefulWidget {
  const CatecoryScreen({Key? key}) : super(key: key);

  @override
  State<CatecoryScreen> createState() => _CatecoryScreenState();
}

class _CatecoryScreenState extends State<CatecoryScreen> 
    with TickerProviderStateMixin {

  final formatCurrency = new NumberFormat.simpleCurrency(locale: "ko.KR",name: "",decimalDigits: 0);
  late TabController _tabController;
  var skinData=[];
  var pointData=[];
  var baseData=[];
  var allGoodsData = [];
  var userLikeList = [];
  var count = "";
  dynamic userdata;
  bool isLoading = false;
  String basketCount="";

  @override
  void initState() {
    _tabController = new TabController(
      length : 7,
      vsync : this,
    );
    setState(() {
      isLoading=true;
    });

    super.initState();
    getAllGoodsData();
    getSkinCareData();
    getPointData();
    getBaseData();
    getlikeData();
    getBasketCount();

    setState(() {
      isLoading =false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  getAllGoodsData () async {
    var url = Uri.parse("${adminIp}/api/goods");
    http.Response response = await http.get(
      url,
      headers : {"Accept" : "application/json"}
    );
    var responseBody = utf8.decode(response.bodyBytes);
    allGoodsData = jsonDecode(responseBody);
    // print(allGoodsData);
    setState(() {});
  }

  getSkinCareData () async {
    var url = Uri.parse("${adminIp}/api/category/skinCare");
    http.Response response = await http.get(
      url,
      headers : {"Accept" : "application/json"}
    );
    var responseBody = utf8.decode(response.bodyBytes);
    skinData = jsonDecode(responseBody);
    //print(skinData);
    setState(() {});
  }

  getPointData () async {
    var url = Uri.parse("${adminIp}/api/category/point");
    http.Response response = await http.get(
      url,
      headers : {"Accept" : "application/json"}
    );
    var responseBody = utf8.decode(response.bodyBytes);
    pointData = jsonDecode(responseBody);
    //print(pointData);
    setState(() {});
  }

  getBaseData () async {
    var url = Uri.parse("${adminIp}/api/category/base");
    http.Response response = await http.get(
      url,
      headers : {"Accept" : "application/json"}
    );
    var responseBody = utf8.decode(response.bodyBytes);
    baseData = jsonDecode(responseBody);
    //print(baseData);
    setState(() {});
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
    print(userLikeList);
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
      appBar: AppBar(
        title: Text(
          "카테고리",
          style: TextStyle(
            color: primaryColor
          ),
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
        bottom: TabBar(
          tabs: [
            Tab(text: "전체"),
            Tab(text: "스킨케어"),
            Tab(text: "베이스메이크업"),
            Tab(text: "포인트메이크업"),
            Tab(text: "클렌징"),
            Tab(text: "선케어"),
            Tab(text: "향수"),
          ],
          labelColor: primaryColor,
          controller: _tabController,
          isScrollable: true,
          indicatorColor: primaryColor,
        ),
      ),
      body: 
      isLoading
      ? Center(child: CircularProgressIndicator(color: Colors.black),)
      :
      Container(
        margin: EdgeInsets.all(10),
        child: TabBarView(
          children: <Widget>[
            //전체
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 4),
                      child: RefreshIndicator(
                        color: primaryColor,
                        onRefresh: _refresh,
                        child: GridView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: allGoodsData.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.84,
                          ),
                          shrinkWrap: true, 
                          itemBuilder: (context, index) {
                            dynamic snapshot = allGoodsData[index];
                            var nameSubString = snapshot['bcg_name'].toString();
                            bool isLike = userLikeList.contains(snapshot['bcg_key']);
                            
                            return InkWell(
                              onTap: () async{
                                await Get.to(() => GoodsDetailPage(bcgKey: snapshot['bcg_key'], bcgName: snapshot['bcg_name']));
                                getlikeData();
                                getBasketCount();
                              },
                              child: Container(
                                child : GridTile(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
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
                                      Text(
                                        nameSubString,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12
                                        ),
                                      )
                                    ],
                                  ),
                                  footer: Text(
                                    formatCurrency.format(snapshot['bcg_price'])+"원",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                )
                              ),
                            );
                          }
                        )
                      ),
                    ),
                  )
                ],
              ),
            ),
            //스킨케어
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 4),
                      child: RefreshIndicator(
                        color: primaryColor,
                        onRefresh: _refresh,
                        child: GridView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: skinData.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.84,
                          ),
                          shrinkWrap: true, 
                          itemBuilder: (context, index) {
                            dynamic snapshot = skinData[index];
                            var nameSubString = snapshot['bcg_name'].toString();
                            bool isLike = userLikeList.contains(snapshot['bcg_key']);
                            if(nameSubString.length>20){
                              nameSubString = nameSubString.substring(0,19);
                            }
                            return InkWell(
                              onTap: () async{
                                await Get.to(() => GoodsDetailPage(bcgKey: snapshot['bcg_key'], bcgName: snapshot['bcg_name']));
                                getlikeData();
                                getBasketCount();
                              },
                              child: Container(
                                child : GridTile(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
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
                                      Text(
                                        nameSubString,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12
                                        ),
                                      )
                                    ],
                                  ),
                                  footer: Text(
                                    formatCurrency.format(snapshot['bcg_price'])+"원",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                )
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            //베이스메이크업
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 4),
                      child: RefreshIndicator(
                        color: primaryColor,
                        onRefresh: _refresh,
                        child: GridView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: baseData.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.84,
                          ),
                          shrinkWrap: true, 
                          itemBuilder: (context, index) {
                            dynamic snapshot = baseData[index];
                            var nameSubString = snapshot['bcg_name'].toString();
                            bool isLike = userLikeList.contains(snapshot['bcg_key']);
                            if(nameSubString.length>20){
                              nameSubString = nameSubString.substring(0,19);
                            }
                            return InkWell(
                              onTap: () async{
                                await Get.to(() => GoodsDetailPage(bcgKey: snapshot['bcg_key'], bcgName: snapshot['bcg_name']));
                                getlikeData();
                                getBasketCount();
                              },
                              child: Container(
                                child : GridTile(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
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
                                      Text(
                                        nameSubString,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12
                                        ),
                                      )
                                    ],
                                  ),
                                  footer: Text(
                                    formatCurrency.format(snapshot['bcg_price'])+"원",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                )
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            //포인트메이크업
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 4),
                      child: RefreshIndicator(
                        color: primaryColor,
                        onRefresh: _refresh,
                        child: GridView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: pointData.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.84,
                          ),
                          shrinkWrap: true, 
                          itemBuilder: (context, index) {
                            dynamic snapshot = pointData[index];
                            var nameSubString = snapshot['bcg_name'].toString();
                            bool isLike = userLikeList.contains(snapshot['bcg_key']);
                            if(nameSubString.length>20){
                              nameSubString = nameSubString.substring(0,19);
                            }
                            return InkWell(
                              onTap: () async{
                                await Get.to(() => GoodsDetailPage(bcgKey: snapshot['bcg_key'], bcgName: snapshot['bcg_name']));
                                getlikeData();
                                getBasketCount();
                              },
                              child: Container(
                                child : GridTile(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
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
                                      Text(
                                        nameSubString,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12
                                        ),
                                      )
                                    ],
                                  ),
                                  footer: Text(
                                    formatCurrency.format(snapshot['bcg_price'])+"원",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                )
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ],
          controller: _tabController,
        ),
      )
    );
  }
}