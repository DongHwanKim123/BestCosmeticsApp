import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/screens/login/login_form_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:best_cosmetics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordChangeScrren extends StatefulWidget {
  const PasswordChangeScrren({Key? key}) : super(key: key);

  @override
  State<PasswordChangeScrren> createState() => _PasswordChangeScrrenState();
}

class _PasswordChangeScrrenState extends State<PasswordChangeScrren> {
  final session = new FlutterSecureStorage();
  final formKey = new GlobalKey<FormState>();
  var passwordRegexp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?&])[A-Za-z\d$@$!%*#?&]{8,16}$');
  @override
  void initState() {
    userCheck();
    super.initState();
  }
  userCheck() async {
    userdata = await memberGet.getUser();
    if(userdata.userLogin.toString() != "member") {
      showSnackBar(context, "SNS 회원은 비밀번호 변경을 하실 수 없습니다.");
      Get.back();
    }
  }

  String currentPassword = "";
  String newPassword = "";
  String newPasswordCheck = "";
  MemberGet memberGet = new MemberGet();
  dynamic userdata;

  void newPwCheck(val) {
    setState(() {
      newPasswordCheck = val;
    });
  }
  void newPwSave(val) {
    setState(() {
      newPassword = val;
    });
  }
  
  String? userInfo = "";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { 
        FocusScope.of(context).unfocus(); 
      },
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: backgroudColor,
        title: Text(
            "비밀번호 변경",
            style: TextStyle(
              color: primaryColor
            ),
          ),
        ),
        body: ListView(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '비밀번호 변경하기',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Jua',
                    ),
                  ),
                  Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(left:35,right:35,),
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: '현재 비밀번호',
                              hintStyle: TextStyle(
                                color: Colors.black26
                              ),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            obscureText: true,
                            onSaved: (val) {
                              setState(() {
                                currentPassword = val as String;
                              });
                            },
                            validator: (val) {
                              if(val == null || val.isEmpty) {
                                return '현재 비밀번호를 입력해주세요.';
                              }
                              return null;
                            }
                          ),
                          const SizedBox(height: 5,),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: '새로운 비밀번호 입력',
                              hintStyle: TextStyle(
                                color: Colors.black26
                              ),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            obscureText: true,
                            onChanged: (val) {
                              newPwSave(val);
                            },
                            onSaved: (val) {
                              setState(() {
                                newPassword = val as String;
                              });
                            },
                            validator: (val) {
                              if(val == null || val.isEmpty) {
                                return '새로운 비밀번호를 입력해주세요.';
                              }
                              if(!passwordRegexp.hasMatch(val)) {
                                return '비밀번호는 숫자,영문,특수문자를 포함한 8~16자리여야합니다.';
                              }
                              return null;
                            }
                          ),
                          const SizedBox(height: 5,),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: '새로운 비밀번호 확인',
                              hintStyle: TextStyle(
                                color: Colors.black26
                              ),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            obscureText: true,
                            onChanged: (val) {
                              newPwCheck(val);
                            },
                            onSaved: (val) {
                              setState(() {
                                newPasswordCheck = val as String;
                              });
                            },
                            validator: (val) {
                              if(val == null || val.isEmpty) {
                                return '비밀번호 확인은 비워둘 수 없습니다.';
                              }
                              else if(newPassword != newPasswordCheck) {
                                return '새로운 비밀번호와 일치하지 않습니다.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 5,),
                          OutlinedButton(
                            onPressed: () {
                              if(formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                passwordChange();
                              }
                            },
                            child: const Text(
                              '변경하기',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Jua',
                              ),
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  passwordChange() async{
    var formUrl = "$adminIp/api/passwordChange";
    var url = Uri.parse(formUrl);
    http.Response response = await http.post(
      url,
      body: <String, String> {
        'num' : userdata.userNum.toString(),
        'currentPassword' : currentPassword,
        'newPassword' : newPasswordCheck,
      }
    );
    var responseBody = utf8.decode(response.bodyBytes); 

    String result = responseBody;
    print(result);

    if(result == 'success') {
      Get.defaultDialog(
        title: "변경 성공",
        content: const Text("비밀번호가 변경되었습니다, \n    다시 로그인 해주세요.",),
        confirm: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black87),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
          onPressed: () {
            session.delete(key: "login");
            session.delete(key: "Num");
            session.delete(key: "Id");
            session.delete(key: "Name");
            session.delete(key: "Email");
            Navigator.of(context).pop();
            Get.offAll(const LoginForm());
          }, 
          child: const Text("로그인")
        ),
      );
    }
    else {
      Get.defaultDialog(
        title: "변경 실패",
        content: const Text("현재 비밀번호가 일치하지 않습니다."),
        confirm: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black87),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          }, 
          child: const Text("확인")
        ),
      );
    }
  }
}