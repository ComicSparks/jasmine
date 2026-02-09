import 'package:flutter/material.dart';
import 'package:jasmine/basic/methods.dart';

const _propertyName = "gestureSpeed";
const _defaultGestureSpeed = 1.0;

late double _gestureSpeed;

Future<void> initGestureSpeed() async {
  final value = await methods.loadProperty(_propertyName);
  _gestureSpeed = double.tryParse(value) ?? _defaultGestureSpeed;
  _gestureSpeed = _gestureSpeed.clamp(0.2, 3.0);
}

double currentGestureSpeed() => _gestureSpeed;

Widget gestureSpeedSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text("手势速度 : ${_gestureSpeed.toStringAsFixed(1)}x"),
        subtitle: Slider(
          value: _gestureSpeed,
          min: 0.2,
          max: 3.0,
          divisions: 28,
          label: "${_gestureSpeed.toStringAsFixed(1)}x",
          onChanged: (v) async {
            final value = (v * 10).roundToDouble() / 10.0;
            await methods.saveProperty(_propertyName, value.toString());
            setState(() {
              _gestureSpeed = value;
            });
          },
        ),
        trailing: Text(
          "${_gestureSpeed.toStringAsFixed(1)}x",
          style: const TextStyle(fontSize: 16),
        ),
      );
    },
  );
}
