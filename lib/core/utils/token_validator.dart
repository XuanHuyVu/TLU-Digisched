import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenValidator {
  /// Check xem token có còn hạn không
  /// Returns true nếu token còn hạn, false nếu hết hạn hoặc invalid
  static bool isTokenValid(String token) {
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      debugPrint('❌ Token validation error: $e');
      return false;
    }
  }

  /// Lấy thời gian hết hạn của token
  static DateTime? getTokenExpiration(String token) {
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      debugPrint('❌ Error getting token expiration: $e');
      return null;
    }
  }

  /// Check xem token sắp hết hạn (trong vòng X phút)
  static bool isTokenExpiringSoon(String token, {int minutesBefore = 5}) {
    try {
      final expiration = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();
      final bufferTime = now.add(Duration(minutes: minutesBefore));
      return expiration.isBefore(bufferTime);
    } catch (e) {
      return true; // Nếu lỗi, coi như hết hạn để an toàn
    }
  }

  /// Decode token và lấy payload
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      debugPrint('❌ Error decoding token: $e');
      return null;
    }
  }
}
