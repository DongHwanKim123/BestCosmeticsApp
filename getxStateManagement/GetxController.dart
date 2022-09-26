import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuilderController extends GetxController {
 int goodsCount = 1;

 increment() {
  goodsCount++;
  update();
 }
 decrement() {
  goodsCount--;
  update();
 } 

}