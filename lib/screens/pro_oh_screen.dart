import 'package:flutter/material.dart';

import '../basic/commons.dart';
import 'package:jasmine/basic/log.dart';
import '../basic/methods.dart';
import '../configs/is_pro.dart';
import 'components/right_click_pop.dart';

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
                defaultToast(context, "FAIL");
              }
              await reloadIsPro();
              setState(() {});
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
