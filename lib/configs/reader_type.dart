import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/methods.dart';

enum ReaderType {
  webtoon,
  gallery,
  webToonFreeZoom,
  twoPageGallery,
}

const _propertyName = "readerType";
late ReaderType _readerType;

Future initReaderType() async {
  _readerType = _fromString(await methods.loadProperty(_propertyName));
}

ReaderType _fromString(String valueForm) {
  for (var value in ReaderType.values) {
    if (value.toString() == valueForm) {
      return value;
    }
  }
  return ReaderType.values.first;
}

ReaderType get currentReaderType => _readerType;

String readerTypeName(ReaderType type, BuildContext context) {
  switch (type) {
    case ReaderType.webtoon:
      return "WebToon";
    case ReaderType.gallery:
      return "相册";
    case ReaderType.webToonFreeZoom:
      return "自由放大滚动";
    case ReaderType.twoPageGallery:
      return "双页相册";
  }
}

Future chooseReaderType(BuildContext context) async {
  final Map<String, ReaderType> map = {};
  for (var element in ReaderType.values) {
    map[readerTypeName(element, context)] = element;
  }
  final newReaderType = await chooseMapDialog(
    context,
    title: "请选择阅读器类型",
    values: map,
  );
  if (newReaderType != null) {
    await methods.saveProperty(_propertyName, "$newReaderType");
    _readerType = newReaderType;
  }
}
