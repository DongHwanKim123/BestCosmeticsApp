import 'package:best_cosmetics/resources/member_get.dart';
import 'package:best_cosmetics/utils/colors.dart';
import 'package:best_cosmetics/utils/ip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kpostal/kpostal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DeliverySubmitScreen extends StatefulWidget {
  const DeliverySubmitScreen({Key? key}) : super(key: key);

  @override
  State<DeliverySubmitScreen> createState() => _DeliverySubmitScreenState();
}

class _DeliverySubmitScreenState extends State<DeliverySubmitScreen> {
  final formKey = new GlobalKey<FormState>();
  TextEditingController _reciNameController = TextEditingController();
  TextEditingController _phone1Controller = TextEditingController();
  TextEditingController _phone2Controller = TextEditingController();
  TextEditingController _phone3Controller = TextEditingController();
  TextEditingController _zipcodeController = TextEditingController();
  TextEditingController _address1Controller = TextEditingController();
  TextEditingController _address3Controller = TextEditingController();

  String reciName = "";
  String phone1 = "";
  String phone2 = "";
  String phone3 = "";
  String zipcode = "";
  String address1 = "";
  String address3 = "";

  dynamic userdata;
  List lastDesData = [];

  @override
  void initState() {
    super.initState();
    getLastDeliveryData();
    //getData();
  }

  @override
  void dispose() {
    super.dispose();
    _zipcodeController.dispose();
    _address1Controller.dispose();
    _reciNameController.dispose();
    _phone2Controller.dispose();
    _phone3Controller.dispose();
    _address3Controller.dispose();
    _phone1Controller.dispose();

  }

  // getData() {
  //   List value = Get.arguments;
  //   if(value.isNotEmpty) {
  //     print(value);
  //     value[0]['reciName'] = _reciNameController.text;
  //     value[0]['phone1'] = _phone1Controller.text;
  //     value[0]['phone2'] = _phone2Controller.text;
  //     value[0]['phone3'] = _phone3Controller.text;
  //     value[0]['zipcode'] = _zipcodeController.text;
  //     value[0]['address1'] = _address1Controller.text;
  //     value[0]['address3'] = _address3Controller.text;
  //     print(value[0]['reciName']);
  //   }
  // }

  getLastDeliveryData () async{
    MemberGet memberGet = new MemberGet();
    userdata = await memberGet.getUser();

    var url = Uri.parse("${adminIp}/api/member/lastDeliveryDeDeliveryDestination?bcmNum=${userdata.userNum.toString()}");

    http.Response response = await http.get(
      url,
      headers : {"Accept" : "application/json"},
    );
    var responseBody = utf8.decode(response.bodyBytes);
    lastDesData = jsonDecode(responseBody);
    print(lastDesData);
    setState(() {
      
    });
  }

  void _lastDes(int index) {
    print(index);
    _zipcodeController.text = lastDesData[index]['bcd_zipcode'];
    _address1Controller.text = lastDesData[index]['bcd_address1'] ;
    _address3Controller.text = lastDesData[index]['bcd_address2'] ;
    

    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroudColor,
        title: Text(
          "배송지추가",
          style: TextStyle(
            color: primaryColor
          ),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  Row(
                    children: [
                      Expanded(child: Text("최근배송지",style: TextStyle(fontSize: 16),)),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey)
                        ),
                        child: Text(
                          "1",style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => _lastDes(0),
                      ),
                      SizedBox(width: 5,),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey)
                        ),
                        child: Text(
                          "2",style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => _lastDes(1),
                      ),
                      SizedBox(width: 5,),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey)
                        ),
                        child: Text(
                          "3",style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => _lastDes(2),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  //수령인
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text("수령인",style: TextStyle(fontSize: 16),)
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left:16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: '이름',
                            hintStyle: const TextStyle(
                              color: Colors.black26
                            ),
                          ),
                          onSaved: (val) {
                            setState(() {
                              reciName = val as String;
                            });
                          },
                          controller: _reciNameController,
                          validator: (val) {
                            if(val == null || val.isEmpty) {
                              return '이름을 입력하세요.';
                            }
                            else if(val.length < 2) {
                              return '이름은 최소 2자리여야 합니다.';
                            }
                            else if(!RegExp(r'^[가-힣]*$').hasMatch(val)) {
                              return '이름을 올바르게 입력해주세요.';
                            }
                            return null;
                          }
                        )
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  //휴대폰
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text("휴대폰",style: TextStyle(fontSize: 16),)
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.only(left:16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: '010',
                            hintStyle: const TextStyle(
                              color: Colors.black26
                            ),
                          ),
                          inputFormatters:[FilteringTextInputFormatter(RegExp('[0-9]'),allow:true)],
                          onSaved: (val) {
                            setState(() {
                              phone1 = val as String;
                            });
                          },
                          maxLength: 3,
                          keyboardType: TextInputType.number,
                          controller: _phone1Controller,
                          validator: (val) {
                            if(val == null || val.isEmpty) {
                              return '';
                            }
                            else if(val.length != 3) {
                              return '';
                            }
                            return null;
                          }
                        )
                      ),
                      SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.only(left:16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: '0000',
                            hintStyle: const TextStyle(
                              color: Colors.black26
                            ),
                          ),
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          inputFormatters:[FilteringTextInputFormatter(RegExp('[0-9]'),allow:true),],
                          onSaved: (val) {
                            setState(() {
                              phone2 = val as String;
                            });
                          },
                          controller: _phone2Controller,
                          validator: (val) {
                            if(val == null || val.isEmpty) {
                              return '';
                            }
                            else if(val.length != 4) {
                              return '';
                            }
                            return null;
                          }
                        )
                      ),
                      SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.only(left:16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: '0000',
                            hintStyle: const TextStyle(
                              color: Colors.black26
                            ),
                          ),
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          inputFormatters:[FilteringTextInputFormatter(RegExp('[0-9]'),allow:true),],
                          onSaved: (val) {
                            setState(() {
                              phone3 = val as String;
                            });
                          },
                          controller: _phone3Controller,
                          validator: (val) {
                            if(val == null || val.isEmpty) {
                              return '';
                            }
                            else if(val.length != 4) {
                              return '';
                            }
                            return null;
                          }
                        )
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text("배송지",style: TextStyle(fontSize: 16),)
                      ),
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left:16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: '',
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
                          validator: (val) {
                            if(val == null || val.isEmpty) {
                              return '';
                            }
                            return null;
                          }
                        )
                      ),
                      SizedBox(width: 8,),
                      Expanded(
                        flex: 4,
                        child: InkWell(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10)
                              ),
                            ),
                            child: Center(
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
                                      this.zipcode = result.postCode;
                                      this.address1 = result.address;
                                       _zipcodeController.text = this.zipcode;
                                       _address1Controller.text = this.address1;
                                      //this.latitude = result.latitude.toString();
                                      //this.longitude = result.longitude.toString();
                                      //this.kakaoLatitude = result.kakaoLatitude.toString();
                                      //this.kakaoLongitude = result.kakaoLongitude.toString();
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left:16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: '',
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
                          validator: (val) {
                            if(val == null || val.isEmpty) {
                              return '';
                            }
                            return null;
                          }
                        )
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left:16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: '상세주소를 입력하세요',
                            hintStyle: const TextStyle(
                              color: Colors.black26
                            ),
                          ),
                          onSaved: (val) {
                            setState(() {
                              address3 = val as String;
                            });
                          },
                          controller: _address3Controller,
                          validator: (val) {
                            if(val == null || val.isEmpty) {
                              return '';
                            }
                            return null;
                          }
                        )
                      ),
                    ],
                  ),
                  SizedBox(height: 55,)
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: InkWell(
              onTap: () {
                if(formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  var listmap = [{
                    "reciName" : reciName,
                    "phone1" : phone1,
                    "phone2" : phone2,
                    "phone3" : phone3,
                    "zipcode" : zipcode,
                    "address1" : address1,
                    "address3" : address3
                  }];
                  print(listmap);
                  Get.back(result: listmap);
                }
              },
              child: Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: 55,
                child: Center(
                  child: Text(
                    "완료", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            )
          )
        ],
      )
    );
  }
}