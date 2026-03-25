import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Khởi tạo timezone 1 lần khi app start
class TimezoneHelper {
  static bool _inited = false;

  static Future<void> ensureInitialized({String? localeName}) async {
    if (_inited) return;
    tzdata.initializeTimeZones();
    // VN: Asia/Ho_Chi_Minh; nếu muốn tự động, có thể dùng native query
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    _inited = true;
  }

  static tz.TZDateTime fromLocal(DateTime localTime) {
    final loc = tz.local;
    return tz.TZDateTime.from(localTime, loc);
  }
}
