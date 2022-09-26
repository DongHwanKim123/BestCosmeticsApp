import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/screens/members/member_screen.dart';
import 'package:best_cosmetics/screens/members/order_detail_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:best_cosmetics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderDelivery extends StatefulWidget {
  const OrderDelivery({Key? key}) : super(key: key);

  @override
  State<OrderDelivery> createState() => _OrderDeliveryState();
}

class _OrderDeliveryState extends State<OrderDelivery> {
  late ScrollController _scrollController;
  final formatCurrency = new NumberFormat.simpleCurrency(locale: "ko.KR",name: "",decimalDigits: 0);
  final date = new DateFormat('yyyy-MM-dd HH:mm');
  final date2 = new DateFormat('yyyy년 MM월 dd일 HH시 mm분');
  MemberGet memberGet = new MemberGet();
  dynamic userdata;
  var orderDeliveryData = [];

  @override
  void initState() {
    _scrollController = ScrollController();
    getOrderDelivery();
    super.initState();
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getOrderDelivery() async{
    userdata = await memberGet.getUser();
    var url = Uri.parse("${adminIp}/api/orderdelivery");

    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/x-www-form-urlencoded',
      },
      body: <String, String> {
        "num" : userdata.userNum.toString()
      },
    );
    // print(response.body);
    var responseBody = utf8.decode(response.bodyBytes); 
    orderDeliveryData = jsonDecode(responseBody);
    // print(orderDeliveryData);

    setState(() {});
  }
  statusChange(index, String status) async{
    userdata = await memberGet.getUser();
    var url = Uri.parse("${adminIp}/api/statusChange");

    await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/x-www-form-urlencoded',
      },
      body: <String, String> {
        "num" : userdata.userNum.toString(),
        "status" : status,
        "ordernum" : orderDeliveryData[index]['bco_ordernum'],
      },
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroudColor,
        title: Text(
          "주문/배송조회",
          style: TextStyle(
            color: primaryColor
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        children:[
          Container(
            child: StatefulBuilder(
              builder: (context,StateSetter setState) {
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: orderDeliveryData.length,
                  itemBuilder: ((context, index) {
                    var snapshot = orderDeliveryData[index];
                    return Container(
                      margin: EdgeInsets.only(left: 4, right: 4),
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5,),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          date.format(DateTime.parse(snapshot["bco_orderdate"]).add(new Duration(hours: 9))),
                                          style: TextStyle(
                                            fontFamily: 'Jua',
                                          ),
                                        ),
                                        SizedBox(width: 5,),
                                        Text("|"),
                                        SizedBox(width: 5,),
                                        Text(
                                          snapshot["bco_order_status"],
                                          style: TextStyle(
                                            fontFamily: 'Jua',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  OutlinedButton(
                                    child: Text(
                                      "상세",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    onPressed: () {
                                      String ordernum = snapshot['bco_ordernum'].toString();
                                      String orderdate = date2.format(DateTime.parse(snapshot["bco_orderdate"]).add(new Duration(hours: 9)));
                                      String orderstatus = snapshot['bco_order_status'].toString();
                                      String ordername = snapshot['bco_order_name'].toString();
                                      String totalprice = formatCurrency.format(snapshot['bco_totalprice'])+"원";
                                      Get.to(() =>OrderDetail(orderNum: ordernum, orderdate: orderdate, ordername: ordername, orderstatus: orderstatus,totalprice: totalprice),transition: Transition.rightToLeft);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 0.5,
                          ),
                          Expanded(
                            flex: 8,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Text(
                                        "주문번호 : "+snapshot["bco_ordernum"],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Jua'
                                        ),
                                      ),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16.0),
                                          child: Image.network(
                                            snapshot["bcg_img"],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        snapshot["bco_order_name"],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        formatCurrency.format(snapshot['bco_totalprice'])+"원",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // ElevatedButton(
                                      //   onPressed: () {
                                      //     orderDeliveryData.removeAt(index);
                                      //   }, 
                                      //   child: Text("qqq")
                                      // ),
                                      statusChangeButton(snapshot['bco_order_status'],index),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      )
    );
  }
  Widget statusChangeButton(String status, index) {
    if(status == '배송준비중') {
      return Column(
        children: [
          OutlinedButton(
            child: Text(
              "취소",
              style: TextStyle(
                color: Colors.black
              ),
            ),
            onPressed: () async {
              await statusChange(index, "취소신청");
              setState(() {
                orderDeliveryData.removeAt(index);
              });
              showSnackBar(context, "취소 신청 되었습니다.");
            },
          ),
          OutlinedButton(
            child: Text(
              "교환",
              style: TextStyle(
                color: Colors.black
              ),
            ),
            onPressed: () async {
              await statusChange(index, "교환신청");
              setState(() {
                orderDeliveryData.removeAt(index);
              });
              showSnackBar(context, "교환 신청 되었습니다.");
            },
          ),
        ],
      );
    }
    else if(status == '배송중') {
      return Text("");
    }
    else if(status == '배송완료') {
      return Column(
        children: [
          OutlinedButton(
            child: Text(
              "구매확정",
              style: TextStyle(
                color: Colors.black
              ),
            ),
            onPressed: () async {
              await statusChange(index, "구매확정");
              setState(() {
                orderDeliveryData[index]['bco_order_status'] = "구매확정";
              });
              showSnackBar(context, "구매 해주셔서 감사합니다!");
            },
          ),
          OutlinedButton(
            child: Text(
              "반품",
              style: TextStyle(
                color: Colors.black
              ),
            ),
            onPressed: () async {
              await statusChange(index, "반품신청");
              setState(() {
                orderDeliveryData.removeAt(index);
              });
              showSnackBar(context, "반품 신청 되었습니다.");
            },
          ),
          OutlinedButton(
            child: Text(
              "교환",
              style: TextStyle(
                color: Colors.black
              ),
            ),
            onPressed: () async {
              await statusChange(index, "교환신청");
              setState(() {
                orderDeliveryData.removeAt(index);
              });
              showSnackBar(context, "교환 신청 되었습니다.");
            },
          ),
        ],
      );
    }
    return Text("");
  }
}