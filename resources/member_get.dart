import 'package:best_cosmetics/models/userInfo.dart' as model;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MemberGet {
  final session = new FlutterSecureStorage();

  //사용자정보 가져오기
  Future<model.UserInfo> getUser() async {
    
    dynamic userLogin = await session.read(key: "login");
    dynamic userNum = await session.read(key: "Num");
    dynamic userId = await session.read(key: "Id");
    dynamic userName = await session.read(key: "Name");
    dynamic userEmail = await session.read(key: "Email");

    return model.UserInfo(userNum: userNum , userId: userId, userName: userName, userEmail: userEmail, userLogin: userLogin);
  }
}