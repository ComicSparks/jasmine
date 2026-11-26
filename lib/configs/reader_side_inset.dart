import 'package:flutter/material.dart';
import 'package:jasmine/basic/methods.dart';

enum ReaderSideInsetMode { percent, size }

const _modeProperty = "readerSideInsetMode";
const _portraitProperty = "readerSideInsetPortrait";
const _landscapeProperty = "readerSideInsetLandscape";
const double _minContent = 48;

late ReaderSideInsetMode _mode;
late double _portrait;
late double _landscape;

/// Bumped when a side-inset setting is saved, so an open reader can relayout.
final ValueNotifier<int> readerSideInsetListenable = ValueNotifier<int>(0);

ReaderSideInsetMode get readerSideInsetMode => _mode;
double get readerSideInsetPortrait => _portrait;
double get readerSideInsetLandscape => _landscape;

Future<void> initReaderSideInset() async {
  final mode = await methods.loadProperty(_modeProperty);
  _mode = mode == "size" ? ReaderSideInsetMode.size : ReaderSideInsetMode.percent;
  _portrait = _stored(double.tryParse(await methods.loadProperty(_portraitProperty)) ?? 0);
  _landscape =
      _stored(double.tryParse(await methods.loadProperty(_landscapeProperty)) ?? 0);
}

double _stored(double value) {
  if (value < 0) return 0;
  final maxValue = _mode == ReaderSideInsetMode.percent ? 30.0 : 160.0;
  if (value > maxValue) return maxValue;
  return value;
}

void _notify() {
  readerSideInsetListenable.value++;
}

Future<void> setReaderSideInsetMode(ReaderSideInsetMode value) async {
  _mode = value;
  _portrait = _stored(_portrait);
  _landscape = _stored(_landscape);
  await methods.saveProperty(
    _modeProperty,
    value == ReaderSideInsetMode.size ? "size" : "percent",
  );
  await methods.saveProperty(_portraitProperty, _portrait.toStringAsFixed(0));
  await methods.saveProperty(_landscapeProperty, _landscape.toStringAsFixed(0));
  _notify();
}

Future<void> setReaderSideInsetPortrait(double value) async {
  _portrait = _stored(value);
  await methods.saveProperty(_portraitProperty, _portrait.toStringAsFixed(0));
  _notify();
}

Future<void> setReaderSideInsetLandscape(double value) async {
  _landscape = _stored(value);
  await methods.saveProperty(_landscapeProperty, _landscape.toStringAsFixed(0));
  _notify();
}

String readerSideInsetModeName() {
  return _mode == ReaderSideInsetMode.size ? "固定尺寸" : "百分比";
}

String readerSideInsetValueLabel(double value) {
  if (_mode == ReaderSideInsetMode.percent) {
    return "每侧 ${value.toStringAsFixed(0)}%";
  }
  return "每侧 ${value.toStringAsFixed(0)}";
}

ReaderSideFrame readerSideFrame({
  required bool verticalReader,
  required Size viewport,
}) {
  final landscape = viewport.width > viewport.height;
  final stored = landscape ? _landscape : _portrait;
  final cross = verticalReader ? viewport.width : viewport.height;
  if (stored <= 0 || !(cross > _minContent)) {
    return const ReaderSideFrame(0);
  }
  final raw = _mode == ReaderSideInsetMode.percent
      ? cross * stored / 100.0
      : stored;
  final limit = (cross - _minContent) / 2;
  final inset = raw <= 0 ? 0.0 : (raw > limit ? limit : raw);
  return ReaderSideFrame(inset);
}

EdgeInsets readerSidePaddingOf(
  BuildContext context,
  BoxConstraints constraints, {
  required bool verticalReader,
}) {
  final width = constraints.maxWidth.isFinite
      ? constraints.maxWidth
      : MediaQuery.sizeOf(context).width;
  final height = constraints.maxHeight.isFinite
      ? constraints.maxHeight
      : MediaQuery.sizeOf(context).height;
  return readerSideFrame(
    verticalReader: verticalReader,
    viewport: Size(width, height),
  ).padding(
    verticalReader: verticalReader,
    availableCross: verticalReader ? width : height,
  );
}

class ReaderSideFrame {
  final double inset;

  const ReaderSideFrame(this.inset);

  double fit(double available) {
    if (!(available > _minContent)) {
      return available > 0 ? available : 0;
    }
    final limit = (available - _minContent) / 2;
    final used = inset <= 0 ? 0.0 : (inset > limit ? limit : inset);
    return available - used * 2;
  }

  Widget place(Widget child) {
    if (inset <= 0) return child;
    return Align(alignment: Alignment.center, child: child);
  }

  EdgeInsets padding({
    required bool verticalReader,
    required double availableCross,
  }) {
    if (!(availableCross > 0)) return EdgeInsets.zero;
    final side = (availableCross - fit(availableCross)) / 2;
    if (!(side > 0)) return EdgeInsets.zero;
    return verticalReader
        ? EdgeInsets.symmetric(horizontal: side)
        : EdgeInsets.symmetric(vertical: side);
  }
}

Future<void> chooseReaderSideInsetMode(BuildContext context) async {
  final choose = await showDialog<ReaderSideInsetMode>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text("选择两侧留白方式"),
        children: [
          SimpleDialogOption(
            child: const Text("百分比"),
            onPressed: () =>
                Navigator.of(context).pop(ReaderSideInsetMode.percent),
          ),
          SimpleDialogOption(
            child: const Text("固定尺寸"),
            onPressed: () => Navigator.of(context).pop(ReaderSideInsetMode.size),
          ),
        ],
      );
    },
  );
  if (choose != null) {
    await setReaderSideInsetMode(choose);
  }
}

class ReaderSideInsetSettings extends StatefulWidget {
  const ReaderSideInsetSettings({Key? key}) : super(key: key);

  @override
  State<ReaderSideInsetSettings> createState() => _ReaderSideInsetSettingsState();
}

class _ReaderSideInsetSettingsState extends State<ReaderSideInsetSettings> {
  @override
  void initState() {
    super.initState();
    readerSideInsetListenable.addListener(_onChanged);
  }

  @override
  void dispose() {
    readerSideInsetListenable.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = _mode == ReaderSideInsetMode.percent ? 30.0 : 160.0;
    return Column(
      children: [
        ListTile(
          title: const Text("两侧留白方式"),
          subtitle: Text(readerSideInsetModeName()),
          onTap: () => chooseReaderSideInsetMode(context),
        ),
        _slider(
          title: "竖屏留白",
          value: _portrait,
          maxValue: maxValue,
          save: setReaderSideInsetPortrait,
        ),
        _slider(
          title: "横屏留白",
          value: _landscape,
          maxValue: maxValue,
          save: setReaderSideInsetLandscape,
        ),
      ],
    );
  }

  Widget _slider({
    required String title,
    required double value,
    required double maxValue,
    required Future<void> Function(double value) save,
  }) {
    final shown = value.clamp(0.0, maxValue).toDouble();
    return ListTile(
      title: Text("$title : ${readerSideInsetValueLabel(shown)}"),
      subtitle: Slider(
        min: 0,
        max: maxValue,
        divisions: maxValue.toInt(),
        value: shown,
        label: readerSideInsetValueLabel(shown),
        onChanged: (double next) => save(next.roundToDouble()),
      ),
    );
  }
}
