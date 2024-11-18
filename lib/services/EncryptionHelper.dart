import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class EncryptionHelper {
  static final _key = Key.fromUtf8('my32lengthsupersecretnooneknows1');

  static String encrypt(String plaintext) {
    final encrypter = Encrypter(AES(_key));
    final iv = IV.fromLength(16);

    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    String ivBase64 = base64.encode(iv.bytes);
    String encryptedBase64 = encrypted.base64;
    return '$ivBase64:$encryptedBase64';
  }

  static String decrypt(String combinedEncryptedData) {
    final encrypter = Encrypter(AES(_key));
    List<String> parts = combinedEncryptedData.split(':');
    if (parts.length != 2) {
      throw Exception("Invalid encrypted data format.");
    }
    final iv = IV.fromBase64(parts[0]);
    final encryptedText = parts[1];
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }
}
