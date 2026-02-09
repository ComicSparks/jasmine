import 'package:flutter/material.dart';
import 'package:jasmine/basic/methods.dart';

const _readerZoomMinPropertyName = "readerZoomMinScale";
const _readerZoomMaxPropertyName = "readerZoomMaxScale";
const _readerZoomDoubleTapPropertyName = "readerZoomDoubleTapScale";

late double _readerZoomMinScale;
late double _readerZoomMaxScale;
late double _readerZoomDoubleTapScale;

double get readerZoomMinScale => _readerZoomMinScale;
double get readerZoomMaxScale => _readerZoomMaxScale;
double get readerZoomDoubleTapScale => _readerZoomDoubleTapScale;

Future<void> initReaderZoomScale() async {
  _readerZoomMinScale = double.tryParse(
        await methods.loadProperty(_readerZoomMinPropertyName),
      ) ??
      1.0;
  _readerZoomMaxScale = double.tryParse(
        await methods.loadProperty(_readerZoomMaxPropertyName),
      ) ??
      2.0;
  _readerZoomDoubleTapScale = double.tryParse(
        await methods.loadProperty(_readerZoomDoubleTapPropertyName),
      ) ??
      2.0;

  _readerZoomMinScale = _readerZoomMinScale.clamp(0.2, 1.0);
  _readerZoomMaxScale = _readerZoomMaxScale.clamp(1.0, 30.0);
  _readerZoomDoubleTapScale = _readerZoomDoubleTapScale.clamp(1.2, 5.0);
  if (_readerZoomMaxScale < _readerZoomMinScale) {
    _readerZoomMaxScale = _readerZoomMinScale;
  }
  if (_readerZoomDoubleTapScale > _readerZoomMaxScale) {
    _readerZoomDoubleTapScale = _readerZoomMaxScale;
  }
}

Widget readerZoomMinScaleSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text("缩小最小倍数 : ${_readerZoomMinScale.toStringAsFixed(1)}x"),
        subtitle: Slider(
          value: _readerZoomMinScale,
          min: 0.2,
          max: 1.0,
          divisions: 8,
          label: "${_readerZoomMinScale.toStringAsFixed(1)}x",
          onChanged: (newValue) async {
            final value = (newValue * 10).roundToDouble() / 10.0;
            await methods.saveProperty(_readerZoomMinPropertyName, "$value");
            setState(() {
              _readerZoomMinScale = value;
              if (_readerZoomMaxScale < _readerZoomMinScale) {
                _readerZoomMaxScale = _readerZoomMinScale;
              }
              if (_readerZoomDoubleTapScale > _readerZoomMaxScale) {
                _readerZoomDoubleTapScale = _readerZoomMaxScale;
              }
            });
          },
        ),
        trailing: Text(
          "${_readerZoomMinScale.toStringAsFixed(1)}x",
          style: const TextStyle(fontSize: 16),
        ),
      );
    },
  );
}

Widget readerZoomMaxScaleSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text("放大最大倍数 : ${_readerZoomMaxScale.toStringAsFixed(1)}x"),
        subtitle: Slider(
          value: _readerZoomMaxScale,
          min: 1.0,
          max: 30.0,
          divisions: 58,
          label: "${_readerZoomMaxScale.toStringAsFixed(1)}x",
          onChanged: (newValue) async {
            final value = (newValue * 10).roundToDouble() / 10.0;
            await methods.saveProperty(_readerZoomMaxPropertyName, "$value");
            setState(() {
              _readerZoomMaxScale = value;
              if (_readerZoomMaxScale < _readerZoomMinScale) {
                _readerZoomMinScale = _readerZoomMaxScale;
              }
              if (_readerZoomDoubleTapScale > _readerZoomMaxScale) {
                _readerZoomDoubleTapScale = _readerZoomMaxScale;
              }
            });
          },
        ),
        trailing: Text(
          "${_readerZoomMaxScale.toStringAsFixed(1)}x",
          style: const TextStyle(fontSize: 16),
        ),
      );
    },
  );
}

Widget readerZoomDoubleTapScaleSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title:
            Text("双击放大倍数 : ${_readerZoomDoubleTapScale.toStringAsFixed(1)}x"),
        subtitle: Slider(
          value: _readerZoomDoubleTapScale,
          min: 1.2,
          max: 5.0,
          divisions: 38,
          label: "${_readerZoomDoubleTapScale.toStringAsFixed(1)}x",
          onChanged: (newValue) async {
            final value = (newValue * 10).roundToDouble() / 10.0;
            await methods.saveProperty(
                _readerZoomDoubleTapPropertyName, "$value");
            setState(() {
              _readerZoomDoubleTapScale = value;
              if (_readerZoomDoubleTapScale > _readerZoomMaxScale) {
                _readerZoomDoubleTapScale = _readerZoomMaxScale;
              }
              if (_readerZoomDoubleTapScale < _readerZoomMinScale) {
                _readerZoomDoubleTapScale = _readerZoomMinScale;
              }
            });
          },
        ),
        trailing: Text(
          "${_readerZoomDoubleTapScale.toStringAsFixed(1)}x",
          style: const TextStyle(fontSize: 16),
        ),
      );
    },
  );
}
