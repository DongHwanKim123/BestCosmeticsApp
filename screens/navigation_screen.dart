import 'package:best_cosmetics/getxStateManagement/user_controller.dart';
import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/screens/home/home_screen.dart';
import 'package:best_cosmetics/screens/categories/category_screen.dart';
import 'package:best_cosmetics/screens/like/like_screen.dart';
import 'package:best_cosmetics/screens/members/member_screen.dart';
import 'package:best_cosmetics/screens/baskets/basket_screen.dart';
import 'package:best_cosmetics/screens/members/order_delivery_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:best_cosmetics/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _page = 0;
  final controller = Get.put(UserController());
  late PageController pageController;
  //fcm용
  RemoteMessage? _message;
  String _myText = '';
  dynamic userdata;

  void setToken(String? token) async{
    print('FCM Token: $token');

    MemberGet memberGet = new MemberGet();
    userdata = await memberGet.getUser();
    
    var url = Uri.parse("${adminIp}/api/member/fcmToken");

    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/x-www-form-urlencoded',
      },
      body: <String, String> {
        "bcmNum" : userdata.userNum.toString(),
        "fcmToken" : token.toString()
      },
    );
  }
  
  @override
  void initState() {
    controller.refreshUser();
    super.initState();
    pageController = PageController();
    fcmService();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }
  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  fcmService () {
    // 앱이 시작될 때 확인 안 한 메시지가 있다면 여기서 나온다. 없다면 null
    // 여러개가 있다면 가장 최근의 것이 나온다.
    FirebaseMessaging.instance.getInitialMessage()
      .then((RemoteMessage? message) {
        print('aaaaaa ======================================');
        print(message?.data['message']);
        if (message != null) {
          _message = message;
        }
        // callSanckBar(message?.data['message']); // <-- 빌드전이라 에러 발생
      });

    // 앱이 실행 중일 때 알림 메시지가 올 경우 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.notification?.title);// 타이틀 
      print(message.notification?.body); // 바디 
      print(message.data); //{key:value}
      print('bbbbbb ======================================');
      if (message.data['message'] != null) {
        print(message.data['message']);  // 서버에서 푸시 메시지에 사용한 키 값
        showSnackBar(context, message.data['message']);
      } else {
        print('bbbbbb bbbbbb ===============================');
      }

      // 시스템 알림 창에 등록
      /*
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: 'launch_background',
              ),
            ));
      }
      */
    });

    // 앱이 백그라운드에 있을 때 푸쉬 메시지의 내용을 클릭한 경우
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('cccccc ======================================');
      print(message.data['message']);
      _message = message;
    });
 
    // 폰의 토큰을 앱 실행시마다 구해온다.
    FirebaseMessaging.instance
      .getToken(vapidKey: "")
      .then(setToken);
    // _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    // _tokenStream.listen(setToken);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        bottomNavigationBar: CupertinoTabBar(
          backgroundColor: backgroudColor,
          activeColor: primaryColor,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: (_page == 0) ? primaryColor : secondaryColor,
              ),
              label: '홈',
              backgroundColor: primaryColor
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.view_headline_rounded,
                color: (_page == 1) ? primaryColor : secondaryColor,
              ),
              label: '카테고리',
              backgroundColor: primaryColor
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                color: (_page == 2) ? primaryColor : secondaryColor,
              ),
              label: '찜',
              backgroundColor: primaryColor
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: (_page == 3) ? primaryColor : secondaryColor,
              ),
              label: '마이페이지',
              backgroundColor: primaryColor
            ),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
        body: PageView(
        children: [
          HomeScreen(),
          CatecoryScreen(),
          LikeScreen(),
          MemberScreen(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
    );
  }
}


