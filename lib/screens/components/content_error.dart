import 'package:flutter/material.dart';
import 'package:jasmine/basic/log.dart';
import 'error_types.dart';

class ContentError extends StatelessWidget {
  final Object? error;
  final StackTrace? stackTrace;
  final Future<void> Function() onRefresh;

  const ContentError({
    Key? key,
    required this.error,
    required this.stackTrace,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var type = errorType("$error");
    late String message;
    late IconData iconData;
    switch (type) {
      case ERROR_TYPE_NETWORK:
        iconData = Icons.wifi_off_rounded;
        message = "连接不上啦, 请检查网络";
        break;
      case ERROR_TYPE_PERMISSION:
        iconData = Icons.highlight_off;
        message = "没有权限或路径不可用";
        break;
      case ERROR_TYPE_TIME:
        iconData = Icons.timer_off;
        message = "请检查设备时间";
        break;
      case ERROR_TYPE_UNDER_REVIEW:
        iconData = Icons.highlight_off;
        message = "资源未审核或不可用";
        break;
      default:
        iconData = Icons.highlight_off;
        message = "啊哦, 被玩坏了";
        break;
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        debugPrient("$error");
        debugPrient("$stackTrace");
        var width = constraints.maxWidth;
        var height = constraints.maxHeight;
        var min = width < height ? width : height;
        var iconSize = min / 2.3;
        var textSize = min / 16;
        var tipSize = min / 20;
        var infoSize = min / 30;
        return GestureDetector(
          onTap: onRefresh,
          child: ListView(
            children: [
              Container(
                height: height,
                child: Column(
                  children: [
                    Expanded(child: Container()),
                    Container(
                      child: Icon(
                        iconData,
                        size: iconSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Container(height: min / 10),
                    Container(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                      ),
                      child: Text(
                        message,
                        style: TextStyle(fontSize: textSize),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text('(点击刷新)', style: TextStyle(fontSize: tipSize)),
                    Container(height: min / 15),
                    Text('$error', style: TextStyle(fontSize: infoSize)),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
