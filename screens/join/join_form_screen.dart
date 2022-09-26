import 'package:best_cosmetics/screens/login/login_form_screen.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JoinForm extends StatefulWidget {
  const JoinForm({Key? key}) : super(key: key);

  @override
  State<JoinForm> createState() => _JoinFormState();
}

class _JoinFormState extends State<JoinForm> {
  final formKey = new GlobalKey<FormState>();
  String id = "";
  String password = "";
  String passwordCheck = "";
  String name = "";
  String email = "";

  bool idChecked = false;

  var passwordRegexp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?&])[A-Za-z\d$@$!%*#?&]{8,16}$');
  var nameRegexp = RegExp(r'^[가-힣]*$');
  var emailRegexp = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  void pwCheck(val) {
    setState(() {
      passwordCheck = val;
    });
  }
  void pwSave(val) {
    setState(() {
      password = val;
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { 
        FocusScope.of(context).unfocus(); 
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(30),
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      "회원가입",
                      style: TextStyle(
                        fontFamily: 'Jua',
                        fontSize: 30,
                      ),
                    )
                  ),
                  const SizedBox(height: 20,),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            inputFormatters:[FilteringTextInputFormatter(RegExp('[a-zA-Z0-9]'),allow:true),],
                            decoration: InputDecoration(
                              hintText: '아이디 입력',
                              hintStyle: const TextStyle(
                                color: Colors.black26
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {
                                idChecked = false;
                              });
                            },
                            onSaved: (val) {
                              setState(() {
                                id = val as String;
                              });
                            }, 
                            validator: (val) {
                              if(val == null || val.isEmpty) {
                                return '아이디는 비워둘 수 없습니다.';
                              }
                              else if(val.length < 4 || val.length > 10) {
                                return '아이디는 4~10자리만 가능합니다.';
                              }
                              return null;
                            }
                          ),
                        ),
                        const SizedBox(width: 5,),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.black45),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                          onPressed: () {
                            formKey.currentState!.save();
                            idCheck();
                          }, 
                          child: Text("중복확인")
                        ),
                      ],
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '비밀번호 입력',
                      hintStyle: const TextStyle(
                        color: Colors.black26
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: true,
                    onChanged: (val) {
                      pwSave(val);
                    },
                    onSaved: (val) {
                      setState(() {
                        password = val as String;
                      });
                    },
                    validator: (val) {
                      if(val == null || val.isEmpty) {
                        return '비밀번호는 비워둘 수 없습니다.';
                      }
                      if(!passwordRegexp.hasMatch(val)) {
                        return '비밀번호는 숫자,영문,특수문자를 포함한 8~16자리여야합니다.';
                      }
                      return null;
                    }
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '비밀번호 확인',
                      hintStyle: const TextStyle(
                        color: Colors.black26
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: true,
                    onChanged: (val) {
                      pwCheck(val);
                    },
                    onSaved: (val) {
                      setState(() {
                        passwordCheck = val as String;
                      });
                    },
                    validator: (val) {
                      if(val == null || val.isEmpty) {
                        return '비밀번호를 입력하세요.';
                      }
                      else if(password != passwordCheck) {
                        return '위 비밀번호와 일치하지 않습니다.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '이름 입력',
                      hintStyle: const TextStyle(
                        color: Colors.black26
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onSaved: (val) {
                      setState(() {
                        name = val as String;
                      });
                    }, 
                    validator: (val) {
                      if(val == null || val.isEmpty) {
                        return '이름을 입력하세요.';
                      }
                      else if(val.length < 2) {
                        return '이름은 최소 2자리여야 합니다.';
                      }
                      else if(!nameRegexp.hasMatch(val)) {
                        return '이름을 올바르게 입력해주세요.';
                      }
                      return null;
                    }
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '이메일 입력',
                      hintStyle: const TextStyle(
                        color: Colors.black26
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onSaved: (val) {
                      setState(() {
                        email = val as String;
                      });
                    }, 
                    validator: (val) {
                      if(val == null || val.isEmpty) {
                        return '이메일을 입력하세요.';
                      }
                      else if(!emailRegexp.hasMatch(val)) {
                        return '이메일 형식에 맞지 않습니다.';
                      }
                      return null;
                    }
                  ),
                  const SizedBox(height: 20,),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 65,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.black87),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                      onPressed: () {
                        if(idChecked == false) {
                          Get.defaultDialog(
                            title: "알림",
                            content: Text("아이디 중복확인을 해주세요."),
                            confirm: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.black87),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }, 
                              child: Text("확인")
                            ),
                          );
                        }
                        else {
                          if(formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            createAccount();
                          }
                        }
                      },
                      child: const Text(
                        '가입하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Jua',
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  idCheck() async{
    String contentText = "";
    String titleText = "아이디 중복 확인";
    String buttonText = "";
    var formUrl = "${adminIp}/guest/idCheck";
    var url = Uri.parse(formUrl);
    http.Response response = await http.post(
      url,
      body: <String, String> {
        'id' : '$id',
      }
    );
    // var statusCode = response.statusCode;
    // var responseHeaders = response.headers;
    var responseBody = utf8.decode(response.bodyBytes); 

    // print("statusCode : $statusCode");
    // print("responseHeaders : $responseHeaders");
    // print("responseBody: $responseBody");
    String json = responseBody;
    var idCheckData = jsonDecode(json);
    if(idCheckData["userjson"] == null) {

      contentText = "사용 가능한 아이디 입니다.";
      buttonText = "사용";

      Get.defaultDialog(
        title: titleText,
        content: Text(contentText),
        confirm: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black87),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
          onPressed: () {
            idChecked = true;
            Navigator.of(context).pop();
            FocusManager.instance.primaryFocus?.unfocus();
          }, 
          child: Text(buttonText)
        ),
      );
    }
    else {

      contentText = "중복된 아이디 입니다.";
      buttonText = "재입력";

      Get.defaultDialog(
        title: titleText,
        content: Text(contentText),
        confirm: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black87),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
          onPressed: () {
            idChecked = false;
            Navigator.of(context).pop();
          }, 
          child: Text(buttonText)
        ),
      );
    }
  }
  createAccount() async{

    var formUrl = "${adminIp}/api/appjoin";
    var url = Uri.parse(formUrl);
    http.Response response = await http.post(
      url,
      body: <String, String> {
        'id' : '$id',
        'pw' : '$passwordCheck',
        'name' : '$name',
        'email' : '$email',
      }
    );
    // var statusCode = response.statusCode;
    // var responseHeaders = response.headers;
    var responseBody = utf8.decode(response.bodyBytes); 

    // print("statusCode : $statusCode");
    // print("responseHeaders : $responseHeaders");
    // print("responseBody: $responseBody");
    String json = responseBody;
    var joinData = jsonDecode(json);
    
    if(joinData["result"] == 'success') {
      Get.defaultDialog(
        title: "가입 성공",
        content: Text("회원가입 되었습니다. \n    로그인 해주세요.",),
        confirm: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black87),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            Get.offAll(LoginForm());
          }, 
          child: Text("로그인")
        ),
      );
    }
    else {
      Get.defaultDialog(
        title: "서버 또는 통신 에러",
        content: Text("가입 도중 문제가 발생했습니다.\n관리자에게 문의하세요."),
        confirm: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black87),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          }, 
          child: Text("확인")
        ),
      );
    }
  }
}