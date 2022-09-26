import 'package:best_cosmetics/screens/baskets/basket_screen.dart';
import 'package:best_cosmetics/screens/navigation_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:best_cosmetics/screens/login/login_form_screen.dart';

// 백그라운드/중지된 상태에서의 메시지 처리 - 앱에 뱃지 표시 등 ...
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 백그라운드 메시지 핸들러 세팅
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /* Create an Android Notification Channel.
    We use this channel in the `AndroidManifest.xml` file to override the
    default FCM channel to enable heads up notifications. */
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Update the iOS foreground notification presentation options
    // to allow heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  static final session = FlutterSecureStorage();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Best Cosmetics',
      theme: ThemeData.light().copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: backgroudColor,
          iconTheme : IconThemeData(
            color: primaryColor
          ),
          titleTextStyle: TextStyle(
            fontFamily: 'Dongle',
            color: primaryColor,
            fontSize: 30,
            fontWeight: FontWeight.w700
          )
        ),
        scaffoldBackgroundColor: backgroudColor,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.black45,
          actionTextColor: backgroudColor,
          contentTextStyle: TextStyle(  
            fontFamily: 'Jua'
          )
        ),
        primaryColor: Colors.blue,
        canvasColor: Colors.transparent
        
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: "/", page: () => NavigationScreen()),
        GetPage(name: "/basket",page: () => BasketScreen())
      ],
      home: FutureBuilder(
        future: session.read(key: "login"),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          dynamic userInfo = snapshot.data as dynamic; 
          if (userInfo != null) {
            return const NavigationScreen();
          }
          return const LoginForm();
        }
      )
    );
  }
}



