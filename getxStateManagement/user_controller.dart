
import 'package:best_cosmetics/models/userInfo.dart';
import 'package:best_cosmetics/resources/member_get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserController extends GetxController{
  UserInfo? _userInfo; 
  final MemberGet _memberGet = MemberGet();

  UserInfo get getUser => _userInfo!;

  Future<void> refreshUser() async{
    UserInfo userInfo = await _memberGet.getUser();
    _userInfo = userInfo;
    update();
  }

}