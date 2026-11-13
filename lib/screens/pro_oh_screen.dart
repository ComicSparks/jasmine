import 'package:flutter/material.dart';

import '../basic/commons.dart';
import 'package:jasmine/basic/log.dart';
import '../basic/methods.dart';
import '../configs/is_pro.dart';
import 'components/right_click_pop.dart';
import 'pro_screen.dart';

class ProOhScreen extends StatefulWidget {
  const ProOhScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProOhScreen> {
  String _username = "";

  @override
  void initState() {
    methods.loadLastLoginUsername().then((value) {
      setState(() {
        _username = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("发电中心"),
      ),
      body: ListView(
        children: [
          SizedBox(
            width: min / 2,
            height: min / 2,
            child: Center(
              child: Icon(
                isPro ? Icons.offline_bolt : Icons.offline_bolt_outlined,
                size: min / 3,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Center(child: Text(_username)),
          Container(height: 20),
          const Divider(),
          ListTile(
            title: const Text("发电详情"),
            subtitle: Text(
              isPro
                  ? "发电中 (${DateTime.fromMillisecondsSinceEpoch(1000 * isProEx).toString()})"
                  : "未发电",
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text("我曾经发过电"),
            onTap: () async {
              try {
                await methods.reloadPro();
                defaultToast(context, "SUCCESS");
              } catch (e, s) {
                debugPrient("$e\n$s");
                defaultToast(context, _proOhErrorMessage(e));
              }
              await reloadIsPro();
              setState(() {});
            },
          ),
          const Divider(),
          const ProServerNameWidget(),
          const Divider(),
        ],
      ),
    );
  }
}

String _proOhErrorMessage(Object e) {
  var text = e.toString();
  const prefixes = ['Bad state: ', 'Exception: ', 'Error: '];
  for (final prefix in prefixes) {
    if (text.startsWith(prefix)) {
      text = text.substring(prefix.length);
      break;
    }
  }
  text = text.trim();
  if (text.isEmpty) {
    text = 'SERVER_FAILED';
  }
  const messages = <String, String>{
    'NETWORK_TIMEOUT': '网络超时，请检查网络或更换发电方式',
    'NETWORK_UNREACHABLE': '连接不上服务器，请检查网络或更换发电方式',
    'SERVER_FAILED': '服务器处理失败',
    'SERVER_RESPONSE_INVALID': '服务器返回异常',
    'REQUEST_INVALID': '请求无效',
    'ORDER_NOT_SYNCED': '订单尚未同步，请稍后再试',
    'ORDER_ALREADY_USED': '订单已被使用',
    'ORDER_AMOUNT_INVALID': '订单金额无效',
    'TICKET_NOT_FOUND': '兑换券不存在',
    'TICKET_ALREADY_USED': '兑换券已被使用',
    'TICKET_EVENT_USED': '活动兑换券已参与',
  };
  return messages[text] ?? text;
}
