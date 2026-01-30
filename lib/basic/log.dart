import 'package:flutter/foundation.dart';

void debugPrient(Object? message) {
  if (!kDebugMode) {
    return;
  }
  debugPrint("$message");
}
