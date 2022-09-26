import 'dart:ffi';

import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/screens/baskets/basket_screen.dart';
import 'package:best_cosmetics/screens/home/fcm_screen.dart';
import 'package:best_cosmetics/screens/login/login_form_screen.dart';
import 'package:best_cosmetics/screens/members/cancel_exchange_refund_scrren.dart';
import 'package:best_cosmetics/screens/members/member_info_change_screen.dart';
import 'package:best_cosmetics/screens/members/member_out_screen.dart';
import 'package:best_cosmetics/screens/members/order_delivery_screen.dart';
import 'package:best_cosmetics/screens/members/password_change_scrren.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemberScreen extends StatefulWidget {
  const MemberScreen({Key? key}) : super(key: key);

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  final session = FlutterSecureStorage();
  GoogleSignInAccount? _currentUser;
  String? userInfo = "";

  int deliveryReadyCount = 0;
  int inTransitCount = 0;
  int deliveryCompletedCount = 0;

  MemberGet memberGet = new MemberGet();
  dynamic userdata;

  @override
  void initState() {
    super.initState();
    getOrderInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
    setState(() {
      
    });
  }

  _asyncMethod() async {
    userInfo = await session.read(key: "login");
    if (userInfo == null) {
      Get.to(() =>LoginForm());
    }
  }

  getOrderInfo() async {
    userdata = await memberGet.getUser();

    var url = Uri.parse("${adminIp}/api/orderInfo");
    //print(url);
    http.Response response = await http.post(
      url,
      body: <String, String> {
        "num" : userdata.userNum.toString()
      },
    );
    var responseBody = utf8.decode(response.bodyBytes); 
    String json = responseBody;
    var orderInfoData = jsonDecode(json);

    setState(() {
      deliveryReadyCount = orderInfoData["deliveryready"];
      inTransitCount = orderInfoData["intransit"];
      deliveryCompletedCount = orderInfoData["deliverycompleted"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroudColor,
        title: Text(
          "내 정보"
        ),
        actions: [
          IconButton(
            onPressed: () {
              totalLogout();
            }, 
            icon: Icon(
              Icons.logout
            ),
          ),
        ],
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    height: MediaQuery.of(context).size.width * 3/7,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16)
                        ),
                        border: Border.all(
                          width: 0.5,
                          color : secondaryColor
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '배송준비중',
                              style: TextStyle(
                                fontFamily: 'Jua'
                              ),
                            ),
                            Text("$deliveryReadyCount건"),
                          ],
                        )
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    height: MediaQuery.of(context).size.width * 3/7,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16)
                        ),
                        border: Border.all(
                          width: 0.5,
                          color : secondaryColor
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '배송중',
                              style: TextStyle(
                                fontFamily: 'Jua'
                              ),
                            ),
                            Text("$inTransitCount건"),
                          ],
                        )
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    height: MediaQuery.of(context).size.width * 3/7,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16)
                        ),
                        border: Border.all(
                          width: 0.5,
                          color : secondaryColor
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '배송완료',
                              style: TextStyle(
                                fontFamily: 'Jua'
                              ),
                            ),
                            Text("$deliveryCompletedCount건"),
                          ],
                        )
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 10,
            thickness: 10,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.to(() =>BasketScreen(),transition: Transition.rightToLeft);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 0.5,
                            color : secondaryColor
                          ),
                          bottom: BorderSide(
                            width: 0.5,
                            color : secondaryColor
                          )
                        ),
                      ),
                      padding: EdgeInsets.all(20),
                      height: MediaQuery.of(context).size.width * 3/7,
                      child: Container(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 40,
                              ),
                              Text(
                                '장바구니',
                                style: TextStyle(
                                  fontFamily: 'Jua',
                                  fontSize: 20
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await Get.to(()=>OrderDelivery(),transition: Transition.upToDown,);
                      getOrderInfo();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.5,
                          color : secondaryColor
                        ),
                      ),
                      padding: EdgeInsets.all(20),
                      height: MediaQuery.of(context).size.width * 3/7,
                      child: Container(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 40,
                              ),
                              Text(
                                '주문/배송조회',
                                style: TextStyle(
                                  fontFamily: 'Jua',
                                  fontSize: 20
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 10,
            thickness: 10,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.to(()=>CERScreen(),transition: Transition.upToDown,);
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.width * 1/3,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                width: 0.5,
                                color : secondaryColor
                              ),
                              bottom: BorderSide(
                                width: 0.5,
                                color : secondaryColor
                              )
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.keyboard_return_outlined,
                                  size: 40,
                                ),
                                Text(
                                  '취소/교환/반품',
                                  style: TextStyle(
                                    fontFamily: 'Jua',
                                    fontSize: 20
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.to(()=>MemberInfoChangeScreen(),transition: Transition.rightToLeft);
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.width * 1/3,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5,
                              color : secondaryColor
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 40,
                                ),
                                Text(
                                  '회원정보수정',
                                  style: TextStyle(
                                    fontFamily: 'Jua',
                                    fontSize: 20
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.to(() =>PasswordChangeScrren(),transition: Transition.rightToLeft);
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.width * 1/3,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.5,
                                color : secondaryColor
                              )
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cached_outlined,
                                  size: 40,
                                ),
                                Text(
                                  '비밀번호변경',
                                  style: TextStyle(
                                    fontFamily: 'Jua',
                                    fontSize: 20
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.to(() =>MemberOut(),transition: Transition.upToDown,);
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.width * 1/3,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                width: 0.5,
                                color : secondaryColor
                              ),
                              bottom: BorderSide(
                                width: 0.5,
                                color : secondaryColor
                              )
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_remove_alt_1_outlined,
                                  size: 40,
                                ),
                                Text(
                                  '회원탈퇴',
                                  style: TextStyle(
                                    fontFamily: 'Jua',
                                    fontSize: 20
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  totalLogout() async {
    FacebookAuth.instance.logOut();
    GoogleSignIn _googleSignIn = GoogleSignIn();
    _currentUser = await _googleSignIn.signOut();
    FlutterNaverLogin.logOut();

    session.deleteAll();
    Get.offAll(() => LoginForm());
  }
}