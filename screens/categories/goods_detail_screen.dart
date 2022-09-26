import 'package:badges/badges.dart';
import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/screens/baskets/basket_screen.dart';
import 'package:best_cosmetics/screens/baskets/payment_screen.dart';
import 'package:best_cosmetics/screens/navigation_screen.dart';
import 'package:best_cosmetics/screens/search/search_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:best_cosmetics/utils/utils.dart';
import 'package:best_cosmetics/widgets/like_animation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_share.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GoodsDetailPage extends StatefulWidget {
  final int bcgKey;
  final String bcgName;
  const GoodsDetailPage({Key? key, required this.bcgKey, required this.bcgName}) : super(key: key);

  @override
  State<GoodsDetailPage> createState() => _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> with TickerProviderStateMixin{
  final formatCurrency = new NumberFormat.simpleCurrency(locale: "ko.KR",name: "",decimalDigits: 0);
  final date = new DateFormat('yyyy-MM-dd HH:mm');
  final date2 = new DateFormat('yyyy년 MM월 dd일');
  var item;
  var detail;
  bool isLoading = false;
  late TabController _nestedTabController;
  bool isLikeAnimating = false;
  late ScrollController _scrollController;
  late ScrollController _questionController;
  late ScrollController _reviewController;
  late ScrollController _orderInfoController;
  int likes = 0;
  String count = "";
  bool isOptionSelected = false;
  List<Map<String,dynamic>> smallBasket = [];
  bool optionSelected = false;
  int price = 0;
  int totalPrice = 0;
  int goodsCount = 0;
  dynamic userdata;
  var userLikeList = [];
  bool isLike =false;
  bool _isChecked = false;
  var question;
  var questionData=[];
  List questionList = [];
  String bcq_content = "";
  String bcg_info = "";
  String bcg_date = "";
  String bcq_secret = "";
  String bcg_key = "";
  String strImg ="";
  String bcg_name = "";
  String strDetailImg ="";
  TextEditingController _questionTextController = TextEditingController();
  String basketCount="";
  int questionLength = 0;
  int reviewLength = 0;
  List reviewList=[];
  double scoreAverage = 0;

  @override
  void initState() {
    super.initState();

    _nestedTabController = new TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    _questionController = ScrollController();
    _reviewController = ScrollController();
    _orderInfoController = ScrollController();
    getlikeData();
    getDetailData();
    getQuestionListData();
    getReviewListData();
    getBasketCount();
  }
  
  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
    _scrollController.dispose();
    _questionController.dispose();
    _questionTextController.dispose();
    _reviewController.dispose();
    _orderInfoController.dispose();
  }

  getDetailData () async {
    setState(() {
      isLoading = true;
    });

    MemberGet memberGet = new MemberGet();
    userdata = await memberGet.getUser();


    var url = Uri.parse("${adminIp}/api/goodsDetailView?bcgKey=${widget.bcgKey}");

    http.Response response = await http.get(
      url,
      headers : {"Accept" : "application/json"}
    );
    var responseBody = utf8.decode(response.bodyBytes);
    var Data = jsonDecode(responseBody);
    //print(Data);
    item = Data['item'];
    detail = Data['detail'];
    likes = item['bcg_like'];
    price = item['bcg_price'];
    isLike = userLikeList.contains(item['bcg_key']);
    strImg = item['bcg_img'].toString();
    bcg_name = item['bcg_name'].toString();
    strDetailImg = item['bcg_imgdetail'].toString();
    bcg_info = item['bcg_info'];
    bcg_date = date2.format(DateTime.parse(item['bcg_date']).add(new Duration(hours: 9)));
    bcg_key = item['bcg_key'].toString();

    setState(() {
      isLoading = false;
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
    basketCount = Data.toString();
    setState(() {
      
    });
  }

  getlikeData () async {
    setState(() {
      isLoading = true;
    });
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
      isLoading = false;
    });
  }
  
  favoriteCount () async {

    var url = Uri.parse("${adminIp}/api/goods/favoriteCount");

    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/x-www-form-urlencoded',
      },
      body: <String, String> {
        "bcgKey" : widget.bcgKey.toString(),
        "count" : count,
        "bcmNum" : userdata.userNum.toString()
      },
    );
  }


  //장바구니넣기
  addBasket() async{
    if(smallBasket.isEmpty){
      Get.snackbar("텅~","옵션을 선택해주세요.",snackPosition: SnackPosition.BOTTOM, duration: Duration(milliseconds: 1500),backgroundColor: Colors.black,colorText: Colors.white);
      return;
    }
    for(int i = 0; i<smallBasket.length; i++){
      smallBasket[i]['bcmNum'] = userdata.userNum.toString();
    }
    var url = Uri.parse("${adminIp}/api/member/basket/add");

    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/json',
      },
      body: json.encode(smallBasket),
    );
    Get.back();
    showSnackBar(context, "장바구니에 상품이 담겼습니다.");
    getBasketCount();
    smallBasket.clear();
    optionSelected = false;
  }

  toPayment() {
    if(smallBasket.isEmpty){
      Get.snackbar("텅~","옵션을 선택해주세요.",snackPosition: SnackPosition.BOTTOM, duration: Duration(milliseconds: 1500),backgroundColor: Colors.black,colorText: Colors.white);
      return;
    }
    List orderList = [];
    
    for(int i = 0; i<smallBasket.length; i++) {
      orderList.add({
        'bcg_name' : item['bcg_name'],
        'bcg_price' : item['bcg_price'],
        'bcg_key' : item['bcg_key']
      });

      orderList[i]['bcb_count'] = smallBasket[i]['count'];
      orderList[i]['bcd_detailkey'] = smallBasket[i]['bcd_detailkey'];
    }

    //print(orderList);
    Get.back();
    Get.to(() => PaymentScreen(orderList: orderList),transition: Transition.rightToLeft);
  }

  //문의 리스트
  getQuestionListData () async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse("${adminIp}/api/goodsQuestionList?bcgKey=${widget.bcgKey}");

    http.Response response = await http.get(
      url,
      headers : {"Accept" : "application/json"},
    );
    var responseBody = utf8.decode(response.bodyBytes);
    var questionData = jsonDecode(responseBody);
    //print(responseBody);

    questionList = questionData;
    questionLength = questionList.length;
    print(questionLength);
    setState(() {
      isLoading = false;
    });
  }
  
  //리뷰리스트
  getReviewListData () async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse("${adminIp}/api/member/review/list?bcgKey=${widget.bcgKey}");

    http.Response response = await http.get(
      url,
      headers : {"Accept" : "application/json"},
    );
    var responseBody = utf8.decode(response.bodyBytes);
    reviewList = jsonDecode(responseBody);
    print(reviewList);
    reviewLength = reviewList.length;

    for(int i = 0; i<reviewLength; i++) {
      scoreAverage +=  (reviewList[i]['bcr_score'] / reviewLength);
    }

    setState(() {
      isLoading = false;
    });
  }


  toQuestion(String questionContent)async{
    if(_questionTextController.text == "") {
      showSnackBar(context, "내용이 없네욤");
      return;
    };
    String secret = "off";
    if(_isChecked == true) {
      secret = "on";
    } 
    var formUrl = "${adminIp}/api/question";
    var url = Uri.parse(formUrl);
    http.Response response = await http.post(
      url,
      body: <String, String> {
        'bcg_key' :  item['bcg_key'].toString(),
        'bcg_name': item['bcg_name'].toString(),
        'bcm_num' : userdata.userNum.toString(),
        'bcm_name' : userdata.userName.toString(),
        'bcq_content' : questionContent,
        'bcq_secret' : secret,
      }
    );
    _questionTextController.clear();
    showSnackBar(context, "문의가 등록되었습니다.");
    getQuestionListData();
  }

  void _questionSubmit (String bcq_content) {
    toQuestion(bcq_content);
  }
  void _launchURL(url) async {
    await launchUrlString(url);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Get.offAll(() => NavigationScreen());
            }, 
            icon: Icon(
              Icons.home_outlined
            )
          ),
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
      body: 
      isLoading
      ? const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      )
      : Stack(
        alignment: Alignment.center,
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            controller: _scrollController,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInImage.assetNetwork(
                        width: MediaQuery.of(context).size.width,
                        image : strImg,
                        placeholder: 'assets/images/Spinner.gif',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {}, 
                                    icon: Icon(
                                      isLike ? Icons.favorite : Icons.favorite_outline_outlined,
                                      color:  isLike ? Colors.red :Colors.black45,
                                    )
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${likes.toString()}명이 찜 하고 있습니다.",
                                      style: TextStyle(
                                        color: Colors.black38
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      KakaoSdk.init(nativeAppKey: '7a2f3513d4d88cdbd3fea8c2dd24344a');
                                      CommerceTemplate defaultCommerce = CommerceTemplate(
                                        content: Content(
                                          title: bcg_name,
                                          imageUrl: Uri.parse(strImg),
                                          link: Link(
                                            mobileWebUrl: Uri.parse('${adminIp}/guest/detailPage?BCG_KEY=$bcg_key'),
                                          ),
                                        ),
                                        commerce: Commerce(
                                          regularPrice: price,
                                          productName: bcg_name,
                                          currencyUnit: "원",
                                          currencyUnitPosition: 0,
                                        ),
                                        buttons: [
                                          Button(
                                            title: '구매하기',
                                            link: Link(
                                              mobileWebUrl: Uri.parse('${adminIp}/guest/detailPage?BCG_KEY=$bcg_key'),
                                            ),
                                          ),
                                        ],
                                      );
                                      Uri uri = await ShareClient.instance.shareDefault(template: defaultCommerce);
                                      await ShareClient.instance.launchKakaoTalk(uri);
                                    }, 
                                    icon: Icon(
                                      Icons.share_outlined,
                                      color: Colors.black,
                                    )
                                  )
                                ],
                              ),
                            ),
                            Text(
                              bcg_name,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top :8.0,bottom: 8.0),
                              child: Text(
                                formatCurrency.format(price)+"원",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700
                                ),
                              ),
                            ),
                            Divider(),
                            Container(
                              child: Column(
                                children: <Widget>[
                                  TabBar(
                                    controller: _nestedTabController,
                                    indicatorColor: primaryColor,
                                    labelColor: primaryColor,
                                    isScrollable: true,
                                    unselectedLabelColor: Colors.black54,
                                    tabs: <Widget>[
                                      Tab(text: "상세정보",),
                                      Tab(
                                        text: reviewLength<1 ? "리뷰" : "리뷰 (${reviewLength})" ,
                                      ),
                                      Tab(
                                        text: questionLength<1 ? "문의" : "문의 (${questionLength})",
                                      ),
                                      Tab(
                                        text: "주문정보",
                                      )
                                    ],
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.6,
                                    child: TabBarView(
                                      controller: _nestedTabController,
                                      children: [
                                        //상세정보
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: SingleChildScrollView(
                                            physics: BouncingScrollPhysics(),
                                            child: Column(
                                              children: [
                                                Image.network( 
                                                  strDetailImg,
                                                  fit: BoxFit.fitWidth,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if(loadingProgress == null) return child;
                                                    return Center(child: CircularProgressIndicator(color: Colors.black),);
                                                  },
                                                ),
                                                SizedBox(height: 50,),
                                                Text("고객센터",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
                                                SizedBox(height: 20,),
                                                Divider(thickness: 1,),
                                                SizedBox(height: 20,),
                                                Row(
                                                  children: [
                                                    Text("카톡 상담"),
                                                    Expanded(flex:2, child: Text("(평일 10:00 ~ 17:00)", style: TextStyle(color: Colors.black38),)),
                                                    Expanded(
                                                      flex: 1,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          KakaoSdk.init(nativeAppKey: '7a2f3513d4d88cdbd3fea8c2dd24344a');
                                                          Uri url = await TalkApi.instance.channelChatUrl('_YxlxmIxj');
                                                          try {
                                                            await launchBrowserTab(url);
                                                          } catch (error) {
                                                            print('에러 : $error');
                                                          }
                                                        },
                                                        child: Image(
                                                          image: AssetImage("assets/images/counseling.png")
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 15,),
                                                Row(
                                                  children: [
                                                    Text("전화 상담"),
                                                    Expanded(child: Text("(평일 10:00 ~ 17:00)", style: TextStyle(color: Colors.black38),)),
                                                    OutlinedButton(
                                                      onPressed: () => _launchURL('tel:010-7188-8309'), 
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.call_outlined,color: Colors.black,),
                                                          SizedBox(width: 1,),
                                                          Text("전화 상담",style: TextStyle(color: Colors.black),),
                                                        ],
                                                      )
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        //리뷰
                                        Container(
                                          decoration: BoxDecoration(
                                            color: backgroudColor,
                                          ),
                                          child: ListView(
                                            physics: BouncingScrollPhysics(),
                                            controller: _reviewController,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top:16),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      color: Colors.yellow,
                                                      size: 30,
                                                    ),
                                                    SizedBox(width: 10,),
                                                    Text(
                                                      scoreAverage.toStringAsFixed(2), 
                                                      style: TextStyle(fontWeight: FontWeight.w700,fontSize: 24),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Divider(thickness: 0.5,),
                                              ListView.builder(
                                                physics: BouncingScrollPhysics(),
                                                itemCount: reviewList.length,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  dynamic snapshot = reviewList[index];
                                                  List<bool> reviewScore = [false,false,false,false,false];
                                                  for(int i=0; i<snapshot['bcr_score'] ; i++){
                                                    reviewScore[i] =true;
                                                  }
                                                  return Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Colors.grey,
                                                          width: 0.2
                                                        )
                                                      )
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                snapshot['bcm_name']
                                                              ),
                                                            ),
                                                            Icon(
                                                              reviewScore[0] ? Icons.star : Icons.star_border_outlined,
                                                              color: Colors.yellow,
                                                            ),
                                                            Icon(
                                                              reviewScore[1] ? Icons.star : Icons.star_border_outlined,
                                                              color: Colors.yellow,
                                                            ),
                                                            Icon(
                                                              reviewScore[2] ? Icons.star : Icons.star_border_outlined,
                                                              color: Colors.yellow,
                                                            ),
                                                            Icon(
                                                              reviewScore[3] ? Icons.star : Icons.star_border_outlined,
                                                              color: Colors.yellow,
                                                            ),
                                                            Icon(
                                                              reviewScore[4] ? Icons.star : Icons.star_border_outlined,
                                                              color: Colors.yellow,
                                                            )
                                                          ],
                                                        ),
                                                        SizedBox(height: 5,),
                                                        Text(
                                                          date.format(DateTime.parse(snapshot['bcr_date']).add(new Duration(hours: 9))), 
                                                          style: TextStyle(color : Colors.black38),
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Container(
                                                          width: MediaQuery.of(context).size.width * 0.88,
                                                          height: MediaQuery.of(context).size.width * 0.3,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius: BorderRadius.circular(16),
                                                                child: 
                                                                (snapshot['bcr_photo'] == null)
                                                                ? Image.asset(
                                                                  "assets/icons/logo.png",
                                                                )
                                                                : Image.network(
                                                                  snapshot['bcr_photo'],
                                                                  width: MediaQuery.of(context).size.width * 0.3,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(10.0),
                                                                  child: Text(
                                                                    snapshot['bcr_content'],
                                                                    overflow: TextOverflow.visible,
                                                                    maxLines: 7,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),

                                                      ],
                                                    ),
                                                  );
                                                }
                                              ),
                                              SizedBox(height: 100,)
                                            ],
                                          ),
                                        ),
                                        //문의
                                        Container(
                                          child: ListView(
                                            physics: BouncingScrollPhysics(),
                                            controller: _questionController,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                                    child: Text(
                                                      "문의 내용 작성", 
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        ),
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    controller: _questionTextController,
                                                    maxLength: 150,
                                                    maxLines: 5,
                                                    decoration: const InputDecoration(
                                                      border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.grey, width: 1.0,
                                                        )
                                                      ),
                                                      hintText: '내용을 입력해주세요.',
                                                    ),
                                                    onFieldSubmitted: _questionSubmit,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Checkbox(
                                                        value: _isChecked, 
                                                        activeColor: Colors.grey,
                                                        onChanged: ((value) {
                                                          setState(() {
                                                            _isChecked = value!;
                                                          });
                                                        })
                                                      ),
                                                      Text("비밀글 여부", style: TextStyle(fontSize: 12),),
                                                      Expanded(
                                                        child: Text("")),
                                                      TextButton(
                                                        style: ElevatedButton.styleFrom(
                                                          primary: Colors.black,
                                                          minimumSize: Size(20,0),
                                                        ),
                                                        onPressed: () {
                                                          _questionSubmit(_questionTextController.text);
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            "등록하기",
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10, ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Q&A", 
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  ListView.builder(
                                                    controller: _questionController,
                                                    physics: NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemCount: questionList.length,
                                                    itemBuilder: (context, index){
                                                      dynamic snapshot = questionList[index];
                                                        return Container(
                                                          width: MediaQuery.of(context).size.width,
                                                          decoration: BoxDecoration(
                                                            border: Border(
                                                              bottom: BorderSide(
                                                                width: 0.3,
                                                                color : secondaryColor
                                                              )
                                                            )
                                                          ), 
                                                          child: ListTile(
                                                            leading: Builder(
                                                              builder: (context) {
                                                                if(snapshot['bca_content'] == null) {
                                                                  return Container( 
                                                                    height: 20,
                                                                    width: 50,
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(),
                                                                    ),
                                                                    child: Center(
                                                                      child: Text(
                                                                        "답변대기",
                                                                        style: TextStyle(
                                                                          color: Colors.black87,
                                                                          fontSize: 10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                else {
                                                                  return  Container( 
                                                                    height: 20,
                                                                    width: 50,
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.black, 
                                                                    ),
                                                                    child: Center(
                                                                      child: Text(
                                                                        "답변완료",
                                                                        style: TextStyle(
                                                                          color: Colors.white,
                                                                          fontSize: 10,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                            title: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  date.format(DateTime.parse(snapshot['bcq_date']).add(new Duration(hours: 9))),
                                                                  style: TextStyle(
                                                                    fontSize: 12,),
                                                                  ),
                                                                  SizedBox(width: 10,),
                                                                Text(snapshot['bcm_name'],
                                                                style: TextStyle(
                                                                    fontSize: 10.5 )),
                                                              ],
                                                            ),
                                                            subtitle: Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                StatefulBuilder(
                                                                  builder: (context, setState) {
                                                                    if(snapshot["bcq_secret"] == "on") {
                                                                      if(snapshot['bcm_num'].toString() != userdata.userNum.toString()) {
                                                                         return Container(
                                                                          child: Row(
                                                                            children: [
                                                                              Icon(Icons.lock_outline, 
                                                                              size: 15),
                                                                              Text("비밀글입니다."),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }else{
                                                                        return Column(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              child:Text(snapshot['bcq_content']),
                                                                            ),
                                                                            Container(
                                                                              child: Container(
                                                                                child: snapshot["bca_content"] == null ?
                                                                                  Text("")
                                                                                  : Text(" ┗ " + snapshot['bca_content'])
                                                                              )
                                                                            ),
                                                                          ],
                                                                        );
                                                                      }
                                                                    } else {
                                                                      return Column(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            child:Text(snapshot['bcq_content']),
                                                                          ),
                                                                          Container(
                                                                            child: Container(
                                                                              child: snapshot["bca_content"] == null ?
                                                                                Text("")
                                                                                : Text(" ┗ " + snapshot['bca_content'])
                                                                            )
                                                                          ),
                                                                        ],
                                                                      );
                                                                    }
                                                                  } )
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                    }),
                                                ],
                                              ),
                                              SizedBox(height: 70,),
                                            ],
                                          ),
                                        ),
                                        //주문정보
                                        Container(
                                          width: MediaQuery.of(context).size.width *0.9,
                                          child: ListView(
                                            physics: BouncingScrollPhysics(),
                                            controller: _orderInfoController,
                                            children: [
                                              SizedBox(height: 50,),
                                              Text("제품요약정보",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
                                              Divider(thickness: 1,),
                                              Text("상품명 : $bcg_name"),
                                              SizedBox(height: 5,),
                                              Text("출시일 : ${bcg_date}"),
                                              SizedBox(height: 5,),
                                              Text("사용 기한 : 개봉 전 24개월/개봉 후 6개월"),
                                              SizedBox(height: 5,),
                                              Text("사용 방법 : 상세페이지 참조"),
                                              SizedBox(height: 5,),
                                              Text("제조 업자 : BestCos(주)"),
                                              SizedBox(height: 5,),
                                              Text("제품 타입 : 모든피부"),
                                              SizedBox(height: 5,),
                                              Text("전성분 : $bcg_info"),
                                              SizedBox(height: 5,),
                                              Text("주의사항 : 1. 화장품 사용시 또는 사용 후 직사광선에 의하여 사용부위가 붉은 반점, 부어오름 또는 가려움증 등의 이상 증상이나 부작용이 있는 경우 전문의 등과 상담할 것 2. 상처가 있는 부위 등에는 사용을 자제할 것 3. 보관 및 취급 시의 주의사항 1) 어린이의 손이 닿지 않는 곳에 보관할 것 2) 직사광선을 피해서 보관할 것"),
                                              SizedBox(height: 5,),
                                              Text("품질보증 : 본 제품에 이상이 있을 경우 공정거래위원회고시 '소비자분쟁해결기준'에 의해 보상해드립니다."),
                                              SizedBox(height: 5,),
                                              Text("소비자상담번호 : 고객서비스 센터 080-380-0114"),
                                              SizedBox(height: 20,),
                                              Text("배송정보",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
                                              Divider(thickness: 1,),
                                              SizedBox(height: 5,),
                                              Text("배송지역 : 전국"),
                                              SizedBox(height: 5,),
                                              Text("배송비 : 무료"),
                                              SizedBox(height: 5,),
                                              Text("베스트코스메틱은 CJ 택배를 이용합니다. 군부대의 경우 주문 단계에서 군부대 배송을 체크하여 주시면, 우체국 택배로 발송됩니다. 단, 택배 송장 번호 확인시 CJ 택배 송장이 표기되며, 우체국 송장 번호는 고객 상담실로 전화 주시면 확인 가능합니다."),
                                              SizedBox(height: 5,),
                                              Text("배송예정일 : 평일 오후 2시 이전 주문 건은 당일 출고되며, 그 후 주문 건은 다음 날 출고됩니다. 보통 주문일로부터 평일 기준 2~3일 소요되며, 주말/공휴일이 포함되거나 할인 행사로 인한 주문 폭주 및 택배사의 사정 등으로 인한 경우 배송이 지연될 수 있습니다."),
                                              SizedBox(height: 5,),
                                              Text("상품 불량 및 오배송 등으로 인한 교환/반품신청의 경우 배송비는 무료 입니다."),
                                              SizedBox(height: 5,),
                                              Text("고객님의 단순 변심으로 인한 교환/반품 신청은 고객님께서 왕복배송비 5,000원을 부담해 주셔야 처리가 됩니다. 제일은행 325-20-460048 (주)베스트코스메틱"),
                                              SizedBox(height: 5,),
                                              Text("주의사항 : 한정된 수량으로 더 많은 고객님들께 혜택을 드리기 위하여, 동일 주소지 대량 주문 시 1인 고객으로 집계하여 해당 아이디에 대한 주문이 제한될 수 있습니다."),
                                              SizedBox(height: 20,),
                                              Text("교환/반품정보",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
                                              Divider(thickness: 1,),
                                              Text("사은품 품절 시 공지 없이 대체상품이 발송됩니다.",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),),//
                                              SizedBox(height: 5,),
                                              Text("- 단순변심, 착오구매에 따른 교환/반품 신청은 상품을 공급받은 날부터 7일 이내 가능합니다. (배송비 고객 부담)"),
                                              SizedBox(height: 5,),
                                              Text("- 다만, 공급받은 상품이 표시/광고의 내용과 다르거나 계약내용과 다르게 이행된 경우에는 상품을 공급받은 날부터 3개월 이내, 그 사실을 안 날 또는 알 수 있었던 날부터 30일 이내 교환/반품 신청을 하실 수 있습니다. (배송비 회사 부담)"),
                                              SizedBox(height: 5,),
                                              Text("- 교환/반품을 원하는 고객은 쇼핑몰 고객센터 (080-380-0114)에 전화하시거나 쇼핑몰의 [마이페이지>내 주문관리]를 통해 신청하시면 됩니다."),
                                              SizedBox(height: 5,),
                                              Text("- 신청 후 2~3일 이내에 이니스프리 지정 택배사가 직접 방문하여 상품을 수거합니다."),
                                              SizedBox(height: 5,),
                                              Text("- (반송지 주소: 경상북도 김천시 대광동 1000-2번지 아모레퍼시픽 김천물류센터 이니스프리 담당자 : 오연정)"),
                                              SizedBox(height: 5,),
                                              Text("- 해당 상품 구매 시 사은품/증정품 등이 제공된 경우, 상품 교환/반품 시 함께 보내주셔야 합니다."),
                                              SizedBox(height: 5,),
                                              Text("- 반품 시 상품대금 환불은 상품 회수 및 청약철회가 확정된 날부터 3영업일 이내 진행되며, 기한을 초과한 경우 지연기간에 대하여 연 100분의 15를 곱하여 산정한 지연이자를 지급합니다."),
                                              SizedBox(height: 5,),
                                              Text("교환/반품이 불가능한 경우",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),),
                                              SizedBox(height: 5,),
                                              Text("- 고객에게 책임이 있는 사유로 상품이 멸실되거나 훼손된 경우(상품내용을 확인하기 위하여 포장 등을 훼손한 경우는 제외)"),
                                              SizedBox(height: 5,),
                                              Text("- 고객의 사용 또는 일부 소비로 상품 가치가 현저히 감소한 경우"),
                                              SizedBox(height: 5,),
                                              Text("- 시간이 지나 다시 판매하기 곤란할 정도로 상품 가치가 현저히 감소한 경우"),
                                              SizedBox(height: 5,),
                                              Text("- 복제가 가능한 상품의 포장을 훼손한 경우"),
                                              SizedBox(height: 5,),
                                              Text("- 고객의 주문에 따라 개별적으로 생산되는 상품 또는 이와 유사한 상품에 대하여 청약철회등을 인정하는 경우"),
                                              SizedBox(height: 5,),
                                              Text("- 통신판매업자에게 회복할 수 없는 중대한 피해가 예상되는 경우로서 사전에 해당 거래에 대하여 별도로 그 사실을 고지하고 고객의 서면(전자문서 포함)에 의한 동의를 받은 경우"),
                                              SizedBox(height: 5,),
                                              Text("- 오프라인 매장에서 구매한 제품은 불가능"),
                                              SizedBox(height: 5,),
                                              Text("불만처리 및 분쟁해결",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),),
                                              SizedBox(height: 5,),
                                              Text("- 교환/반품/대금 환불 등에 대한 문의사항 및 불만처리 요청은 쇼핑몰 고객센터 [080-380-0114] 혹은 1:1 고객문의 게시판을 이용하세요."),
                                              SizedBox(height: 5,),
                                              Text("- 고객센터 운영시간: (월~목) 09:00~18:00 , (금) 09:00~17:30 , 토/일/공휴일 휴무"),
                                              SizedBox(height: 5,),
                                              Text("- 본 상품의 품질보증 및 피해보상에 관한 사항은 관련 법률 및 공정거래위원회 고시 「소비자분쟁해결기준」에 따릅니다."),
                                              SizedBox(height: 5,),
                                              Text("- 트러블에 의한 반품 시 의사의 소견서를 첨부해야 하며 기타 제반 비용은 고객님이 부담하셔야 합니다."),
                                              SizedBox(height: 5,),
                                              Text("- 다만, 의사의 소견에 따라 구매 상품의 사용으로 인한 사유가 명백한 경우 소비자분쟁해결기준에 따릅니다."),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 70,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 70,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: wigetColor,
                border: Border(
                    top: BorderSide(
                    width: 1.0,
                    color: Colors.black12
                  )
                )
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: wigetColor,
                      border: Border.all(
                        width: 1.5,
                        color: secondaryColor
                      )
                    ),
                    child: IconButton(
                      icon: Icon(
                        isLike ? Icons.favorite : Icons.favorite_outline_outlined,
                        color: isLike ? Colors.red : secondaryColor,
                      ),
                      onPressed: () {
                        if(isLike){
                          setState(() {
                            likes = likes-1;
                            showSnackBar(context, "찜 목록에서 삭제 되었습니다.");
                            count = "down";
                            isLike=false;
                          });
                          favoriteCount();
                        }else{
                          setState(() {
                            isLikeAnimating = true;
                            likes = likes+1;
                            count = "up";
                            isLike=true;
                          });
                          favoriteCount();
                        }
                      },
                    )
                  ),
                  Expanded(
                    child: InkWell(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.black
                        ),
                        child: Center(
                          child: Text(
                            "구매하기",
                            style: TextStyle(
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                      onTap: openBottomSheet,
                    ),
                  )
                ]
              ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: isLikeAnimating ? 1 : 0,
            child: LikeAnimation(
              isAnimating: isLikeAnimating,
              child: const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 150,
              ),
              duration: const Duration(
                milliseconds: 400,
              ),
              onEnd: () {
                setState(() {
                  isLikeAnimating = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }


  void openBottomSheet() {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (BuildContext buildContext, StateSetter setState) {
          return 
          optionSelected == false
          ?
          Container(
            padding: EdgeInsets.all(16),
            height: 500,
            decoration: const BoxDecoration(
              color: backgroudColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20)
              )
            ),
            child: ListView(
              children: [
                Text(
                  "옵션", style : TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
                ),
                Divider(),
                ListView.builder(
                  shrinkWrap: true, 
                  itemCount: detail.length,
                  itemBuilder: (context, index) {
                    dynamic snapshot = detail[index];
                    if (snapshot['bcd_option'] == "-"){
                      snapshot['bcd_option'] ="기본 옵션";
                    }
                    return InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 0.5,
                              color: secondaryColor
                            )
                          )
                        ),
                        child: ListTile(
                          title: Text(
                            snapshot['bcd_option'], style: TextStyle(),
                          ),  
                        ),
                      ),
                      onTap: () {
                        totalPrice = 0;
                        goodsCount = 0;
                        if(smallBasket.contains(snapshot)){
                          setState(() {
                            smallBasket[smallBasket.indexOf(snapshot)]['count'] = smallBasket[smallBasket.indexOf(snapshot)]['count']+1; 
                          });
                        }else{
                          setState(() {
                            snapshot['count'] = 1;
                            smallBasket.add(snapshot);
                          });
                        }
                        for(var i=0; i<smallBasket.length; i++){
                          int varPrice = smallBasket[i]['count'] * price;
                          int varCount = smallBasket[i]['count'];
                          totalPrice += varPrice; 
                          goodsCount += varCount;
                        }
                        setState(() {
                          optionSelected = true;
                        });
                      },
                    );
                  }
                )
              ],
            )
          )
          :
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                height: 500,
                decoration: const BoxDecoration(
                  color: backgroudColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)
                  )
                ),
                child: ListView(
                  children: [
                    Text(
                      "옵션", style : TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
                    ),
                    Divider(),
                    InkWell(
                      onTap: () {
                        setState(() {
                          smallBasket;
                          optionSelected = false;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(8),
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 0.5,
                            color : secondaryColor
                          )
                        ),
                        child: Center(child: Text("옵션 선택", style: TextStyle(color: secondaryColor,),)),
                      ),
                    ),
                    Container(
                      height: 260,
                      color: Color.fromRGBO(196, 196, 255, 180),
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: smallBasket.length,
                        itemBuilder: (context, index) {
                          dynamic snap = smallBasket[index];
                          int optionCount = snap['count'];
                          int optionPrice = snap['count'] * price;
                          return Container(
                            margin: EdgeInsets.all(8),
                            height: 105,
                            decoration: BoxDecoration(
                              color: backgroudColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                width: 0.5,
                                color : secondaryColor
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 5.0,
                                  offset: Offset(0,10),
                                )
                              ]
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.only(top : 12, left: 16),
                                        child: Text(
                                          snap['bcd_option']
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          smallBasket.removeAt(index);
                                          totalPrice -= optionPrice;
                                          goodsCount -= optionCount;
                                        });
                                      }, 
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.black38,
                                      )
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if(snap['count'] > 1){
                                            snap['count']=snap['count']-1;
                                            totalPrice -= price;
                                            goodsCount -= 1;
                                          }
                                        });
                                      }, 
                                      icon: Icon(
                                        Icons.remove_circle_outline
                                      )
                                    ),
                                    Text(
                                      snap['count'].toString(), style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if(snap['count'] > 19) {
                                            Get.snackbar("수량","최대 20개 이하만 구매가능합니다.",snackPosition: SnackPosition.BOTTOM, duration: Duration(milliseconds: 1500),backgroundColor: Colors.black,colorText: Colors.white);
                                          } else {
                                            snap['count']=snap['count']+1;
                                            totalPrice += price;
                                            goodsCount += 1;
                                          }
                                        });
                                      }, 
                                      icon: Icon(
                                        Icons.add_circle_outline
                                      )
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(right : 16.0),
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            formatCurrency.format(optionPrice)+" 원", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                                          )
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                bottom: 70,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: wigetColor,
                    border: Border(
                        top: BorderSide(
                        width: 1.0,
                        color: Colors.black12
                      )
                    )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(child: Text(" 총 ${goodsCount}개의 상품", style: TextStyle(color: Colors.black45),)),
                      Text("총 금액"),
                      SizedBox(width: 10,),
                      Text(
                        formatCurrency.format(totalPrice)+"원",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 20),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: wigetColor,
                    border: Border(
                        top: BorderSide(
                        width: 1.0,
                        color: Colors.black12
                      )
                    )
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Color.fromRGBO(196, 196, 255, 50)
                            ),
                            child: Center(
                              child: Text(
                                "장바구니",style: TextStyle(),
                              ),
                            ),  
                          ),
                          onTap: () {
                            addBasket();
                          },
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: InkWell(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.black
                            ),
                            child: Center(
                              child: Text(
                                "바로 구매", style: TextStyle(color: Colors.white),
                              ),
                            )
                          ),
                          onTap: () {
                            toPayment();
                          },
                        ),
                      )
                    ],
                  ),
                )
              )
            ],
          );
        }
      ) 
    );
  }
}