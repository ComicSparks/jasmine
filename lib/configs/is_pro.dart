import 'package:event/event.dart';
import '../basic/methods.dart';

var isPro = false;
var isProEx = 0;

ProInfoAf? _proInfoAf;
ProInfoPat? _proInfoPat;

ProInfoAf get proInfoAf => _proInfoAf ?? ProInfoAf.fromJson({"is_pro": false, "expire": 0});
ProInfoPat get proInfoPat => _proInfoPat ?? ProInfoPat.fromJson({"is_pro": false, "pat_id": "", "bind_uid": "", "request_delete": 0, "re_bind": 0, "error_type": 0, "error_msg": "", "access_key": ""});

final proEvent = Event();

Future reloadIsPro() async {
  final proInfoAll = await methods.proInfoAll();
  _proInfoAf = proInfoAll.proInfoAf;
  _proInfoPat = proInfoAll.proInfoPat;
  
  isPro = _proInfoAf!.isPro || _proInfoPat!.isPro;
  isProEx = _proInfoAf!.expire;
  
  proEvent.broadcast();
}
