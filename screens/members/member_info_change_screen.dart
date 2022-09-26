import 'package:best_cosmetics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/screens/login/login_form_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:kpostal/kpostal.dart';

class MemberInfoChangeScreen extends StatefulWidget {
  const MemberInfoChangeScreen({Key? key}) : super(key: key);

  @override
  State<MemberInfoChangeScreen> createState() => _MemberInfoChangeScreenState();
}

class _MemberInfoChangeScreenState extends State<MemberInfoChangeScreen> {
  bool isLoding = true;
  final formKey = new GlobalKey<FormState>();
  final TextEditingController _zipcodeController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();
  final TextEditingController _phone3Controller = TextEditingController();

  final session = FlutterSecureStorage();
  MemberGet memberGet = new MemberGet();
  var emailRegexp = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  dynamic userdata;
  var MemberData = {};

  String id = "";
  String login = "";
  String email = "";
  String snsEmail = "";
  String name = "";

  String firstEmail = "";
  String secondEmail = "";
  String phone1 = "";
  String phone2 = "";
  String phone3 = "";
  String zipcode = "";
  String address1 = "";
  String address2 = "";

  @override
  void initState() {
    getSessionInfo();
    super.initState();
  }

  getSessionInfo() async {
    userdata = await memberGet.getUser();
    login = userdata.userLogin.toString();
    id = userdata.userId.toString();
    name = userdata.userName.toString();

    if(login != 'member') {
      id = "SNS 회원";
      snsEmail = userdata.userEmail.toString();
    }
    _emailController.text = userdata.userEmail.toString();
    setState(() {});
    getUserInfo();
  }

  getUserInfo() async {
    var url = Uri.parse("${adminIp}/api/getUserInfo");
    //print(url);
    http.Response response = await http.post(
      url,
      body: <String, String> {
        "num" : userdata.userNum.toString()
      },
    );
    var responseBody = utf8.decode(response.bodyBytes); 
    MemberData = jsonDecode(responseBody);

    if(MemberData['bcm_phonenum1'] != null) {
      _phone1Controller.text = MemberData['bcm_phonenum1'];
      _phone2Controller.text = MemberData['bcm_phonenum2'];
      _phone3Controller.text = MemberData['bcm_phonenum3'];
    }
    if(MemberData['bcm_zipcode'] != null) {
      _zipcodeController.text = MemberData['bcm_zipcode'].toString();
      _address1Controller.text = MemberData['bcm_address1'].toString();
      _address2Controller.text = MemberData['bcm_address2'].toString();
    }

    setState(() { 
    });
    isLoding = false;
  }

  updateUserInfo() async {
    List<String> emails = email.split("@");

    var url = Uri.parse("${adminIp}/api/updateUserInfo");
    //print(url);
    await http.post(
      url,
      body: <String, String> {
        "num" : userdata.userNum.toString(),
        "firstEmail" : emails[0],
        "secondEmail" : emails[1],
        "phone1" : phone1,
        "phone2" : phone2,
        "phone3" : phone3,
        "zipcode" : zipcode,
        "address1" : address1,
        "address2" : address2,
        "address3" : "",
      },
    );
    showSnackBar(context, "수정 되었습니다.");
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return isLoding ? const Center(child: CircularProgressIndicator(color: Colors.black),) : 
    GestureDetector(
      onTap: () { 
        FocusScope.of(context).unfocus(); 
      },
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: backgroudColor,
        title: Text(
            "회원정보수정",
            style: TextStyle(
              color: primaryColor
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "[필수 입력사항]",
                      style: TextStyle(
                        fontFamily: 'Jua',
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      "아이디 : $id",
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Text(
                      "이름 : $name",
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          "이메일 : ",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: '이메일 입력',
                              hintStyle: TextStyle(
                                color: Colors.black26
                              ),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: _emailController,
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },
                            onSaved: (val) {
                              setState(() {
                                email = val as String;
                              });
                            }, 
                            validator: (val) {
                              if(snsEmail != '' && _emailController.text != snsEmail) {
                                return 'SNS 회원은 이메일을 수정 할 수 없습니다.';
                              }
                              if(val == null || val.isEmpty) {
                                return '이메일을 입력하세요.';
                              }
                              else if(!emailRegexp.hasMatch(val)) {
                                return '이메일 형식에 맞지 않습니다.';
                              }
                              return null;
                            }
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30,),
                    const Text(
                      "[선택 입력사항]",
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Jua'
                      ),
                    ),
                    const Text("휴대폰"),
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: "010",
                              hintStyle: const TextStyle(
                                color: Colors.black26
                              ),
                              counterText: '',
                              contentPadding: const EdgeInsets.only(left:16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            controller: _phone1Controller,
                            maxLength: 3,
                            keyboardType: TextInputType.number,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            inputFormatters:[FilteringTextInputFormatter(RegExp('[0-9]'),allow:true),],
                            onSaved: (val) {
                              setState(() {
                                phone1 = val as String;
                              });
                            }, 
                          ),
                        ),
                        const SizedBox(width: 8,),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: "0000",
                              hintStyle: const TextStyle(
                                color: Colors.black26
                              ),
                              counterText: '',
                              contentPadding: const EdgeInsets.only(left:16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            maxLength: 4,
                            controller: _phone2Controller,
                            keyboardType: TextInputType.number,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            inputFormatters:[FilteringTextInputFormatter(RegExp('[0-9]'),allow:true),],
                            onSaved: (val) {
                              setState(() {
                                phone2 = val as String;
                              });
                            }, 
                          ),
                        ),
                        const SizedBox(width: 8,),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: "0000",
                              hintStyle: const TextStyle(
                                color: Colors.black26
                              ),
                              counterText: '',
                              contentPadding: const EdgeInsets.only(left:16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            maxLength: 4,
                            controller: _phone3Controller,
                            keyboardType: TextInputType.number,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            inputFormatters:[FilteringTextInputFormatter(RegExp('[0-9]'),allow:true),],
                            onSaved: (val) {
                              setState(() {
                                phone3 = val as String;
                              });
                            }, 
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    const Text("주소"),
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left:16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: '우편번호',
                              hintStyle: const TextStyle(
                                color: Colors.black26
                              ),
                            ),
                            readOnly: true,
                            onSaved: (val) {
                              setState(() {
                                zipcode = val as String;
                              });
                            },
                            controller: _zipcodeController,
                          )
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: InkWell(
                            child: Container(
                              height: 55,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "우편번호 찾기", style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            onTap: () async{
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => KpostalView(
                                    useLocalServer: true,
                                    localPort: 8081,
                                    kakaoKey: '1524818cf18610267a911db9915ef7fa',
                                    callback: (Kpostal result) {
                                      setState(() {
                                        zipcode = result.postCode;
                                        address1 = result.address;
                                         _zipcodeController.text = zipcode;
                                         _address1Controller.text = address1;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5,),
                    TextFormField(
                      decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left:16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: '주소',
                            hintStyle: const TextStyle(
                              color: Colors.black26
                            ),
                          ),
                          readOnly: true,
                          onSaved: (val) {
                            setState(() {
                              address1 = val as String;
                            });
                          },
                          controller: _address1Controller,
                    ),
                    const SizedBox(height: 5,),
                    TextFormField(
                      decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left:16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: '상세 주소를 입력하세요.',
                            hintStyle: const TextStyle(
                              color: Colors.black26
                            ),
                          ),
                          onSaved: (val) {
                            setState(() {
                              address2 = val as String;
                            });
                          },
                          controller: _address2Controller,
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.black87),
                              padding: MaterialStateProperty.all(const EdgeInsets.only(left : 151, right: 151, top: 20, bottom: 20)),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            ),
                            onPressed: () {
                              if(formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                updateUserInfo();
                              }
                            },
                            child: const Text(
                              '수정',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Jua',
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}