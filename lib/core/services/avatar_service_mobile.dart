import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io' show File;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class AvatarService {
  static const _prefsKey = "profile_avatar_base64";

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

  static Future<void> saveAvatar(String base64Image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, base64Image);
  }

  static Future<String?> loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey);
  }

  static Future<void> removeAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  static Future<String?> pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    Uint8List? bytes;
    final file = result.files.first;

    if (file.path != null) {
      final f = File(file.path!);
      bytes = await f.readAsBytes();
    } else {
      bytes = file.bytes;
    }

    if (bytes == null) return null;

    // Resize nếu quá lớn
    if (bytes.length > 500000) {
      final resized = await resizeImage(bytes);
      bytes = resized ?? bytes;
    }

    final base64Image = base64Encode(bytes);
    await saveAvatar(base64Image);
    return base64Image;
  }
}
