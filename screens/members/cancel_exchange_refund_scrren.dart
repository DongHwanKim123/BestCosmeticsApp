import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/screens/members/order_detail_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:best_cosmetics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

class CERScreen extends StatefulWidget {
  const CERScreen({Key? key}) : super(key: key);

  @override
  State<CERScreen> createState() => _CERScreenState();
}

class _CERScreenState extends State<CERScreen> {
  late ScrollController _scrollController;
  final formatCurrency = new NumberFormat.simpleCurrency(locale: "ko.KR",name: "",decimalDigits: 0);
  final date = new DateFormat('yyyy-MM-dd HH:mm');
  final date2 = new DateFormat('yyyy년 MM월 dd일 HH시 mm분');
  MemberGet memberGet = new MemberGet();
  dynamic userdata;
  var cancelExchangeRefundData = [];

  @override
  void initState() {
    _scrollController = ScrollController();
    getCER();
    super.initState();
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getCER() async{
    userdata = await memberGet.getUser();
    var url = Uri.parse("${adminIp}/api/cancelExchangeRefund");

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
    cancelExchangeRefundData = jsonDecode(responseBody);
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
        "ordernum" : cancelExchangeRefundData[index]['bco_ordernum'],
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
          "취소/교환/반품 목록",
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
                  itemCount: cancelExchangeRefundData.length,
                  itemBuilder: ((context, index) {
                    var snapshot = cancelExchangeRefundData[index];
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
                                      Text(
                                        snapshot["bco_order_status"],
                                        style: TextStyle(fontWeight: FontWeight.w700),
                                      ),
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
}