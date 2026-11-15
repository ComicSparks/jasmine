/// 内容繁简体转换 (仅影响显示)

import 'dart:ffi';
import 'dart:io';

import 'package:event/event.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import '../basic/commons.dart';
import '../basic/methods.dart';

enum ContentConvertMode {
  off,
  s2t,
  t2s,
}

const _propertyName = "contentConvertMode";
ContentConvertMode _mode = ContentConvertMode.off;
final Map<String, String> _cache = {};
_ZhFfi? _zhFfi;
bool _zhFfiTried = false;

final contentConvertEvent = Event<EventArgs>();

Future<void> initContentConvert() async {
  final value = await methods.loadProperty(_propertyName);
  await _applyMode(ContentConvertMode.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ContentConvertMode.off,
  ));
}

Future<void> _applyMode(ContentConvertMode mode) async {
  _mode = mode;
  _cache.clear();
}

_ZhFfi? _openZhFfi() {
  if (_zhFfiTried) {
    return _zhFfi;
  }
  _zhFfiTried = true;
  try {
    final os = Platform.operatingSystem;
    final DynamicLibrary lib;
    if (os == 'android' || os == 'ohos') {
      lib = DynamicLibrary.open('librust.so');
    } else if (os == 'ios' || os == 'macos') {
      lib = DynamicLibrary.process();
    } else {
      lib = DynamicLibrary.executable();
    }
    _zhFfi = _ZhFfi(
      lib.lookupFunction<_ConvertNative, _ConvertDart>('convert_zh_ffi'),
      lib.lookupFunction<_FreeNative, _FreeDart>('free_str_ffi'),
    );
  } catch (e) {
    debugPrint('content convert unavailable: $e');
    _zhFfi = null;
  }
  return _zhFfi;
}

/// 仅用于展示, 不要用于复制/编辑/保存/上传
String ccConvert(String raw) {
  if (_mode == ContentConvertMode.off || raw.isEmpty) {
    return raw;
  }
  final cached = _cache[raw];
  if (cached != null) {
    return cached;
  }
  final ffi = _openZhFfi();
  if (ffi == null) {
    return raw;
  }
  try {
    final converted = ffi.convert(_mode.name, raw);
    if (_cache.length > 4000) {
      _cache.clear();
    }
    _cache[raw] = converted;
    return converted;
  } catch (e) {
    debugPrint('content convert failed: $e');
    return raw;
  }
}

typedef _ConvertNative = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _ConvertDart = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _FreeNative = Void Function(Pointer<Utf8>);
typedef _FreeDart = void Function(Pointer<Utf8>);

class _ZhFfi {
  final _ConvertDart _convert;
  final _FreeDart _free;

  _ZhFfi(this._convert, this._free);

  String convert(String mode, String text) {
    final modePtr = mode.toNativeUtf8();
    final textPtr = text.toNativeUtf8();
    try {
      final out = _convert(modePtr, textPtr);
      if (out == nullptr) {
        return text;
      }
      try {
        return out.toDartString();
      } finally {
        _free(out);
      }
    } finally {
      calloc.free(modePtr);
      calloc.free(textPtr);
    }
  }
}

/// 设置变更时重建, 用于 Text.rich 等需要自行调用 ccConvert 的场景
class CcBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const CcBuilder(this.builder);

  @override
  State<StatefulWidget> createState() => CcBuilderState();
}

class CcBuilderState extends State<CcBuilder> {
  @override
  void initState() {
    contentConvertEvent.subscribe(_onChanged);
    super.initState();
  }

  @override
  void dispose() {
    contentConvertEvent.unsubscribe(_onChanged);
    super.dispose();
  }

  void _onChanged(_) {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

/// 与 Text 用法一致, 显示时按设置转换繁简体
class CcText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final StrutStyle? strutStyle;

  const CcText(
    this.data, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.strutStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CcBuilder(
      (context) => Text(
        ccConvert(data),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        strutStyle: strutStyle,
      ),
    );
  }
}

/// 与 SelectableText 用法一致, 选择复制得到转换后的文本
class CcSelectableText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  const CcSelectableText(
    this.data, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CcBuilder(
      (context) => SelectableText(
        ccConvert(data),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
      ),
    );
  }
}

Widget contentConvertSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      final names = {
        ContentConvertMode.off: '关闭',
        ContentConvertMode.s2t: '简体 -> 繁体',
        ContentConvertMode.t2s: '繁体 -> 简体',
      };
      return ListTile(
        title: const Text('内容繁简体转换'),
        subtitle: Text(names[_mode]!),
        onTap: () async {
          final mode = await chooseMapDialog<ContentConvertMode>(
            context,
            title: '内容繁简体转换',
            values: {for (final e in names.entries) e.value: e.key},
          );
          if (mode != null) {
            await methods.saveProperty(_propertyName, mode.name);
            await _applyMode(mode);
            contentConvertEvent.broadcast();
            setState(() {});
          }
        },
      );
    },
  );
}
