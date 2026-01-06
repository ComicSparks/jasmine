import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jasmine/basic/methods.dart';

late String _apiHost;

const _base64List = [
  "d3d3LmNkbmJlYS5uZXQ=",
  "d3d3LmNkbmh0aC5uZXQ=",
  "d3d3LmNkbmd3Yy5jYw==",
  "d3d3LmNkbmh0aC5jbHVi",
]; 

var _apiList = [];

Future<void> initApiHost() async {
  for (var i = 0; i < _base64List.length; i++) {
    _apiList.add(utf8.decode(base64.decode(_base64List[i])));
  }
  _apiHost = await methods.loadApiHost();
}

String get currentApiHostName => (_apiHost);

Future<T?> chooseApiDialog<T>(BuildContext buildContext) async {
  return await showDialog<T>(
    context: buildContext,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text("API分流"),
        children: [
          ..._apiList
            .map(
              (e) => SimpleDialogOption(
                child: ApiOptionRow(
                  e,
                  key: Key("API:${e}"),
                ),
                onPressed: () {
                  Navigator.of(context).pop(e);
                },
              ),
            ),
            SimpleDialogOption(
              child: const Text("手动输入"),
              onPressed: () async {
                Navigator.of(context).pop(await _manualInputApiHost(context));
              },
            ),
            SimpleDialogOption(
              child: const Text("取消"),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
        ],
      );
    },
  );
}

final TextEditingController _controller = TextEditingController();

Future<String> _manualInputApiHost(BuildContext context) async {
  _controller.text = _apiHost;
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("手动输入API地址"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "www.example.com",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(_controller.text);
            },
            child: const Text("确定"),
          ),
        ],
      );
    },
  );
}

class ApiOptionRow extends StatefulWidget {
  final String value;

  const ApiOptionRow(this.value, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ApiOptionRowState();
}

class _ApiOptionRowState extends State<ApiOptionRow> {
  late Future<int> _feature;

  @override
  void initState() {
    super.initState();
    _feature = methods.ping(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.value),
        Expanded(child: Container()),
        FutureBuilder(
          future: _feature,
          builder: (
            BuildContext context,
            AsyncSnapshot<int> snapshot,
          ) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const PingStatus(
                "测速中",
                Colors.blue,
              );
            }
            if (snapshot.hasError) {
              return const PingStatus(
                "失败",
                Colors.red,
              );
            }
            int ping = snapshot.requireData;
            if (ping <= 200) {
              return PingStatus(
                "${ping}ms",
                Colors.green,
              );
            }
            if (ping <= 500) {
              return PingStatus(
                "${ping}ms",
                Colors.yellow,
              );
            }
            return PingStatus(
              "${ping}ms",
              Colors.orange,
            );
          },
        ),
      ],
    );
  }
}

class PingStatus extends StatelessWidget {
  final String title;
  final Color color;

  const PingStatus(this.title, this.color, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '\u2022',
          style: TextStyle(
            color: color,
          ),
        ),
        Text(" $title"),
      ],
    );
  }
}

Future chooseApiHost(BuildContext context) async {
  final choose = await chooseApiDialog(context);
  if (choose != null) {
    await methods.saveApiHost(choose);
    _apiHost = choose;
  }
}

Widget apiHostSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        onTap: () async {
          await chooseApiHost(context);
          setState(() {});
        },
        title: const Text("API分流"),
        subtitle: Text(_apiHost),
      );
    },
  );
}
