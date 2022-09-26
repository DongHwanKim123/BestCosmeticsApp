import 'dart:convert';

import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/screens/baskets/delivery_submit_screen.dart';
import 'package:best_cosmetics/screens/members/member_screen.dart';
import 'package:best_cosmetics/screens/members/order_delivery_screen.dart';
import 'package:best_cosmetics/screens/navigation_screen.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:bootpay/bootpay.dart';
                    

class PaymentScreen extends StatefulWidget {
  final List orderList;
  const PaymentScreen({Key? key, required this.orderList}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final formatCurrency = new NumberFormat.simpleCurrency(locale: "ko.KR",name: "",decimalDigits: 0);
  MemberGet memberGet = new MemberGet();
  String userNum = "";
  String userName ="";
  String userEmail = "";
  List callbackData = [];
  bool isDeliveryConfirm = false;
  TextEditingController _deliveryRequest = TextEditingController();
  int allPrice = 0;
  String orderNum = "";
  List orderList =[];
  String orderName = "";
  dynamic MemberData;

  //부트페이
  Payload payload = Payload();
  String _data = ""; // 서버승인을 위해 사용되기 위한 변수
  String webApplicationId = '';
  String androidApplicationId = '';
  String iosApplicationId = '';
  

  @override
  void initState() {
    super.initState();
    //print(widget.orderList);
    getData();
    getUserInfo();
  }

  getUserInfo() async {
    dynamic userdata = await memberGet.getUser();
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
    print(MemberData);

    if(MemberData['bcm_zipcode'] != null && MemberData['bcm_phonenum1'] != null && MemberData['bcm_phonenum2'] != null && MemberData['bcm_phonenum3'] != null) {
      callbackData = [{
        "reciName" : userdata.userName.toString(),
        "phone1" : MemberData['bcm_phonenum1'],
        "phone2" : MemberData['bcm_phonenum2'],
        "phone3" : MemberData['bcm_phonenum3'],
        "zipcode" : MemberData['bcm_zipcode'],
        "address1" : MemberData['bcm_address1'],
        "address3" : MemberData['bcm_address2']
      }];
      isDeliveryConfirm = true;
    }
    print(callbackData);
    setState(() {
      
    });
  }

  getData () async{
    dynamic userdata = await memberGet.getUser();
    userNum = userdata.userNum.toString();
    userName = userdata.userName.toString();
    userEmail = userdata.userEmail.toString();
    
    allPrice = 0;
    orderList = widget.orderList;
    for(int i = 0; i<orderList.length; i++){
      int price = orderList[i]['bcg_price'];
      int count = orderList[i]['bcb_count'];
      allPrice += price*count;
    }
    //주문번호 받아오기
    var url = Uri.parse("${adminIp}/api/member/payment/orderNum");
    http.Response response = await http.get(
      url,
    );

    var responseBody = utf8.decode(response.bodyBytes); 
    print(responseBody);
    orderNum = responseBody.toString();

    setState(() {
      
    });
  }

  String get applicationId {
    return Bootpay().applicationId(
      webApplicationId,
      androidApplicationId,
      iosApplicationId
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroudColor,
        title: Text(
          "주문/결제",
          style: TextStyle(
            color: primaryColor
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 16,right: 8,bottom: 8),
                        child: Text("주문자 정보",style: TextStyle(fontSize: 22,fontFamily: 'jua'),),
                      ),
                      Divider(thickness: 0.5,height: 0.5,),
                      Container(
                        padding: EdgeInsets.only(left : 16 ,right: 16, bottom: 16, top: 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text("주문자",style: TextStyle(fontSize: 16),)
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(userName,style: TextStyle(fontSize: 16, fontFamily: 'jua'),)
                                )
                              ],
                            ),
                            SizedBox(height: 8,),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text("이메일",style: TextStyle(fontSize: 16),)
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(userEmail,style: TextStyle(fontSize: 16, fontFamily: 'jua'),)
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Divider(thickness: 6,height: 6,),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8,right: 8,bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text("배송지 정보",style: TextStyle(fontSize: 22, fontFamily: 'jua'),)),
                          isDeliveryConfirm == false
                          ? Container() 
                          : TextButton(
                            onPressed: () {
                              setState(() {
                                isDeliveryConfirm = false;
                                callbackData.clear();
                                print(callbackData);
                              });
                            }, 
                            child: Text("배송지 변경",style: TextStyle(color: Colors.blue),
                            )
                          )
                        ],
                      ),
                    ),
                    Divider(thickness: 0.5,height: 0.5,),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: 
                    isDeliveryConfirm == false
                      ? InkWell(
                        onTap: () async{
                          var value = await Get.to(() => DeliverySubmitScreen());
                          print(value);
                          //주소 콜백 받은거
                          callbackData = value;
                          if(callbackData != null) {
                            isDeliveryConfirm = true;
                          }
                          setState(() {
                            
                          });
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(6)
                            ),
                            border: Border.all(
                              width: 0.7,
                              color : secondaryColor
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "배송지 입력하기 >", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      )
                      : Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              callbackData[0]['reciName'],
                              style: TextStyle(fontWeight: FontWeight.w700,fontSize: 16
                            ),
                            ),
                            Text(
                              "${callbackData[0]['phone1']}-${callbackData[0]['phone2']}-${callbackData[0]['phone3']}",
                                style: TextStyle(fontSize: 14,color: Colors.black54),
                            ),
                            Text(
                              "${callbackData[0]['address1']}, ${callbackData[0]['address3']}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14,color: Colors.black54),
                            ),
                            SizedBox(height: 6,),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _deliveryRequest,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 16),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      hintText: '배송요청사항을 입력해주세요.',
                                      hintStyle: const TextStyle(
                                        color: Colors.black26
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ),
                    Divider(thickness: 6,height: 6),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 8,right: 8,bottom: 8),
                            child: Text("결제 금액",style: TextStyle(fontSize: 22, fontFamily: 'jua'),),
                          ),
                          Divider(thickness: 0.5,height: 0.5,),
                          Container(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "총 상품 금액",style: TextStyle(color: Colors.black54),
                                        ),
                                      ),
                                      Text(
                                        "${formatCurrency.format(allPrice)}원",style: TextStyle(fontWeight: FontWeight.w700),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "배송비",style: TextStyle(color: Colors.black54),
                                        ),
                                      ),
                                      Text(
                                        "0원",style: TextStyle(fontWeight: FontWeight.w700),
                                      )
                                    ],
                                  ),
                                ),
                                Divider(thickness: 0.5,height: 0.5),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12,top: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "결제 예상 금액",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 16),
                                        ),
                                      ),
                                      Text(
                                        "${formatCurrency.format(allPrice)}원",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          )
                        ],
                      )
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 80,
              )
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
              height: 80,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: backgroudColor,
                border: Border.all(
                  width: 0.3,
                  color : secondaryColor
                ),
              ),
              child: InkWell(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(
                      Radius.circular(16)
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "결제하기", style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                onTap: () {
                  if(callbackData == null){
                    Get.snackbar("배송지", "배송정보를 입력해주세요",backgroundColor: Colors.black,colorText: Colors.white);
                    return;
                  }

                  bootpayReqeustDataInit(); //결제용 데이터 init
                  goBootpayTest(context);
                },
              ),
            ),
          )
        ],
      )
    );
  }
  
  bootpayReqeustDataInit() {
    // Item item1 = Item();
    // item1.name = "미키 '마우스"; // 주문정보에 담길 상품명
    // item1.qty = 1; // 해당 상품의 주문 수량
    // item1.id = "ITEM_CODE_MOUSE"; // 해당 상품의 고유 키
    // item1.price = 500; // 상품의 가격

    // Item item2 = Item();
    // item2.name = "키보드"; // 주문정보에 담길 상품명
    // item2.qty = 1; // 해당 상품의 주문 수량
    // item2.id = "ITEM_CODE_KEYBOARD"; // 해당 상품의 고유 키
    // item2.price = 500; // 상품의 가격
    List<Item> itemList = [];
    

    for(int i = 0; i < orderList.length ; i++ ) {
      Item item = Item();
      item.name = orderList[i]['bcg_name'];
      item.qty = orderList[i]['bcb_count'];
      item.id = orderList[i]['bcg_key'].toString();
      int bcgPrice = orderList[i]['bcg_price'];
      item.price = bcgPrice.toDouble();
      orderName = orderList[i]['bcg_name'];

      itemList.add(item);
    }
    print(itemList);

    payload.webApplicationId = webApplicationId; // web application id
    payload.androidApplicationId = androidApplicationId; // android application id
    payload.iosApplicationId = iosApplicationId; // ios application id


    payload.pg = '';
    payload.methods = ['휴대폰' , '카드'];
    // payload.methods = ['card', 'phone', 'vbank', 'bank', 'kakao'];
    payload.orderName = "${orderName} 외 ${orderList.length-1}건"; //결제할 상품명
    payload.price = allPrice.toDouble(); //정기결제시 0 혹은 주석


    payload.orderId = orderNum;//DateTime.now().millisecondsSinceEpoch.toString(); //주문번호, 개발사에서 고유값으로 지정해야함


    // payload.params = {
    //   "callbackParam1" : "value12",
    //   "callbackParam2" : "value34",
    //   "callbackParam3" : "value56",
    //   "callbackParam4" : "value78",
    // }; // 전달할 파라미터, 결제 후 되돌려 주는 값
    payload.items = itemList; // 상품정보 배열

    User user = User(); // 구매자 정보
    user.username = userName;
    user.email = userEmail;
    user.area = "Korea";
    user.phone = "${callbackData[0]['phone1']}-${callbackData[0]['phone2']}-${callbackData[0]['phone3']}";
    user.addr = "${callbackData[0]['address1']}, ${callbackData[0]['address3']}";

    Extra extra = Extra(); // 결제 옵션
    extra.appScheme = 'bootpayFlutterExample';
    extra.cardQuota = '3';
    // extra.openType = 'popup';

    // extra.carrier = "SKT,KT,LGT"; //본인인증 시 고정할 통신사명
    // extra.ageLimit = 20; // 본인인증시 제한할 최소 나이 ex) 20 -> 20살 이상만 인증이 가능

    payload.user = user;
    payload.extra = extra;
    payload.extra?.openType = "iframe";
  }

  //버튼클릭시 부트페이 결제요청 실행
  void goBootpayTest(BuildContext context) {
    Bootpay().requestPayment(
      context: context,
      payload: payload,
      showCloseButton: false,
      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data) {
        print('------- onCancel: $data');
        Get.snackbar("결제취소", "결제 취소되었습니다.",backgroundColor: Colors.black,colorText: Colors.white);
      },
      onError: (String data) {
        print('------- onCancel: $data');
        Get.snackbar("결제에러", "결제 실패되었습니다.",backgroundColor: Colors.black,colorText: Colors.white);
      },
      onClose: () {
        print('------- onClose');
        Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        //TODO - 원하시는 라우터로 페이지 이동
        
        
      },
      // onCloseHardware: () {
      //   print('------- onCloseHardware');
      // },
      onIssued: (String data) {
        print('------- onIssued: $data');
      },
      onConfirm: (String data) {
        /**
            1. 바로 승인하고자 할 때
            return true;
         **/
        /***
            2. 비동기 승인 하고자 할 때
            checkQtyFromServer(data);
            return false;
         ***/
        /***
            3. 서버승인을 하고자 하실 때 (클라이언트 승인 X)
            return false; 후에 서버에서 결제승인 수행
         */
        // checkQtyFromServer(data);
        // return false;
        return true;
      },
      onDone: (String data) {
        print('------- onDone: $data');
        toServerData();
        Get.snackbar("주문완료","${orderName} 외 ${orderList.length-1}건", duration: Duration(seconds: 10),
                      titleText: InkWell(
                        onTap: () {
                          Get.to(() =>OrderDelivery());
                        },
                        child: Text(
                          "주문완료",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white),
                        ),
                      ),
                      messageText: InkWell(
                        onTap: () {
                          Get.to(() =>OrderDelivery());
                        },
                        child: Text(
                          "${orderName} 외 ${orderList.length-1}건",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white),
                        ),
                      ),
                      backgroundColor: Colors.black
                    );
        Get.offAll(() => NavigationScreen());
      },
    );
  }

  toServerData() async{

    List listData = [];

    for(int i = 0; i<orderList.length; i++){
      Map<String,dynamic> data = {
        'bcgKey' : orderList[i]['bcg_key'],
        'bcgDetailkey' : orderList[i]['bcd_detailkey'],
        'count' : orderList[i]['bcb_count'].toString()
      };
      listData.add(data); 
    }

    Map<String,dynamic> orderData = {
      'bcmNum' : userNum.toString(),
      'bcmName' : userName.toString(),
      'orderNum' : orderNum.toString(),
      'totalPrice' : allPrice.toString(),
      'phoneNum1' : callbackData[0]['phone1'].toString(),
      'phoneNum2' : callbackData[0]['phone2'].toString(),
      'phoneNum3' : callbackData[0]['phone3'].toString(),
      'zipcode' : callbackData[0]['zipcode'].toString(),
      'address1' : callbackData[0]['address1'].toString(),
      'address2' : null,
      'address3' : callbackData[0]['address3'].toString(),
      'deliveryRequest' : _deliveryRequest.text.toString(),
      'reciName' : callbackData[0]['reciName'].toString(),
      'orderList' : listData,
      'orderName' : "${orderName} 외 ${orderList.length-1}건"
    };

    print(orderData);

    var url = Uri.parse("${adminIp}/api/member/payment/after");

    http.Response response = await http.post(
      url,
      headers: <String, String> {
        'Content-Type' : 'application/json',
      },
      body: json.encode(orderData),
    );
  }
}