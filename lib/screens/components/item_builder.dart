import 'package:flutter/material.dart';
import 'package:jasmine/basic/log.dart';

// 非全屏FutureBuilder封装
class ItemBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final AsyncWidgetBuilder<T> successBuilder;
  final Future<dynamic> Function() onRefresh;
  final double? loadingHeight;
  final double? height;

  const ItemBuilder({
    Key? key,
    required this.future,
    required this.successBuilder,
    required this.onRefresh,
    this.height,
    this.loadingHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var _maxWidth = constraints.maxWidth;
        var _loadingHeight = height ?? loadingHeight ?? _maxWidth / 2;
        return FutureBuilder(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
              if (snapshot.hasError) {
                debugPrient("${snapshot.error}");
                debugPrient("${snapshot.stackTrace}");
                return InkWell(
                  onTap: onRefresh,
                  child: Container(
                    width: _maxWidth,
                    height: _loadingHeight,
                    child: Center(
                      child:
                          Icon(Icons.sync_problem, size: _loadingHeight / 1.5),
                    ),
                  ),
                );
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return SizedBox(
                  width: _maxWidth,
                  height: _loadingHeight,
                  child: Center(
                    child: Icon(Icons.sync, size: _loadingHeight / 1.5),
                  ),
                );
              }
              return SizedBox(
                width: _maxWidth,
                height: height,
                child: successBuilder(context, snapshot),
              );
            });
      },
    );
  }
}
