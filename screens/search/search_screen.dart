
import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/screens/categories/goods_detail_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:best_cosmetics/widgets/like_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final formatCurrency = new NumberFormat.simpleCurrency(locale: "ko.KR",name: "",decimalDigits: 0);
  String bodyChange = ""; // 검색어 없을때 , 검색어입력중 , 검색어제출
  List searchingList = [];
  List searchList = [];
  final formKey = new GlobalKey<FormState>();
  dynamic userdata;
  var count = "";
  var userLikeList = [];

  @override
  void initState() {
    getlikeData();
    super.initState();
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
  //검색어 입력중 호출 onChanged
  getSearchText(String searchStr) async{
    var url = Uri.parse("${adminIp}/api/search/seaching?seachStr=${searchStr}");
    http.Response response = await http.get(
      url,
    );

    var responseBody = utf8.decode(response.bodyBytes); 
    String json = responseBody;
    searchingList = jsonDecode(json);

    //print(searchingList);
    setState(() {
      
    });
  }

  getSearchAfterSubmitted(String searchStr) async{
    
    var url = Uri.parse("${adminIp}/api/search/submitted?seachStr=${searchStr}");
    http.Response response = await http.get(
      url,
    );
    var responseBody = utf8.decode(response.bodyBytes); 
    String json = responseBody;
    searchList = jsonDecode(json);

    //print(searchList);
    setState(() {
      
    });
  }

  //검색어 누르면 submit되도록 하는 function
  void _fieldSubmit (String searchStr) {
    getSearchAfterSubmitted(searchStr);
    setState(() {
      bodyChange = "검색어제출";
    });
    FocusScope.of(context).unfocus();
    //print(searchStr);
  }

  Future<void> _refresh() {
    return Future.delayed(
      Duration(seconds: 0),
    );
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TextFormField(
            controller: _searchController,
            onFieldSubmitted: _fieldSubmit,
            onChanged: (value) {
              if (value == ""){
                setState(() {
                  bodyChange = "";
                });
              } else {
                getSearchText(value);
                setState(() {
                  bodyChange = "검색어입력중";
                });
              }
            },
            cursorColor: Colors.black,
            autofocus: true,
            style: TextStyle(fontFamily: "NotoSansKR"),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Color.fromRGBO(196, 196, 255, 200),
              hintText: 'BestCosmeics',
              hintStyle: const TextStyle(
                color: Colors.black26
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.black26,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black26)
              )
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              }, 
              child: Text(
                "취소", style: TextStyle(color: Colors.black26),
              )
            )
          ],
        ),
        body: Form(
          child: StatefulBuilder(
            builder: (context, setState) {
              
              if(bodyChange == "검색어제출"){
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
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
                                itemCount: searchList.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.84,
                                ),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  dynamic snapshot = searchList[index];
                                  var nameSubString = snapshot['bcg_name'].toString();
                                  bool isLike = userLikeList.contains(snapshot['bcg_key']);
                                  return InkWell(
                                    onTap: () async{
                                      await Get.to(() => GoodsDetailPage(bcgKey: snapshot['bcg_key'], bcgName: snapshot['bcg_name']));
                                      getlikeData();
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
                                                      onPressed: () {
                                                        if(isLike){
                                                          count = "down";
                                                          favoriteCount(snapshot['bcg_key']);
                                                          isLike=false;
                                                          getlikeData();
                                                          setState(() {});
                                                        }else{
                                                          count = "up";
                                                          favoriteCount(snapshot['bcg_key']);
                                                          isLike=true;
                                                          getlikeData();
                                                          setState(() {});
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
                                },
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }else if (bodyChange == "검색어입력중") { //검색어 입력중 body
                return ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: searchingList.length,
                      itemBuilder: (context,index) {
                        dynamic snapshot = searchingList[index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: InkWell(
                            onTap: () {
                              _searchController.text = snapshot['bcg_name'];
                              _fieldSubmit(_searchController.text);
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 0.2
                                  )
                                )
                              ),
                              child: Text(
                                snapshot['bcg_name'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      }
                    )
                  ],
                ); 
              }else{ //검색어 없을때 body
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children : [
                      
                      Text("추천검색어", style: TextStyle(fontWeight: FontWeight.w700),),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8,top: 16, bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.2
                              )
                            )
                          ),
                          child: Row(
                            children: [
                              Text("1   ", style: TextStyle(fontWeight: FontWeight.w700,color: Colors.redAccent),),
                              Expanded(child: Text("로션")),
                              Text("-", style: TextStyle(color: Colors.black38),)
                            ],
                          ),
                        ),
                        onTap: () {
                          _searchController.text = "로션";
                          _fieldSubmit(_searchController.text);
                        },
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8,top: 16, bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.2
                              )
                            )
                          ),
                          child: Row(
                            children: [
                              Text("2   ", style: TextStyle(fontWeight: FontWeight.w700,color: Colors.redAccent),),
                              Expanded(child: Text("립")),
                              Text("-", style: TextStyle(color: Colors.black38),)
                            ],
                          ),
                        ),
                        onTap: () {
                          _searchController.text = "립";
                          _fieldSubmit(_searchController.text);
                        },
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8,top: 16, bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.2
                              )
                            )
                          ),
                          child: Row(
                            children: [
                              Text("3   ", style: TextStyle(fontWeight: FontWeight.w700,color: Colors.redAccent),),
                              Expanded(child: Text("에센스")),
                              Text("-", style: TextStyle(color: Colors.black38),)
                            ],
                          ),
                        ),
                        onTap: () {
                          _searchController.text = "에센스";
                          _fieldSubmit(_searchController.text);
                        },
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8,top: 16, bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.2
                              )
                            )
                          ),
                          child: Row(
                            children: [
                              Text("4   ", style: TextStyle(fontWeight: FontWeight.w700),),
                              Expanded(child: Text("앰플")),
                              Text("-", style: TextStyle(color: Colors.black38),)
                            ],
                          ),
                        ),
                        onTap: () {
                          _searchController.text = "앰플";
                          _fieldSubmit(_searchController.text);
                        },
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8,top: 16, bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.2
                              )
                            )
                          ),
                          child: Row(
                            children: [
                              Text("5   ", style: TextStyle(fontWeight: FontWeight.w700),),
                              Expanded(child: Text("크림")),
                              Text("-", style: TextStyle(color: Colors.black38),)
                            ],
                          ),
                        ),
                        onTap: () {
                          _searchController.text = "크림";
                          _fieldSubmit(_searchController.text);
                        },
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8,top: 16, bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.2
                              )
                            )
                          ),
                          child: Row(
                            children: [
                              Text("6   ", style: TextStyle(fontWeight: FontWeight.w700),),
                              Expanded(child: Text("스킨")),
                              Text("-", style: TextStyle(color: Colors.black38),)
                            ],
                          ),
                        ),
                        onTap: () {
                          _searchController.text = "스킨";
                          _fieldSubmit(_searchController.text);
                        },
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8,top: 16, bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.2
                              )
                            )
                          ),
                          child: Row(
                            children: [
                              Text("7   ", style: TextStyle(fontWeight: FontWeight.w700),),
                              Expanded(child: Text("오일")),
                              Text("-", style: TextStyle(color: Colors.black38),)
                            ],
                          ),
                        ),
                        onTap: () {
                          _searchController.text = "오일";
                          _fieldSubmit(_searchController.text);
                        },
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8,top: 16, bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.2
                              )
                            )
                          ),
                          child: Row(
                            children: [
                              Text("8   ", style: TextStyle(fontWeight: FontWeight.w700),),
                              Expanded(child: Text("세럼")),
                              Text("-", style: TextStyle(color: Colors.black38),)
                            ],
                          ),
                        ),
                        onTap: () {
                          _searchController.text = "세럼";
                          _fieldSubmit(_searchController.text);
                        },
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8,top: 16, bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.2
                              )
                            )
                          ),
                          child: Row(
                            children: [
                              Text("9   ", style: TextStyle(fontWeight: FontWeight.w700),),
                              Expanded(child: Text("파우더")),
                              Text("-", style: TextStyle(color: Colors.black38),)
                            ],
                          ),
                        ),
                        onTap: () {
                          _searchController.text = "파우더";
                          _fieldSubmit(_searchController.text);
                        },
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8,top: 16, bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.2
                              )
                            )
                          ),
                          child: Row(
                            children: [
                              Text("10   ", style: TextStyle(fontWeight: FontWeight.w700),),
                              Expanded(child: Text("틴트")),
                              Text("-", style: TextStyle(color: Colors.black38),)
                            ],
                          ),
                        ),
                        onTap: () {
                          _searchController.text = "틴트";
                          _fieldSubmit(_searchController.text);
                        },
                      ),
                      
                    ]
                  ),
                );
              }
            }
          ),
        )
        
      ),
    );
  }
}