import 'package:flutter/material.dart';
import '../basic/web_dav_sync.dart';
import '../configs/login.dart';
import '../configs/passed.dart';

import 'app_screen.dart';
import 'first_login_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          padding: const EdgeInsets.only(top: 10.0, left: 10.0),
          color: Colors.black,
          child: const ContentBody(),
        ),
      );
}

class ContentBody extends StatefulWidget {
  const ContentBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ContentBodyState();
}

class ContentBodyState extends State<ContentBody> {
  String sums = '0';
  String total = '0';
  String flag = '';
  bool isDouble = false;
  int tag = 0;
  List list = [
    {'bgc': '0xFFFF9800', 'color': '0xFFFFFFFFF'},
    {'bgc': '0xFFFF9800', 'color': '0xFFFFFFFFF'},
    {'bgc': '0xFFFF9800', 'color': '0xFFFFFFFFF'},
    {'bgc': '0xFFFF9800', 'color': '0xFFFFFFFFF'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(child: Container()),
        Container(
          padding: const EdgeInsets.only(
              top: 10.0, left: 10.0, right: 20.0, bottom: 10.0),
          child: Container(
            alignment: Alignment.bottomRight,
            child: Text(
              sums,
              maxLines: 8,
              style: const TextStyle(fontSize: 33, color: Colors.white),
            ),
          ),
        ),
        Expanded(child: Container()),
        Column(
          children: [
            Center(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(32),
                        color: Colors.grey,
                        splashColor: Colors.white,
                        onPressed: () {
                          btnclick('重置');
                        },
                        child: const Text('AC',
                            style: TextStyle(
                                color: Colors.black, fontSize: 20)),
                        shape: const CircleBorder(
                          side: BorderSide(color: Colors.grey),
                        ),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(32),
                        color: Colors.grey,
                        splashColor: Colors.white,
                        onPressed: () {
                          btnclick('加/减');
                        },
                        child: const Text('+/-',
                            style: TextStyle(
                                color: Colors.black, fontSize: 20)),
                        shape: const CircleBorder(
                            side: BorderSide(color: Colors.grey)),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(32),
                        color: Colors.grey,
                        splashColor: Colors.white,
                        onPressed: () {
                          btnclick('百分号');
                        },
                        child: const Text('%',
                            style: TextStyle(
                                color: Colors.black, fontSize: 25)),
                        shape: const CircleBorder(
                            side: BorderSide(color: Colors.grey)),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(24),
                        color: Color(int.parse(list[0]['bgc'])),
                        splashColor: Color(int.parse(list[0]['bgc'])),
                        onPressed: () {
                          btnclick('除');
                        },
                        child: Text('÷',
                            style: TextStyle(
                                color:
                                Color(int.parse(list[0]['color'])),
                                fontSize: 30)),
                        shape: CircleBorder(
                            side: BorderSide(
                                color:
                                Color(int.parse(list[0]['bgc'])))),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(29),
                        color: const Color(0xFF3B3B3B),
                        splashColor: Colors.grey,
                        onPressed: () {
                          numClick('7');
                        },
                        child: const Text('7',
                            style: TextStyle(
                                color: Colors.white, fontSize: 30)),
                        shape: const CircleBorder(
                            side: BorderSide(color: Color(0xFF3B3B3B))),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(29),
                        color: const Color(0xFF3B3B3B),
                        splashColor: Colors.grey,
                        onPressed: () {
                          numClick('8');
                        },
                        child: const Text('8',
                            style: TextStyle(
                                color: Colors.white, fontSize: 30)),
                        shape: const CircleBorder(
                            side: BorderSide(color: Color(0xFF3B3B3B))),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(29),
                        color: const Color(0xFF3B3B3B),
                        splashColor: Colors.grey,
                        onPressed: () {
                          numClick('9');
                        },
                        child: const Text('9',
                            style: TextStyle(
                                color: Colors.white, fontSize: 30)),
                        shape: const CircleBorder(
                            side: BorderSide(color: Color(0xFF3B3B3B))),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(24),
                        color: Color(int.parse(list[1]['bgc'])),
                        splashColor: Color(int.parse(list[1]['bgc'])),
                        onPressed: () {
                          btnclick('乘');
                        },
                        child: Text('×',
                            style: TextStyle(
                                color:
                                Color(int.parse(list[1]['color'])),
                                fontSize: 30)),
                        shape: CircleBorder(
                            side: BorderSide(
                                color:
                                Color(int.parse(list[1]['bgc'])))),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(29),
                        color: const Color(0xFF3B3B3B),
                        splashColor: Colors.grey,
                        onPressed: () {
                          numClick('4');
                        },
                        child: const Text('4',
                            style: TextStyle(
                                color: Colors.white, fontSize: 30)),
                        shape: const CircleBorder(
                            side: BorderSide(color: Color(0xFF3B3B3B))),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(29),
                        color: const Color(0xFF3B3B3B),
                        splashColor: Colors.grey,
                        onPressed: () {
                          numClick('5');
                        },
                        child: const Text('5',
                            style: TextStyle(
                                color: Colors.white, fontSize: 30)),
                        shape: const CircleBorder(
                            side: BorderSide(color: Color(0xFF3B3B3B))),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(30),
                        color: const Color(0xFF3B3B3B),
                        splashColor: Colors.grey,
                        onPressed: () {
                          numClick('6');
                        },
                        child: const Text('6',
                            style: TextStyle(
                                color: Colors.white, fontSize: 30)),
                        shape: const CircleBorder(
                            side: BorderSide(color: Color(0xFF3B3B3B))),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(24),
                        color: Color(int.parse(list[2]['bgc'])),
                        splashColor: Color(int.parse(list[2]['bgc'])),
                        onPressed: () {
                          btnclick('减');
                        },
                        child: Text('—',
                            style: TextStyle(
                                color:
                                Color(int.parse(list[2]['color'])),
                                fontSize: 30)),
                        shape: CircleBorder(
                            side: BorderSide(
                                color:
                                Color(int.parse(list[2]['bgc'])))),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(29),
                        color: const Color(0xFF3B3B3B),
                        splashColor: Colors.grey,
                        onPressed: () {
                          numClick('1');
                        },
                        child: const Text('1',
                            style: TextStyle(
                                color: Colors.white, fontSize: 30)),
                        shape: const CircleBorder(
                            side: BorderSide(color: Color(0xFF3B3B3B))),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(29),
                        color: const Color(0xFF3B3B3B),
                        splashColor: Colors.grey,
                        onPressed: () {
                          numClick('2');
                        },
                        child: const Text('2',
                            style: TextStyle(
                                color: Colors.white, fontSize: 30)),
                        shape: const CircleBorder(
                            side: BorderSide(color: Color(0xFF3B3B3B))),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(29),
                        color: const Color(0xFF3B3B3B),
                        splashColor: Colors.grey,
                        onPressed: () {
                          numClick('3');
                        },
                        child: const Text('3',
                            style: TextStyle(
                                color: Colors.white, fontSize: 30)),
                        shape: const CircleBorder(
                            side: BorderSide(color: Color(0xFF3B3B3B))),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(
                      child: MaterialButton(
                        padding:
                        EdgeInsets.all(24),
                        color: Color(int.parse(list[3]['bgc'])),
                        splashColor: Color(int.parse(list[3]['bgc'])),
                        onPressed: () {
                          btnclick('加');
                        },
                        child: Text('+',
                            style: TextStyle(
                                color:
                                Color(int.parse(list[3]['color'])),
                                fontSize: 30)),
                        shape: CircleBorder(
                            side: BorderSide(
                                color:
                                Color(int.parse(list[3]['bgc'])))),
                      ),
                      alignment: Alignment.center,
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    child: MaterialButton(
                      padding: const EdgeInsets.only(
                          left: 70.0,
                          top: 20.0,
                          bottom: 20.0,
                          right: 76.0),
                      color: const Color(0xFF3B3B3B),
                      splashColor: Colors.grey,
                      onPressed: () {
                        numClick('0');
                      },
                      child: const Text('0',
                          style: TextStyle(
                              color: Colors.white, fontSize: 30)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                    ),
                    margin: const EdgeInsets.only(left: 10.0),
                    alignment: Alignment.center,
                  ),
                  Container(
                    child: MaterialButton(
                      padding:
                      EdgeInsets.all(29),
                      color: const Color(0xFF3B3B3B),
                      splashColor: Colors.grey,
                      onPressed: () {
                        numClick('.');
                      },
                      child: const Text('.',
                          style: TextStyle(
                              color: Colors.white, fontSize: 30)),
                      shape: const CircleBorder(
                          side: BorderSide(color: Color(0xFF3B3B3B))),
                    ),
                    alignment: Alignment.center,
                  ),
                  Container(
                    child: MaterialButton(
                      padding:
                      EdgeInsets.all(24),
                      color: Colors.orange,
                      splashColor: Colors.orange,
                      onPressed: () {
                        btnclick('等于');
                      },
                      child: const Text('=',
                          style: TextStyle(
                              color: Colors.white, fontSize: 30)),
                      shape: const CircleBorder(
                          side: BorderSide(color: Colors.orange)),
                    ),
                    alignment: Alignment.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(child: Container()),
      ],
    );
  }

  numClick(e) {
    if (sums == '0') {
      if (e == '.') {
        setState(() {
          isDouble = true;
          sums += e;
        });
      } else {
        setState(() {
          sums = e;
        });
      }
    } else {
      if (flag != '') {
        if (tag == 0) {
          if (sums.length < 20) {
            setState(() {
              sums += e;
            });
          }
        } else {
          setState(() {
            sums = e;
            tag = 0;
          });
        }
      } else {
        if (sums.length < 20) {
          setState(() {
            sums += e;
          });
        }
      }
    }
  }

//  计算点击
  btnclick(e) {
    if (sums == "55566686648") {
      firstPassed().then((value) {
        if (loginStatus == LoginStatus.notSet) {
          Future.delayed(Duration.zero, () async {
            await webDavSyncAuto(context);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (BuildContext context) {
                return firstLoginScreen;
              }),
            );
          });
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (BuildContext context) {
              return const AppScreen();
            },
          ));
        }
      });
    }
    for (var element in list) {
      element['color'] = '0xFFFFFFFFF';
      element['bgc'] = '0xFFFF9800';
    }
    switch (e) {
      case '重置':
        setState(() {
          sums = '0';
          tag = 0;
          flag = '';
        });
        break;
      case '加':
        setState(() {
          total = sums;
          tag = 1;
          flag = '加';
          list[3]['bgc'] = '0xFFFFFFFFF';
          list[3]['color'] = '0xFFFF9800';
        });
        break;
      case '减':
        setState(() {
          total = sums;
          tag = 1;
          flag = '减';
          list[2]['bgc'] = '0xFFFFFFFFF';
          list[2]['color'] = '0xFFFF9800';
        });
        break;
      case '乘':
        setState(() {
          total = sums;
          tag = 1;
          flag = '乘';
          list[1]['bgc'] = '0xFFFFFFFFF';
          list[1]['color'] = '0xFFFF9800';
        });
        break;
      case '除':
        setState(() {
          total = sums;
          tag = 1;
          flag = '除';
          list[0]['bgc'] = '0xFFFFFFFFF';
          list[0]['color'] = '0xFFFF9800';
        });
        break;
      case '百分号':
        setState(() {
          total = sums;
          tag = 1;
          flag = '百分号';
          sums = (int.parse(sums) / 100).toString();
          isDouble = true;
        });
        break;
      case '等于':
        sumClac();
        setState(() {
          tag = 1;
          flag = 'true';
        });
        clacVlaue();
    }
  }

// 计算函数
  sumClac() {
    if (flag == '加') {
      if (isDouble) {
        double c = double.parse(total) + double.parse(sums);
        setState(() {
          sums = c.toString();
        });
      } else {
        int c = int.parse(total) + int.parse(sums);
        setState(() {
          sums = c.toString();
        });
      }
      setState(() {
        total = '';
        isDouble = false;
        flag = '';
      });
    } else if (flag == '减') {
      if (isDouble) {
        double c = double.parse(total) - double.parse(sums);
        setState(() {
          sums = c.toString();
        });
      } else {
        int c = int.parse(total) - int.parse(sums);
        setState(() {
          sums = c.toString();
        });
      }
      setState(() {
        total = '';
        flag = '';
        isDouble = false;
      });
    } else if (flag == '乘') {
      if (isDouble) {
        double c = double.parse(total) * double.parse(sums);
        setState(() {
          sums = c.toString();
        });
      } else {
        int c = int.parse(total) * int.parse(sums);
        setState(() {
          sums = c.toString();
        });
      }
      setState(() {
        total = '';
        flag = '';
        isDouble = false;
      });
    } else if (flag == '除') {
      if (isDouble) {
        double c = double.parse(total) * double.parse(sums);
        setState(() {
          sums = c.toString();
        });
      } else {
        double c = int.parse(total) / int.parse(sums);
        if (int.parse(total) % int.parse(sums) == 0) {
          setState(() {
            sums = c.toInt().toString();
          });
        } else {
          setState(() {
            sums = c.toString();
          });
        }
      }
      setState(() {
        total = '';
        flag = '';
        isDouble = false;
      });
    }
  }

//  判断计算值
  clacVlaue() {
//    if(sums.length >10){
//      setState(() {
//        sums = sums.substring(0, 10);
//      });
//    }
  }
}
