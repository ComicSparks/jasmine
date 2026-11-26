import 'package:flutter/material.dart';
import 'package:jasmine/basic/methods.dart';

enum ReaderWheelMode { page, distance }

const _modeProperty = "readerWheelMode";
const _eventsProperty = "readerWheelEventsPerPage";
const _stepProperty = "readerWheelStepPercent";
const _noAnimationProperty = "readerWheelNoAnimation";

late ReaderWheelMode _mode;
late int _eventsPerPage;
late int _stepPercent;
late bool _wheelNoAnimation;

ReaderWheelMode get readerWheelMode => _mode;

int get readerWheelEventsPerPage => _eventsPerPage;

int get readerWheelStepPercent => _stepPercent;

double get readerWheelStepFraction => _stepPercent / 100;

bool readerWheelNoAnimation() => _wheelNoAnimation;

Future<void> initReaderWheel() async {
  _mode = (await methods.loadProperty(_modeProperty)) == "distance"
      ? ReaderWheelMode.distance
      : ReaderWheelMode.page;
  _eventsPerPage = _clampEvents(
    int.tryParse(await methods.loadProperty(_eventsProperty)) ?? 1,
  );
  _stepPercent = _clampStep(
    int.tryParse(await methods.loadProperty(_stepProperty)) ?? 50,
  );
  _wheelNoAnimation =
      (await methods.loadProperty(_noAnimationProperty)) == "true";
}

int _clampEvents(int value) => value.clamp(1, 4).toInt();

int _clampStep(int value) => value.clamp(10, 100).toInt();

String readerWheelModeName() => _mode == ReaderWheelMode.distance ? "按距离" : "按页";

Future<void> chooseReaderWheelMode(BuildContext context) async {
  final result = await showDialog<ReaderWheelMode>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text("选择滚轮翻页方式"),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ReaderWheelMode.page),
            child: const Text("按页"),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ReaderWheelMode.distance),
            child: const Text("按距离"),
          ),
        ],
      );
    },
  );
  if (result == null) return;
  _mode = result;
  await methods.saveProperty(
    _modeProperty,
    result == ReaderWheelMode.distance ? "distance" : "page",
  );
}

Future<void> setReaderWheelEventsPerPage(int value) async {
  _eventsPerPage = _clampEvents(value);
  await methods.saveProperty(_eventsProperty, "$_eventsPerPage");
}

Future<void> setReaderWheelStepPercent(int value) async {
  _stepPercent = _clampStep(value);
  await methods.saveProperty(_stepProperty, "$_stepPercent");
}

Future<void> setReaderWheelNoAnimation(bool value) async {
  _wheelNoAnimation = value;
  await methods.saveProperty(_noAnimationProperty, "$value");
}

class ReaderWheelSettings extends StatefulWidget {
  const ReaderWheelSettings({Key? key}) : super(key: key);

  @override
  State<ReaderWheelSettings> createState() => _ReaderWheelSettingsState();
}

class _ReaderWheelSettingsState extends State<ReaderWheelSettings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text("滚轮翻页方式"),
          subtitle: Text(readerWheelModeName()),
          onTap: () async {
            await chooseReaderWheelMode(context);
            setState(() {});
          },
        ),
        ListTile(
          title: Text("滚轮翻一页所需次数 : $_eventsPerPage"),
          subtitle: Slider(
            min: 1,
            max: 4,
            divisions: 3,
            value: _eventsPerPage.toDouble(),
            onChanged: (double value) async {
              await setReaderWheelEventsPerPage(value.round());
              setState(() {});
            },
          ),
        ),
        ListTile(
          title: Text("滚轮每次滚动距离 : $_stepPercent%"),
          subtitle: Slider(
            min: 10,
            max: 100,
            divisions: 90,
            value: _stepPercent.toDouble(),
            onChanged: (double value) async {
              await setReaderWheelStepPercent(value.round());
              setState(() {});
            },
          ),
        ),
        SwitchListTile(
          title: const Text("取消滚轮翻页动画"),
          value: _wheelNoAnimation,
          onChanged: (bool value) async {
            await setReaderWheelNoAnimation(value);
            setState(() {});
          },
        ),
      ],
    );
  }
}
