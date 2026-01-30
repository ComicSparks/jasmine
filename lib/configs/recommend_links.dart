import 'package:event/event.dart';

import '../basic/methods.dart';

final recommendLinksEvent = Event();
Map<String, String> _recommendLinks = {};

Map<String, String> currentRecommendLinks() => _recommendLinks;

Future<void> initRecommendLinks() async {
  try {
    _recommendLinks = await methods.configLinks();
  } catch (_) {
    _recommendLinks = {};
  }
  recommendLinksEvent.broadcast();
}
