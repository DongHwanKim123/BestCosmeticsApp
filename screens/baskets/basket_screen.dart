import 'dart:convert';

import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/screens/baskets/payment_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({Key? key}) : super(key: key);

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  final formatCurrency = new NumberFormat.simpleCurrency(locale: "ko.KR",name: "",decimalDigits: 0);
  late ScrollController _scrollController;
  MemberGet memberGet = new MemberGet();
  var basketData=[];
  dynamic userdata;
  List<bool>? _isChecked;
  int allCount=0;
  int totalPrice=0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getBasket();
    
  }

  getBasket() async{
    userdata = await memberGet.getUser();
    var url = Uri.parse("${adminIp}/api/basketView");
    //print(url);
    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/x-www-form-urlencoded',
      },
      body: <String, String> {
        "bcmNum" : userdata.userNum.toString()
      },
    );
    var responseBody = utf8.decode(response.bodyBytes); 
    String json = responseBody;
    basketData = jsonDecode(json);
    _isChecked = List<bool>.filled(basketData.length,true,growable: true);
    
    setState(() {});
    dataReset();
  }
  
  basketDownCount (int bcgKey, int bcdDetailKey) async {
    var url = Uri.parse("${adminIp}/api/member/basket/downCount");
    //print(url);
    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/x-www-form-urlencoded',
      },
      body: <String, String> {
        "bcmNum" : userdata.userNum.toString(),
        "bcg_key" : bcgKey.toString(),
        "bcd_detailkey" : bcdDetailKey.toString()
      },
    );
    setState(() {});
  }

  basketUpCount (int bcgKey, int bcdDetailKey) async {
    var url = Uri.parse("${adminIp}/api/member/basket/upCount");
    //print(url);
    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/x-www-form-urlencoded',
      },
      body: <String, String> {
        "bcmNum" : userdata.userNum.toString(),
        "bcg_key" : bcgKey.toString(),
        "bcd_detailkey" : bcdDetailKey.toString()
      },
    );
    setState(() {});
  }

  basketDelete (int bcgKey, int bcdDetailKey) async {
    var url = Uri.parse("${adminIp}/api/member/basket/delete");
    //print(url);
    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/x-www-form-urlencoded',
      },
      body: <String, String> {
        "bcmNum" : userdata.userNum.toString(),
        "bcg_key" : bcgKey.toString(),
        "bcd_detailkey" : bcdDetailKey.toString()
      },
    );
    setState(() {});
  }

  dataReset() {
    allCount = 0;
    totalPrice = 0;
    for(int i = 0 ; i<basketData.length ; i++) {
      if(_isChecked?[i] == true){
        int listPrice =  basketData[i]['bcb_count'] * basketData[i]['bcg_price'];
        totalPrice += listPrice;
        allCount += 1;
      } 
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroudColor,
        title: Text(
          "장바구니",
          style: TextStyle(
            color: primaryColor
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            controller: _scrollController,
            children: [
              Container(
                padding: EdgeInsets.only(top: 16, left: 16, bottom: 4),
                child: Text(
                  "담긴 상품",
                  style: TextStyle(fontSize: 20, fontFamily: 'Jua'),
                ),
              ),
              Divider(),
              Container(
                decoration: BoxDecoration(
                  
                ),
                child: StatefulBuilder(
                  builder: (context,StateSetter setState) {
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: basketData.length,
                      itemBuilder: ((context, index) {
                        dynamic snapshot = basketData[index];
                        if (snapshot['bcd_option'] == "-"){
                          snapshot['bcd_option'] =" ";
                        }
                        int optionCount = snapshot['bcb_count'];
                        int optionPrice = snapshot['bcg_price'];
                        int optionTotalPrice = optionCount * optionPrice;
                        return Container(
                          margin: EdgeInsets.only(left: 4,right: 4),
                          width: MediaQuery.of(context).size.width,
                          height: 175,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.3,
                                color : secondaryColor
                              )
                            )
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *0.7,
                                    child: CheckboxListTile(
                                      title: RichText(
                                        text: TextSpan(
                                          text: snapshot['bcg_name'],
                                          style: TextStyle(color: Colors.black87, fontSize: 13)
                                        ),
                                      ),
                                      controlAffinity: 
                                        ListTileControlAffinity.leading,
                                      value: _isChecked?[index],
                                      onChanged: (val) {
                                        setState(() {
                                          _isChecked?[index] = val!;
                                          print(index);
                                          dataReset();
                                        });
                                      },
                                      activeColor: Colors.black,
                                      checkColor: Colors.white,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(right: 24),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.close
                                          ),
                                          onPressed: () {
                                            setState(() { 
                                              basketData.removeAt(index);
                                              _isChecked?.removeAt(index);
                                              basketDelete(snapshot['bcg_key'],snapshot['bcd_detailkey']);
                                              dataReset();
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 24,right: 24, bottom: 16),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16.0),
                                        child: Image.network(
                                          snapshot['bcg_img']
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(top: 16,left: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.only(left: 10),
                                                  child: Text(
                                                    snapshot['bcd_option'], style: (TextStyle(color: Colors.black38 ,fontWeight: FontWeight.w500,fontSize: 12)),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        if(snapshot['bcb_count'] > 1){
                                                          snapshot['bcb_count']= snapshot['bcb_count']-1;
                                                          basketDownCount(snapshot['bcg_key'],snapshot['bcd_detailkey']);
                                                          dataReset();
                                                        }
                                                      });
                                                    }, 
                                                    icon: Icon(
                                                      Icons.remove_circle_outline
                                                    )
                                                  ),
                                                  Text(
                                                    snapshot['bcb_count'].toString(), style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        if(snapshot['bcb_count'] > 19){
                                                          Get.snackbar("수량","최대 20개 이하만 구매가능합니다.",snackPosition: SnackPosition.TOP, duration: Duration(milliseconds: 1500),backgroundColor: Colors.black,colorText: Colors.white);
                                                        }else{
                                                          snapshot['bcb_count']= snapshot['bcb_count']+1;
                                                          basketUpCount(snapshot['bcg_key'],snapshot['bcd_detailkey']);
                                                          dataReset();
                                                        }
                                                      });
                                                    }, 
                                                    icon: Icon(
                                                      Icons.add_circle_outline
                                                    )
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(right : 16.0),
                                                      child: Align(
                                                        alignment: Alignment.bottomRight,
                                                        child: Text(
                                                          formatCurrency.format(optionTotalPrice)+" 원", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19),
                                                        )
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        );
                      })
                    );
                  }
                ),
              ),
              Container(
                height: 130,
                width: MediaQuery.of(context).size.width,
                color: backgroudColor,
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(top : 30,left: 16, right: 16),
              width: MediaQuery.of(context).size.width,
              height: 130,
              decoration: BoxDecoration(
                color: backgroudColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24)
                ),
                border: Border.all(
                  width: 0.2,
                  color : secondaryColor
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0.5,
                    blurRadius: 5.0,
                    offset: Offset(0,0),
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment:CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          "결제 예상 금액", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        formatCurrency.format(totalPrice)+"원", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        print(basketData.length);
                        print(_isChecked!.length);
                        List orderList = [];

                        for(int i = 0; i<basketData.length; i++){
                          if(_isChecked?[i] == true){
                            orderList.add(basketData[i]);
                          }
                        }

                        if(orderList.isEmpty){
                          Get.snackbar("주문 불가", "장바구니에 선택한 상품이 없습니다.",backgroundColor: Colors.black,colorText: Colors.white);
                          return;
                        }
                        Get.to(() => PaymentScreen(orderList: orderList),transition: Transition.rightToLeft);
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 8, bottom: 16),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(
                            Radius.circular(16)
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "총 ${allCount}개 주문하기", style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          )
        ],
      )
    );
  }
}