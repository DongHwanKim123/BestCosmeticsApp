import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/screens/categories/review_write_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderDetail extends StatefulWidget {
  final String orderNum;
  final String orderdate;
  final String orderstatus;
  final String ordername;
  final String totalprice;

  const OrderDetail({Key? key, required this.orderNum,required this.orderdate,required this.orderstatus,required this.ordername,required this.totalprice}) : super(key: key);

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  late ScrollController _scrollController;
  final formatCurrency = new NumberFormat.simpleCurrency(locale: "ko.KR",name: "",decimalDigits: 0);
  final date = new DateFormat('yyyy-MM-dd HH:mm');
  
  MemberGet memberGet = new MemberGet();
  dynamic userdata;
  var orderDetailData = [];


  @override
  void initState() {
    // print(widget.orderNum);
    getOrderDetail();
    _scrollController = ScrollController();
    super.initState();
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getOrderDetail() async{
    userdata = await memberGet.getUser();
    var url = Uri.parse("${adminIp}/api/orderdetail");

    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/x-www-form-urlencoded',
      },
      body: <String, String> {
        "orderNum" : widget.orderNum
      },
    );
    // print(response.body);
    var responseBody = utf8.decode(response.bodyBytes); 
    orderDetailData = jsonDecode(responseBody);
    print(orderDetailData);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroudColor,
        title: Text(
          "주문내역",
          style: TextStyle(
            color: primaryColor
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        children:[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        widget.orderstatus,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        widget.ordername,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: 'Jua',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        "주문일시 : "+widget.orderdate,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black38
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        "주문번호 : "+widget.orderNum,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black38
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(thickness: 1,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: StatefulBuilder(
                builder: (context,StateSetter setState) {
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: orderDetailData.length,
                    itemBuilder: ((context, index) {
                      var snapshot = orderDetailData[index];
                      if(snapshot['bcd_option'] == '-') {
                        snapshot['bcd_option'] = "기본 옵션";
                      }
                      return Container(
                        margin: EdgeInsets.only(left: 4, right: 4),
                        width: MediaQuery.of(context).size.width,
                        height: 170,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 0.3,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Text(
                                    snapshot['bcg_name'],
                                    style: TextStyle(
                                      fontFamily: 'Jua',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 8,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
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
                                    flex: 3,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "기본 : "+formatCurrency.format(snapshot['bcg_price'])+"원",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "옵션 : "+snapshot['bcd_option'],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "수량 : "+snapshot["bco_count"].toString()+"개",
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          formatCurrency.format(snapshot['total_price'])+"원",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        reviewButton(snapshot['bco_reviewcheck'],snapshot['bcg_key'],snapshot['bcg_name'],snapshot['bcg_img']),
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
          ),
          SizedBox(height: 15,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "총 결제금액",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 10,),
                Text(
                  widget.totalprice,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50,),
        ],
      )
    );
  }
  Widget reviewButton(String reviewCheck,int bcgKey, String bcgName, String bcgImg) {
    bool isreview = false;
    if(reviewCheck == 'false' && widget.orderstatus == '구매확정') {
      return OutlinedButton(
        onPressed: () async{
          await Get.to(() => ReviewWriteScreen(bcgKey: bcgKey, bcgName: bcgName, bcgImg : bcgImg, orderNum: widget.orderNum,));
          getOrderDetail();
        }, 
        child: Text(
          "리뷰",
          style: TextStyle(
            color: Colors.black
          ),
        ),
      );
    }
    else if(reviewCheck == 'true' && widget.orderstatus == '구매확정') {
      return Column(
        children: [
          Text("리뷰", style: TextStyle(color: Colors.black38),),
          Text("작성완료", style: TextStyle(color: Colors.black38),),
        ],
      );
    }
    return Text("");
  }
}