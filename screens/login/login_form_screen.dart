import 'package:best_cosmetics/screens/join/join_form_screen.dart';
import 'package:best_cosmetics/screens/navigation_screen.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:best_cosmetics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_keyhash/flutter_facebook_keyhash.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  Map _userObj = {}; // facebook 계정 정보 받는 곳
  GoogleSignInAccount? _currentUser; // google 계정 정보 받는 곳
  Map _naverObj = {}; // 네이버 계정 정보 받는 곳
  Map _kakaObj = {}; // 카카오 계정 정보 받는 곳

  static final session = new FlutterSecureStorage();
  final formKey = new GlobalKey<FormState>();

  String id = "";
  String password = "";
  
  @override
  void initState() {
    // printKeyHash();
    super.initState();
  }


  // @override
  // void initState() {
  //   printKeyHash();
  //   super.initState();
  // }

  // void printKeyHash() async{

  //  String? key=await FlutterFacebookKeyhash.getFaceBookKeyHash ??
  //         'Unknown platform version';
  //  print(key??'');

  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 35),
            child: Row(
              children: const [
                Text(
                  '안녕하세요 :)',
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'Jua',
                    // Jua SingleDay Dongle IBMPlexSansKR NotoSansKR DoHyeon
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 35.0),
            child: Row(
              children: const [
                Text(
                  'Best-Cosmetic 입니다.',
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'Jua',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(35.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    inputFormatters:[FilteringTextInputFormatter(RegExp('[a-zA-Z0-9]'),allow:true),],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: '아이디 입력',
                      hintStyle: const TextStyle(
                        color: Colors.black26
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.disabled,
                    onSaved: (val) {
                      setState(() {
                        id = val as String;
                      });
                    }, 
                    validator: (val) {
                      if(val == null || val.isEmpty) {
                        return '아이디를 입력하세요.';
                      }
                      return null;
                    }
                  ),
                  const SizedBox(height: 5,),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: '비밀번호 입력',
                      hintStyle: const TextStyle(
                        color: Colors.black26
                      ),
                    ),
                    obscureText: true,
                    onSaved: (val) {
                      setState(() {
                        password = val as String;
                      });
                    }, 
                    validator: (val) {
                      if(val == null || val.isEmpty) {
                        return '비밀번호를 입력하세요.';
                      }
                      return null;
                    }
                  ),
                  const SizedBox(height: 5,),
                  renderButton(),
                  const SizedBox(height: 5,),
                  TextButton(
                    onPressed: () {
                      Get.to(() => JoinForm());
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Jua',
                      ),
                    )
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    children: const [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "SNS 계정으로 로그인",
                        style: TextStyle(fontFamily: 'Jua',),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          naverLogin();
                        },
                        child: const Image(
                          image: AssetImage('assets/icons/naver.png'),
                          width: 50,
                          height: 50,
                        ),
                      ),
                      const SizedBox(width: 20,),
                      InkWell(
                        onTap: () {
                          kakaoLogin();
                        },
                        child: const Image(
                          image: AssetImage('assets/icons/kakao.png'),
                          width: 50,
                          height: 50,
                        ),
                      ),
                      const SizedBox(width: 20,),
                      InkWell(
                        onTap: () {
                          googleLogin();
                        },
                        child: const Image(
                          image: AssetImage('assets/icons/google.png'),
                          width: 50,
                          height: 50,
                        ),
                      ),
                      const SizedBox(width: 20,),
                      InkWell(
                        onTap: () async {
                          FacebookAuth.instance.login(
                            permissions: ["public_profile", "email"]).then((value) {
                              FacebookAuth.instance.getUserData().then((userData) async {
                                setState(() {
                                  _userObj = userData;
                                  facebookLogin();
                                });
                              });
                          });
                        },
                        child: const Image(
                          image: AssetImage('assets/icons/facebook.png'),
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  renderButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.black87),
          padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        ),
        onPressed: () {
          if(formKey.currentState!.validate()) {
            formKey.currentState!.save();
            FormCheck();
          }
        },
        child: const Text(
          '로그인',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Jua',
            fontSize: 16,
          ),
        ),
      ),
    );
  }
  

  FormCheck() async {
    var formUrl = "${adminIp}/api/login";

    var url = Uri.parse(formUrl);
    http.Response response = await http.post(
      url,
      body: <String, String> {
        'id' : id,
        'pw' : password
      },
    );
    var responseBody = utf8.decode(response.bodyBytes); 

    String json = responseBody;
    var loginData = jsonDecode(json);
    print(loginData);

    if(loginData["error"] == "ok") {
      session.write(key: "login", value: "member");
      session.write(key: "Num", value: loginData["Num"]);
      session.write(key: "Id", value: loginData["Id"]);
      session.write(key: "Name", value: loginData["Name"]);
      session.write(key: "Email", value: loginData["Email"]);
      setState(() {});
      Get.offAll(NavigationScreen());
    }
    else {
      session.delete(key: "login");
      session.delete(key: "Num");
      session.delete(key: "Id");
      session.delete(key: "Name");
      session.delete(key: "Email");
      showSnackBar(context , loginData["error"].toString());
      formKey.currentState!.reset();
    }
  }

  facebookLogin() async {
    var formUrl = "${adminIp}/api/snsLogin";

    var url = Uri.parse(formUrl);
    http.Response response = await http.post(
      url,
      body: <String, String> {
        'sns' : "facebook",
        'id' : _userObj["id"],
        'name' : _userObj["name"],
        'email' : _userObj["email"],
      },
    );
    var responseBody = utf8.decode(response.bodyBytes); 

    String json = responseBody;
    var facebookData = jsonDecode(json);
    // print(facebookData);
    if(facebookData["error"] == "ok") {
      session.write(key: "login", value: "facebook");
      session.write(key: "Num", value: facebookData["Num"].toString());
      session.write(key: "Id", value: facebookData["Id"]);
      session.write(key: "Name", value: facebookData["Name"]);
      session.write(key: "Email", value: facebookData["Email"]);
      
      setState(() {});
      Get.offAll(NavigationScreen());
    }
  }

  googleLogin() async {
    await googleSign();
    // print(_currentUser);
    String? googleId = _currentUser!.id;
    String? name = _currentUser!.displayName;
    String? googleEmail = _currentUser!.email;
    String googleName = "";
    if(name != null) {
      googleName = name;
    }
    
    var formUrl = "${adminIp}/api/snsLogin";

    var url = Uri.parse(formUrl);
    http.Response response = await http.post(
      url,
      body: <String, String> {
        'sns' : "google",
        'id' : googleId,
        'name' : googleName,
        'email' : googleEmail,
      },
    );
    var responseBody = utf8.decode(response.bodyBytes); 

    String json = responseBody;
    var googleData = jsonDecode(json);
    // print(googleData);
    if(googleData["error"] == "ok") {
      session.write(key: "login", value: "google");
      session.write(key: "Num", value: googleData["Num"].toString());
      session.write(key: "Id", value: googleData["Id"]);
      session.write(key: "Name", value: googleData["Name"]);
      session.write(key: "Email", value: googleData["Email"]);
      
      setState(() {});
      Get.offAll(NavigationScreen());
    }
  }
  naverLogin() async {
    await naverSign();
    
    var formUrl = "${adminIp}/api/snsLogin";

    var url = Uri.parse(formUrl);
    http.Response response = await http.post(
      url,
      body: <String, String> {
        'sns' : "naver",
        'id' : _naverObj['id'],
        'name' : _naverObj['name'],
        'email' : _naverObj['email'],
      },
    );
    var responseBody = utf8.decode(response.bodyBytes); 

    String json = responseBody;
    var naverData = jsonDecode(json);
    print(naverData);
    if(naverData["error"] == "ok") {
      session.write(key: "login", value: "naver");
      session.write(key: "Num", value: naverData["Num"].toString());
      session.write(key: "Id", value: naverData["Id"]);
      session.write(key: "Name", value: naverData["Name"]);
      session.write(key: "Email", value: naverData["Email"]);
      
      setState(() {});
      Get.offAll(NavigationScreen());
    }
  }
  kakaoLogin() async {
    await kakaoSign();
    
    var formUrl = "${adminIp}/api/snsLogin";

    var url = Uri.parse(formUrl);
    http.Response response = await http.post(
      url,
      body: <String, String> {
        'sns' : "kakao",
        'id' : _kakaObj['id'].toString(),
        'name' : _kakaObj['name'],
        'email' : _kakaObj['email'],
      },
    );
    var responseBody = utf8.decode(response.bodyBytes); 

    String json = responseBody;
    var kakaoData = jsonDecode(json);
    print(kakaoData);
    if(kakaoData["error"] == "ok") {
      session.write(key: "login", value: "kakao");
      session.write(key: "Num", value: kakaoData["Num"].toString());
      session.write(key: "Id", value: kakaoData["Id"]);
      session.write(key: "Name", value: kakaoData["Name"]);
      session.write(key: "Email", value: kakaoData["Email"]);
      
      setState(() {});
      Get.offAll(NavigationScreen());
    }
  }


  Future<void> googleSign() async {
      GoogleSignIn _googleSignIn = GoogleSignIn(signInOption: SignInOption.standard);
      _currentUser = await _googleSignIn.signIn();
  }
  Future<void> naverSign() async {
    NaverLoginResult res = await FlutterNaverLogin.logIn();
    _naverObj['id'] = res.account.id;
    _naverObj['name'] = res.account.name;
    _naverObj['email'] = res.account.email;
  }
  Future<void> kakaoSign() async {
    KakaoSdk.init(nativeAppKey: '');
    await UserApi.instance.loginWithKakaoAccount();
    User user = await UserApi.instance.me();
    _kakaObj['id'] = user.id;
    _kakaObj['name'] = user.kakaoAccount!.profile!.nickname;
    _kakaObj['email'] = user.kakaoAccount!.email;
  }
}