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

class MemberOut extends StatefulWidget {
  const MemberOut({Key? key}) : super(key: key);

  @override
  State<MemberOut> createState() => _MemberOutState();
}

class _MemberOutState extends State<MemberOut> {
  bool _isChecked = false;
  final session = FlutterSecureStorage();
  dynamic userdata;
  MemberGet memberGet = new MemberGet();
  
  deleteMember() async {
    userdata = await memberGet.getUser();
    var url = Uri.parse("${adminIp}/api/deleteMember");
    http.Response response = await http.post(
      url,
      body: <String, String> {
        "bcm_num" : userdata.userNum.toString()
      },
    );
    String result = utf8.decode(response.bodyBytes);
    // var responseBody = utf8.decode(response.bodyBytes); 
    // MemberData = jsonDecode(responseBody);
    if(result == '탈퇴완료') {
      await session.deleteAll();
      showSnackBar(context, "이용해주셔서 감사합니다.");
      Get.offAll(LoginForm());
    }
    else {
      showSnackBar(context, "탈퇴 에러");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroudColor,
        title: Text(
          "회원탈퇴",
          style: TextStyle(
            color: primaryColor
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "저희 BestCosmetic을",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700
              ),
            ),
            Text(
              "이용해 주셔서 감사합니다.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700
              ),
            ),
            Text(
              "회원탈퇴 시 모든 회원정보와 구매내역 등이",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700
              ),
            ),
            Text(
              "자동으로 삭제 처리되며, 복구가 불가합니다.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700
              ),
            ),
            Text(
              "< 자동 삭제 항목(복구 불가능) >",
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.w700
              ),
            ),
            Text(
              "회원정보, 상품구매 등의 모든 내역",
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.w700
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _isChecked, 
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value!;
                      print(_isChecked);
                    });
                  }
                ),
                Text("회원 탈퇴에 대한 동의(필수)")
              ],
            ),
            Text(
              "위 내용을 모두 확인하였으며,",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700
              ),
            ),
            Text(
              "모든 정보는 복구가 불가능합니다.",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700
              ),
            ),
            Text(
              "회원 탈퇴에 동의하시겠습니까?",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                if(_isChecked) {
                  await deleteMember();
                  await session.deleteAll();
                  showSnackBar(context, "이용해주셔서 감사합니다.");
                  Get.offAll(() =>LoginForm());
                }
                else {
                  showSnackBar(context, "회원 탈퇴에 대한 동의를 체크해주세요.");
                }
              }, 
              child: Text(
                "회원 탈퇴",
                style: TextStyle(
                  color: Colors.black
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}