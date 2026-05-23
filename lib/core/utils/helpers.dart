import 'dart:convert';
import 'package:crypto/crypto.dart';

class Helpers {
  Helpers._();

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }

  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode.abs().toString();
    return '${timestamp}_$random';
  }

  static double clampBattery(int percent) =>
      percent.clamp(0, 100).toDouble();

  static bool isBatteryLow(int percent) => percent <= 20;
  static bool isBatteryCritical(int percent) => percent <= 10;
}
