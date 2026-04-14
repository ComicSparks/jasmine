import '../basic/methods.dart';
import 'always_enter_browser.dart';

const _propertyName = "passed";
late bool _passed;

Future<void> initPassed() async {
  _passed = (await methods.loadProperty(_propertyName)) == "true";
}

bool currentPassed() {
  return _passed && !currentAlwaysEnterBrowser();
}

Future<void> firstPassed() async {
  if (currentAlwaysEnterBrowser()) {
    _passed = false;
    return;
  }
  await methods.saveProperty(_propertyName, "true");
  _passed = true;
}

Future<void> clearPassed() async {
  await methods.deleteProperty(_propertyName);
  _passed = false;
}
