import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  final _storage = const FlutterSecureStorage();
  static String TOKEN_KEY = "user_token_ffa";
  Future<void> saveToken(String token) async {
    await _storage.write(key: TOKEN_KEY, value: token); 
  }
  Future<String> getToken() async {
    return await _storage.read(key: TOKEN_KEY) ?? ""; 
  }
  
}
