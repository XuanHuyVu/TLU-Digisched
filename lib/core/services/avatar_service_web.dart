import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';

class AvatarService {
  static const _prefsKey = "profile_avatar_base64";

  /// Resize ảnh về kích thước chuẩn (300x300)
  static Future<Uint8List?> resizeImage(Uint8List imageBytes) async {
    try {
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: 300,
        targetHeight: 300,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final byteData =
      await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// Lưu avatar vào localStorage + sessionStorage
  static Future<void> saveAvatar(String base64Image) async {
    final domain = html.window.location.hostname;
    final avatarKey = "tlu_avatar_${domain}_base64";
    html.window.localStorage[avatarKey] = base64Image;
    html.window.sessionStorage['tlu_avatar_session'] = base64Image;
  }

  /// Load avatar
  static Future<String?> loadAvatar() async {
    final domain = html.window.location.hostname;
    final avatarKey = "tlu_avatar_${domain}_base64";
    return html.window.localStorage[avatarKey] ??
        html.window.sessionStorage['tlu_avatar_session'];
  }

  /// Xoá avatar
  static Future<void> removeAvatar() async {
    final domain = html.window.location.hostname;
    html.window.localStorage.remove("tlu_avatar_${domain}_base64");
    html.window.sessionStorage.remove('tlu_avatar_session');
  }

  /// Chọn avatar mới từ Web (FilePicker)
  static Future<String?> pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // quan trọng cho web
    );

    if (result == null || result.files.isEmpty) return null;

    Uint8List? bytes = result.files.first.bytes;

    if (bytes == null) return null;

    // Resize nếu quá lớn (>500KB)
    if (bytes.length > 500000) {
      final resized = await resizeImage(bytes);
      bytes = resized ?? bytes;
    }

    final base64Image = base64Encode(bytes);
    await saveAvatar(base64Image);
    return base64Image;
  }
}
