import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/configs/Authentication.dart';
import 'package:jasmine/configs/configs.dart';
import 'package:jasmine/configs/login.dart';

import '../basic/web_dav_sync.dart';
import '../configs/passed.dart';
import 'app_screen.dart';
import 'calculator_screen.dart';
import 'first_login_screen.dart';
import 'network_setting_screen.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return const Center(
            child: Text("initializing..."),
          );
        },
      ),
    );
  }

  Future _init() async {
    try {
      await methods.init();
      await initConfigs(context);
      print("STATE : ${loginStatus}");
      if (!currentPassed()) {
        Future.delayed(Duration.zero, () async {
          await webDavSyncAuto(context);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) {
              return const CalculatorScreen();
            }),
          );
        });
      } else if (currentAuthentication()) {
        Future.delayed(Duration.zero, () async {
          await webDavSyncAuto(context);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) {
              return const AuthScreen();
            }),
          );
        });
      } else if (loginStatus == LoginStatus.notSet) {
        Future.delayed(Duration.zero, () async {
          await webDavSyncAuto(context);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) {
              return firstLoginScreen;
            }),
          );
        });
      } else {
        Future.delayed(Duration.zero, () async {
          await webDavSyncAuto(context);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) {
              return const AppScreen();
            }),
          );
        });
      }
    } catch (e, st) {
      print("$e\n$st");
      defaultToast(context, "初始化失败, 请设置网络");
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) {
            return const NetworkSettingScreen();
          }),
        );
      });
    }
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      test();
    });
  }

  test() async {
    if (await verifyAuthentication(context)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) {
          return const AppScreen();
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("身份验证"),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: MaterialButton(
            onPressed: () async {
              test();
            },
            child: const Text(
              '您在之前使用APP时开启了身份验证, 请点这段文字进行身份核查, 核查通过后将会进入APP',
            ),
          ),
        ),
      ),
    );
  }
}
